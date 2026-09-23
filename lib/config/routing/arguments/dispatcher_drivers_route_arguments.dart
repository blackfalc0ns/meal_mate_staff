import '../../../features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_view_mode.dart';
import '../../../features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_mode.dart';

class DispatcherDriversRouteArgs {
  const DispatcherDriversRouteArgs.browse({
    this.initialView = DispatcherDriverViewMode.byArea,
    this.initialAreaKey,
    this.initialAreaName,
  }) : mode = DispatcherDriversMode.browse,
       boxId = null;

  const DispatcherDriversRouteArgs.assignment({
    required this.boxId,
    this.initialView = DispatcherDriverViewMode.byArea,
    this.initialAreaKey,
    this.initialAreaName,
  }) : mode = DispatcherDriversMode.assignment;

  final DispatcherDriversMode mode;
  final String? boxId;
  final DispatcherDriverViewMode initialView;
  final String? initialAreaKey;
  final String? initialAreaName;

  bool get isValid {
    if (mode == DispatcherDriversMode.assignment) {
      if (boxId == null) return false;
      return boxId!.trim().isNotEmpty;
    }
    return true;
  }
}
