import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/account_status/data/mapper/account_status_mapper.dart';
import 'package:meal_mate_delivery/features/account_status/data/models/response/driver_registration_status_response_dto.dart';
import 'package:meal_mate_delivery/features/account_status/domain/account_status_kind.dart';

void main() {
  group('Account Status DTO and Mapper Tests', () {
    test('DriverRegistrationStatusResponseDto parses JSON defensively', () {
      final json = {
        'registrationId': '409286c5-c30f-4f95-b505-38054f0f1285',
        'status': 'NeedsChanges',
        'stage': 2,
        'badge': 'تعديل البيانات',
        'title': 'مطلوب تعديل البيانات',
        'subtitle': 'يرجى تعديل البيانات التالية وإعادة إرسال الطلب.',
        'changeRequestNotes': 'صورة رخصة القيادة غير واضحة',
        'canResubmit': true,
        'isApproved': false,
      };

      final dto = DriverRegistrationStatusResponseDto.fromJson(json);
      expect(dto.registrationId, '409286c5-c30f-4f95-b505-38054f0f1285');
      expect(dto.status, 'NeedsChanges');
      expect(dto.stage, 2);
      expect(dto.canResubmit, isTrue);
      expect(dto.isApproved, isFalse);

      final emptyDto = DriverRegistrationStatusResponseDto.fromJson({});
      expect(emptyDto.registrationId, isNull);
      expect(emptyDto.status, isNull);
    });

    test(
      'Mapper correctly maps all 4 backend statuses to AccountStatusKind',
      () {
        // 1. Submitted -> underReview
        const submittedDto = DriverRegistrationStatusResponseDto(
          status: 'Submitted',
          registrationId: 'r-1',
        );
        final submittedEntity = submittedDto.toEntity();
        expect(submittedEntity.kind, AccountStatusKind.underReview);
        expect(submittedEntity.registrationId, 'r-1');

        // 2. NeedsChanges -> moreInformationRequired
        const needsChangesDto = DriverRegistrationStatusResponseDto(
          status: 'NeedsChanges',
          changeRequestNotes: 'Upload new driving license',
        );
        final needsChangesEntity = needsChangesDto.toEntity();
        expect(
          needsChangesEntity.kind,
          AccountStatusKind.moreInformationRequired,
        );
        expect(
          needsChangesEntity.changeRequestNotes,
          'Upload new driving license',
        );

        // 3. Rejected -> rejected
        const rejectedDto = DriverRegistrationStatusResponseDto(
          status: 'Rejected',
          rejectionReason: 'Civil ID invalid',
        );
        final rejectedEntity = rejectedDto.toEntity();
        expect(rejectedEntity.kind, AccountStatusKind.rejected);
        expect(rejectedEntity.rejectionReason, 'Civil ID invalid');

        // 4. Approved -> accepted
        const approvedDto = DriverRegistrationStatusResponseDto(
          status: 'Approved',
          isApproved: true,
        );
        final approvedEntity = approvedDto.toEntity();
        expect(approvedEntity.kind, AccountStatusKind.accepted);
        expect(approvedEntity.isApproved, isTrue);
      },
    );

    test(
      'Mapper handles unexpected or null status gracefully with fallback',
      () {
        const unknownDto = DriverRegistrationStatusResponseDto();
        final entity = unknownDto.toEntity();
        expect(entity.kind, AccountStatusKind.underReview);
        expect(entity.registrationId, '');
        expect(entity.canResubmit, isFalse);
      },
    );

    test('parses fullNameAr, fullNameEn, requestedByRole and accountStatus alias', () {
      final json = {
        'accountStatus': 'NeedsChanges',
        'fullNameAr': 'أحمد محمد',
        'fullNameEn': 'Ahmed Mohamed',
        'requestedByRole': 'IndependentDriver',
        'restaurantApprovalStatus': 'Approved',
        'adminApprovalStatus': 'Pending',
      };

      final dto = DriverRegistrationStatusResponseDto.fromJson(json);
      expect(dto.status, 'NeedsChanges');
      expect(dto.fullNameAr, 'أحمد محمد');
      expect(dto.fullNameEn, 'Ahmed Mohamed');
      expect(dto.requestedByRole, 'IndependentDriver');
      expect(dto.restaurantApprovalStatus, 'Approved');
      expect(dto.adminApprovalStatus, 'Pending');

      final entity = dto.toEntity();
      expect(entity.kind, AccountStatusKind.moreInformationRequired);
      expect(entity.fullName, 'أحمد محمد');
      expect(entity.requestedByRole, 'IndependentDriver');
    });

    test('mapper name fallback uses fullName first, then fullNameAr, then fullNameEn', () {
      const dtoWithBoth = DriverRegistrationStatusResponseDto(
        fullName: 'Full Name Explicit',
        fullNameAr: 'الاسم بالعربي',
        fullNameEn: 'English Name',
      );
      expect(dtoWithBoth.toEntity().fullName, 'Full Name Explicit');

      const dtoWithArOnly = DriverRegistrationStatusResponseDto(
        fullNameAr: 'الاسم بالعربي',
        fullNameEn: 'English Name',
      );
      expect(dtoWithArOnly.toEntity().fullName, 'الاسم بالعربي');

      const dtoWithEnOnly = DriverRegistrationStatusResponseDto(
        fullNameEn: 'English Name',
      );
      expect(dtoWithEnOnly.toEntity().fullName, 'English Name');
    });

    test('conservative resubmit guard: Rejected and Approved always force canResubmit to false', () {
      // Backend bug: backend reports canResubmit: true on Rejected, but POST returns 409
      const rejectedDto = DriverRegistrationStatusResponseDto(
        status: 'Rejected',
        canResubmit: true,
      );
      final rejectedEntity = rejectedDto.toEntity();
      expect(rejectedEntity.kind, AccountStatusKind.rejected);
      expect(rejectedEntity.canResubmit, isFalse,
          reason: 'Client-side guard must reject resubmission for Rejected status');

      // Approved status also cannot be resubmitted
      const approvedDto = DriverRegistrationStatusResponseDto(
        status: 'Approved',
        canResubmit: true,
      );
      final approvedEntity = approvedDto.toEntity();
      expect(approvedEntity.kind, AccountStatusKind.accepted);
      expect(approvedEntity.canResubmit, isFalse);

      // NeedsChanges retains canResubmit: true
      const needsChangesDto = DriverRegistrationStatusResponseDto(
        status: 'NeedsChanges',
        canResubmit: true,
      );
      final needsChangesEntity = needsChangesDto.toEntity();
      expect(needsChangesEntity.kind, AccountStatusKind.moreInformationRequired);
      expect(needsChangesEntity.canResubmit, isTrue);
    });
  });
}
