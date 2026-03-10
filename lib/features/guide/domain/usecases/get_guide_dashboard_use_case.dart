import '../entities/guide_dashboard_entity.dart';
import '../repositories/guide_repository.dart';

class GetGuideDashboardUseCase {
  GetGuideDashboardUseCase(this._repository);

  final GuideRepository _repository;

  Future<GuideDashboardEntity> execute() {
    return _repository.getDashboard();
  }
}
