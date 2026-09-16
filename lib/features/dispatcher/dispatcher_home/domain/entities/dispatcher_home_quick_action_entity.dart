enum DispatcherHomeQuickActionType {
  assignDriver,
  solveIssues,
  driversMap,
  allDrivers,
}

class DispatcherHomeQuickActionEntity {
  const DispatcherHomeQuickActionEntity({
    required this.type,
    required this.title,
    required this.iconAsset,
  });

  final DispatcherHomeQuickActionType type;
  final String title;
  final String iconAsset;
}
