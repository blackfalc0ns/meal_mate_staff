enum BoxTrackingStatus {
  readyAtRestaurant,
  pickedUpByDriver,
  onTheWay,
  delivered,
  pending,
  cancelled,
  unknown,
}

extension BoxTrackingStatusX on BoxTrackingStatus {
  static BoxTrackingStatus fromApi(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'readyatrestaurant' => BoxTrackingStatus.readyAtRestaurant,
      'pickedupbydriver' => BoxTrackingStatus.pickedUpByDriver,
      'ontheway' || 'indelivery' => BoxTrackingStatus.onTheWay,
      'delivered' => BoxTrackingStatus.delivered,
      'pending' => BoxTrackingStatus.pending,
      'cancelled' => BoxTrackingStatus.cancelled,
      _ => BoxTrackingStatus.unknown,
    };
  }
}
