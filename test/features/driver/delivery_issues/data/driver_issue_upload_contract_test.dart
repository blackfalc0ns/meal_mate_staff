import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/data/data_source/driver_issue_remote_data_source_impl.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/data/repo/driver_issue_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/delivery_issue_reason.dart';

void main() {
  for (final response in [
    {'url': 'https://example.test/image.jpg'},
    {'fileUrl': 'https://example.test/image.jpg'},
    {'storageKey': ''},
    {'storageKey': '   '},
    {'storageKey': '/data/user/0/com.mealmate/cache/photo.jpg'},
    {'storageKey': 'assets/images/photo.png'},
  ]) {
    test(
      'rejects upload without a valid storage key: ${response.keys}',
      () async {
        final directory = Directory.systemTemp.createTempSync(
          'invalid-issue-upload-',
        );
        final file = File('${directory.path}/evidence.jpg')
          ..writeAsBytesSync([1]);
        final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
        addTearDown(() {
          dio.close();
          directory.deleteSync(recursive: true);
        });
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 201,
                  data: response,
                ),
              );
            },
          ),
        );
        final repo = DriverIssueRepositoryImpl(
          DriverIssueRemoteDataSourceImpl(ApiServices(dio)),
        );
        final result = await repo.uploadEvidence(file);
        expect(result, isA<ApiErrorResult<String>>());
        expect(
          (result as ApiErrorResult<String>).failure.exception.backendErrorCode,
          'ISSUE_UPLOAD_STORAGE_KEY_INVALID',
        );
      },
    );
  }

  for (final successCase in [
    {
      'name': 'full ImageKit HTTPS URL',
      'expected': 'https://cdn.example.com/account/uploads/drivers/issue-evidence/evidence.jpg',
      'data': {'storageKey': 'https://cdn.example.com/account/uploads/drivers/issue-evidence/evidence.jpg'},
    },
    {
      'name': 'relative storage path',
      'expected': 'uploads/drivers/issue-evidence/image.jpg',
      'data': {'storageKey': 'uploads/drivers/issue-evidence/image.jpg'},
    },
    {
      'name': 'relative storage path with leading slash',
      'expected': '/uploads/drivers/issue-evidence/image.jpg',
      'data': {'storageKey': '/uploads/drivers/issue-evidence/image.jpg'},
    },
    {
      'name': 'nested data with ImageKit HTTPS URL',
      'expected': 'https://cdn.example.com/account/uploads/drivers/issue-evidence/evidence.jpg',
      'data': {'data': {'storageKey': 'https://cdn.example.com/account/uploads/drivers/issue-evidence/evidence.jpg'}},
    },
    {
      'name': 'nested data with relative path',
      'expected': 'uploads/drivers/issue-evidence/image.jpg',
      'data': {'data': {'storageKey': 'uploads/drivers/issue-evidence/image.jpg'}},
    },
    {
      'name': 'nested data string',
      'expected': 'uploads/drivers/issue-evidence/image.jpg',
      'data': {'data': 'uploads/drivers/issue-evidence/image.jpg'},
    },
    {
      'name': 'alternative key name',
      'expected': 'uploads/drivers/issue-evidence/image.jpg',
      'data': {'data': {'key': 'uploads/drivers/issue-evidence/image.jpg'}},
    },
  ]) {
    test(
      'accepts and preserves upload response: ${successCase['name']}',
      () async {
        final directory = Directory.systemTemp.createTempSync(
          'valid-issue-upload-',
        );
        final file = File('${directory.path}/evidence.jpg')
          ..writeAsBytesSync([1]);
        final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
        addTearDown(() {
          dio.close();
          directory.deleteSync(recursive: true);
        });
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 201,
                  data: successCase['data'],
                ),
              );
            },
          ),
        );
        final repo = DriverIssueRepositoryImpl(
          DriverIssueRemoteDataSourceImpl(ApiServices(dio)),
        );
        final result = await repo.uploadEvidence(file);
        expect(result, isA<ApiSuccessResult<String>>());
        expect(
          (result as ApiSuccessResult<String>).data,
          successCase['expected'],
        );
      },
    );
  }

  test(
    'invalid local device photo key blocks report instead of silently dropping evidence',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      addTearDown(dio.close);
      var requests = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests++;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: 'issue-id',
              ),
            );
          },
        ),
      );
      final repo = DriverIssueRepositoryImpl(
        DriverIssueRemoteDataSourceImpl(ApiServices(dio)),
      );
      final result = await repo.reportIssue(
        boxId: 'stop-id',
        reason: DeliveryIssueReason.damagedBox,
        photoStorageKeys: ['/data/user/0/com.mealmate/cache/photo.jpg'],
      );
      expect(result, isA<ApiErrorResult<String>>());
      expect(requests, 0);
    },
  );

  test(
    'valid ImageKit HTTPS photo key is accepted and passed in report',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      addTearDown(dio.close);
      Map<String, dynamic>? report;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            report = options.data as Map<String, dynamic>;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: 'issue-id',
              ),
            );
          },
        ),
      );
      final repo = DriverIssueRepositoryImpl(
        DriverIssueRemoteDataSourceImpl(ApiServices(dio)),
      );
      const httpsKey =
          'https://cdn.example.com/account/uploads/drivers/issue-evidence/evidence.jpg';
      final result = await repo.reportIssue(
        boxId: 'stop-id',
        reason: DeliveryIssueReason.damagedBox,
        photoStorageKeys: [httpsKey],
      );
      expect(result, isA<ApiSuccessResult<String>>());
      expect(report!['evidencePhotoStorageKeys'], [httpsKey]);
    },
  );

  for (final format in {
    'jpg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  }.entries) {
    test(
      'uploads ${format.key} to evidence folder and sends returned key with report',
      () async {
        final directory = Directory.systemTemp.createTempSync(
          'issue-upload-contract-',
        );
        final file = File('${directory.path}/evidence.${format.key}')
          ..writeAsBytesSync([1, 2, 3]);
        final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
        addTearDown(() {
          dio.close();
          directory.deleteSync(recursive: true);
        });
        FormData? upload;
        Map<String, dynamic>? report;
        const key = 'uploads/drivers/issue-evidence/server-key.jpg';
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path == '/api/v1/uploads') {
                upload = options.data as FormData;
                handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 201,
                    data: {'storageKey': key},
                  ),
                );
              } else {
                report = options.data as Map<String, dynamic>;
                handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: 'issue-id',
                  ),
                );
              }
            },
          ),
        );
        final repo = DriverIssueRepositoryImpl(
          DriverIssueRemoteDataSourceImpl(ApiServices(dio)),
        );
        final result = await repo.uploadEvidence(file);
        expect(result, isA<ApiSuccessResult<String>>());
        final fields = Map.fromEntries(upload!.fields);
        expect(fields['scope'], 'drivers');
        expect(fields['folder'], 'issue-evidence');
        expect(upload!.files.single.key, 'file');
        expect(upload!.files.single.value.contentType.toString(), format.value);
        final uploadedKey = (result as ApiSuccessResult<String>).data;
        await repo.reportIssue(
          boxId: 'stop-id',
          reason: DeliveryIssueReason.damagedBox,
          photoStorageKeys: [uploadedKey],
        );
        expect(report!['evidencePhotoStorageKeys'], [key]);
      },
    );
  }
}
