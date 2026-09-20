import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/driver_restaurant_entity.dart';
import '../repo/driver_registration_repository.dart';

@injectable
class GetDriverRestaurantsUseCase {
  const GetDriverRestaurantsUseCase(this._repository);

  final DriverRegistrationRepository _repository;

  Future<ApiResult<List<DriverRestaurantEntity>>> call() =>
      _repository.getRestaurants();
}
