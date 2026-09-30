import 'package:flutter/foundation.dart';

import 'driver_profile_assignment_entity.dart';
import 'driver_profile_document_entity.dart';
import 'driver_profile_ticket_entity.dart';
import 'driver_profile_vehicle_entity.dart';

class DriverProfileEntity {
  const DriverProfileEntity({
    required this.driverProfileId,
    required this.fullName,
    required this.driverDescription,
    this.driverRank,
    required this.driverCode,
    this.phoneNumber,
    this.profileImageUrl,
    required this.isOnline,
    required this.status,
    required this.statusText,
    this.averageRating,
    required this.reviewsCount,
    required this.totalOrders,
    this.acceptanceRatePercent,
    this.joinedAtUtc,
    this.vehicle,
    this.documents = const [],
    this.assignment,
    this.latestSupportTicket,
  });

  final String driverProfileId;
  final String fullName;
  final String driverDescription;
  final String? driverRank;
  final String driverCode;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isOnline;
  final String status;
  final String statusText;
  final double? averageRating;
  final int reviewsCount;
  final int totalOrders;
  final double? acceptanceRatePercent;
  final DateTime? joinedAtUtc;
  final DriverProfileVehicleEntity? vehicle;
  final List<DriverProfileDocumentEntity> documents;
  final DriverProfileAssignmentEntity? assignment;
  final DriverProfileTicketEntity? latestSupportTicket;

  // Compatibility helpers for transition
  String get name => fullName;
  String get driverId => driverCode;
  double get rating => averageRating ?? 0.0;
  int get acceptanceRate => acceptanceRatePercent?.toInt() ?? 0;
  String get memberSince => joinedAtUtc != null
      ? '${joinedAtUtc!.year}-${joinedAtUtc!.month.toString().padLeft(2, '0')}'
      : '';
  String get vehicleType => vehicle?.vehicleType ?? '';
  String get vehicleModel => vehicle?.vehicleModel ?? '';
  String get plateNumber => vehicle?.plateNumber ?? '';
  bool get isVehicleActive => vehicle?.isVehicleActive ?? false;
  String get recentTicketId => latestSupportTicket?.ticketNumber ?? '';
  String get recentTicketSubject => latestSupportTicket?.subject ?? '';
  String get recentTicketDate => latestSupportTicket?.createdAtUtc != null
      ? '${latestSupportTicket!.createdAtUtc!.year}-${latestSupportTicket!.createdAtUtc!.month.toString().padLeft(2, '0')}-${latestSupportTicket!.createdAtUtc!.day.toString().padLeft(2, '0')}'
      : '';
  bool get isTicketResolved =>
      latestSupportTicket?.status.toLowerCase() == 'resolved';
  String get avatarAsset => 'assets/images/auth/registration_driver_role.png';
  String get appVersion => '2.4.1';
  String get language => 'العربية';

  DriverProfileEntity copyWith({
    String? driverProfileId,
    String? fullName,
    String? driverDescription,
    String? driverRank,
    String? driverCode,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isOnline,
    String? status,
    String? statusText,
    double? averageRating,
    int? reviewsCount,
    int? totalOrders,
    double? acceptanceRatePercent,
    DateTime? joinedAtUtc,
    DriverProfileVehicleEntity? vehicle,
    List<DriverProfileDocumentEntity>? documents,
    DriverProfileAssignmentEntity? assignment,
    DriverProfileTicketEntity? latestSupportTicket,
  }) {
    return DriverProfileEntity(
      driverProfileId: driverProfileId ?? this.driverProfileId,
      fullName: fullName ?? this.fullName,
      driverDescription: driverDescription ?? this.driverDescription,
      driverRank: driverRank ?? this.driverRank,
      driverCode: driverCode ?? this.driverCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isOnline: isOnline ?? this.isOnline,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      averageRating: averageRating ?? this.averageRating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      totalOrders: totalOrders ?? this.totalOrders,
      acceptanceRatePercent:
          acceptanceRatePercent ?? this.acceptanceRatePercent,
      joinedAtUtc: joinedAtUtc ?? this.joinedAtUtc,
      vehicle: vehicle ?? this.vehicle,
      documents: documents ?? this.documents,
      assignment: assignment ?? this.assignment,
      latestSupportTicket: latestSupportTicket ?? this.latestSupportTicket,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverProfileEntity &&
          runtimeType == other.runtimeType &&
          driverProfileId == other.driverProfileId &&
          fullName == other.fullName &&
          driverDescription == other.driverDescription &&
          driverRank == other.driverRank &&
          driverCode == other.driverCode &&
          phoneNumber == other.phoneNumber &&
          profileImageUrl == other.profileImageUrl &&
          isOnline == other.isOnline &&
          status == other.status &&
          statusText == other.statusText &&
          averageRating == other.averageRating &&
          reviewsCount == other.reviewsCount &&
          totalOrders == other.totalOrders &&
          acceptanceRatePercent == other.acceptanceRatePercent &&
          joinedAtUtc == other.joinedAtUtc &&
          vehicle == other.vehicle &&
          listEquals(documents, other.documents) &&
          assignment == other.assignment &&
          latestSupportTicket == other.latestSupportTicket;

  @override
  int get hashCode => Object.hash(
        driverProfileId,
        fullName,
        driverDescription,
        driverRank,
        driverCode,
        phoneNumber,
        profileImageUrl,
        isOnline,
        status,
        statusText,
        averageRating,
        reviewsCount,
        totalOrders,
        acceptanceRatePercent,
        joinedAtUtc,
        vehicle,
        Object.hashAll(documents),
        assignment,
        latestSupportTicket,
      );
}
