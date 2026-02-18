const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { logger } = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

exports.sendPushForUserNotification = onDocumentCreated(
   {
      document: 'users/{userId}/notifications/{notificationId}',
      region: 'europe-west1',
   },
   async (event) => {
      const snapshot = event.data;
      if (!snapshot) {
         logger.warn('Notification event has no snapshot');
         return;
      }

      const { userId, notificationId } = event.params;
      const notification = snapshot.data() || {};

      const title = `${notification.title || 'Tur Bildirim'}`.trim();
      const body = `${notification.message || ''}`.trim();
      const tourId = `${notification.tourId || ''}`.trim();

      if (!body) {
         logger.info('Notification body empty, skipping push', { userId, notificationId });
         return;
      }

      if (tourId) {
         const checkedInTicket = await db
            .collection('tickets')
            .where('tourId', '==', tourId)
            .where('userId', '==', userId)
            .where('isScanned', '==', true)
            .limit(1)
            .get();

         if (checkedInTicket.empty) {
            logger.info('User is not checked-in for this tour, push skipped', {
               userId,
               notificationId,
               tourId,
            });

            await snapshot.ref.set(
               {
                  pushStatus: 'skipped_not_checked_in',
                  pushCheckedAt: admin.firestore.FieldValue.serverTimestamp(),
               },
               { merge: true },
            );
            return;
         }
      }

      const userDoc = await db.collection('users').doc(userId).get();
      if (!userDoc.exists) {
         logger.warn('User doc missing for notification', { userId, notificationId });
         return;
      }

      const userData = userDoc.data() || {};
      const tokenField = userData.fcmTokens;
      const fcmTokens = Array.isArray(tokenField)
         ? tokenField.map((token) => `${token}`.trim()).filter(Boolean)
         : [];

      if (fcmTokens.length === 0) {
         logger.info('No FCM tokens for user, skipping push', { userId, notificationId });
         await snapshot.ref.set(
            {
               pushStatus: 'no_token',
               pushCheckedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true },
         );
         return;
      }

      const response = await admin.messaging().sendEachForMulticast({
         tokens: fcmTokens,
         notification: { title, body },
         data: {
            tourId,
            notificationId,
            type: 'tour_announcement',
         },
         android: {
            priority: 'high',
         },
         apns: {
            headers: {
               'apns-priority': '10',
            },
         },
      });

      const invalidTokenCodes = new Set([
         'messaging/registration-token-not-registered',
         'messaging/invalid-registration-token',
      ]);

      const invalidTokens = [];
      response.responses.forEach((result, index) => {
         if (!result.success && invalidTokenCodes.has(result.error?.code)) {
            invalidTokens.push(fcmTokens[index]);
         }
      });

      if (invalidTokens.length > 0) {
         await db.collection('users').doc(userId).set(
            {
               fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
               fcmUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true },
         );
      }

      await snapshot.ref.set(
         {
            pushStatus: response.failureCount === 0 ? 'sent' : 'partial',
            pushSuccessCount: response.successCount,
            pushFailureCount: response.failureCount,
            pushSentAt: admin.firestore.FieldValue.serverTimestamp(),
         },
         { merge: true },
      );

      logger.info('Push send completed', {
         userId,
         notificationId,
         success: response.successCount,
         failure: response.failureCount,
      });
   },
);

exports.fanoutAnnouncementToCheckedInParticipants = onDocumentCreated(
   {
      document: 'tours/{tourId}/announcements/{announcementId}',
      region: 'europe-west1',
   },
   async (event) => {
      const snapshot = event.data;
      if (!snapshot) {
         logger.warn('Announcement event has no snapshot');
         return;
      }

      const { tourId, announcementId } = event.params;
      const data = snapshot.data() || {};
      const message = `${data.notification || ''}`.trim();
      if (!message) {
         logger.info('Announcement message empty, fanout skipped', { tourId, announcementId });
         return;
      }

      const ticketsSnap = await db
         .collection('tickets')
         .where('tourId', '==', tourId)
         .where('isScanned', '==', true)
         .get();

      const userIds = new Set();
      ticketsSnap.docs.forEach((doc) => {
         const userId = `${doc.get('userId') || ''}`.trim();
         if (userId) userIds.add(userId);
      });

      if (userIds.size === 0) {
         logger.info('No checked-in participants for announcement', { tourId, announcementId });
         return;
      }

      const writeBatch = db.batch();
      const now = admin.firestore.FieldValue.serverTimestamp();

      for (const userId of userIds) {
         const notifRef = db.collection('users').doc(userId).collection('notifications').doc();
         writeBatch.set(notifRef, {
            title: 'Tur Bildirim',
            message,
            tourId,
            scope: 'checked_in_only',
            sourceAnnouncementId: announcementId,
            createdAt: now,
            isRead: false,
         });
      }

      await writeBatch.commit();
      logger.info('Announcement fanout completed', {
         tourId,
         announcementId,
         participantCount: userIds.size,
      });
   },
);
