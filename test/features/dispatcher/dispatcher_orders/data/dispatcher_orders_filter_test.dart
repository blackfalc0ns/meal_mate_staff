import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/data/data_source/dispatcher_orders_remote_data_source_impl.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_filter_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_order_status.dart';

void main() {
  group('DispatcherFilterType mapping', () {
    test('maps all filter types to exact backend wire values', () {
      expect(DispatcherFilterType.all.toWireValue(), 'All');
      expect(DispatcherFilterType.pendingAssignment.toWireValue(), 'Pending');
      expect(DispatcherFilterType.assigned.toWireValue(), 'Assigned');
      expect(DispatcherFilterType.inDelivery.toWireValue(), 'InDelivery');
      expect(DispatcherFilterType.problems.toWireValue(), 'Issues');
    });

    test(
      'confirms intentional difference between filter wire value (Issues) and box status (Issue)',
      () {
        final filterWire = DispatcherFilterType.problems.toWireValue();
        expect(filterWire, 'Issues');

        final boxStatus = DispatcherOrderStatus.fromWire('Issue');
        expect(boxStatus, DispatcherOrderStatus.issue);

        // Status from wire 'Issues' would be unknown if not handled as filter
        expect(filterWire, isNot(equals('Issue')));
      },
    );
  });
}
