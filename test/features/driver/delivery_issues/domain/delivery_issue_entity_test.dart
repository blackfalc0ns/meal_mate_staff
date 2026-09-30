import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/delivery_issue_reason.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/fake_data/delivery_issues_fake_data.dart';

void main() {
  group('DeliveryIssueEntity & FakeData', () {
    test('instantiates with default values and supports copyWith', () {
      const defaultEntity = DeliveryIssuesFakeData.defaultIssue;

      expect(defaultEntity.boxCode, '#BX-1257');
      expect(defaultEntity.customerName, 'أحمد إبراهيم');
      expect(defaultEntity.restaurantName, 'مطعم MealMate الكويت');
      expect(defaultEntity.area, 'منطقة حولي');
      expect(defaultEntity.status, 'في الطريق للعميل');
      expect(defaultEntity.mealsCountText, '1 من 1 وجبة');
      expect(defaultEntity.selectedReason, DeliveryIssueReason.customerNoAnswer);

      final updated = defaultEntity.copyWith(
        selectedReason: DeliveryIssueReason.boxDamaged,
        notes: 'الكرتون ممزق',
      );
      expect(updated.selectedReason, DeliveryIssueReason.boxDamaged);
      expect(updated.notes, 'الكرتون ممزق');
    });
  });
}
