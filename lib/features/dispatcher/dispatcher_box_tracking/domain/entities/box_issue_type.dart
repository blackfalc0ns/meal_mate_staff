enum BoxIssueType {
  damagedBox,
  delayedDelivery,
  wrongAddress,
  customerUnreachable,
  other,
  unknown,
}

extension BoxIssueTypeX on BoxIssueType {
  static BoxIssueType fromApi(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'damagedbox' => BoxIssueType.damagedBox,
      'delayeddelivery' => BoxIssueType.delayedDelivery,
      'wrongaddress' => BoxIssueType.wrongAddress,
      'customerunreachable' => BoxIssueType.customerUnreachable,
      'other' => BoxIssueType.other,
      _ => BoxIssueType.other,
    };
  }

  String toApi() {
    return switch (this) {
      BoxIssueType.damagedBox => 'DamagedBox',
      BoxIssueType.delayedDelivery => 'DelayedDelivery',
      BoxIssueType.wrongAddress => 'WrongAddress',
      BoxIssueType.customerUnreachable => 'CustomerUnreachable',
      BoxIssueType.other || BoxIssueType.unknown => 'Other',
    };
  }
}
