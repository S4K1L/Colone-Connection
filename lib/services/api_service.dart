import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_extension/model/multi_body.dart';
import 'package:flutter_extension/util/app_constants.dart';
import 'package:flutter_extension/util/api_constant.dart';
import 'package:flutter_extension/views/base/custom_snackbar.dart';
import 'package:get/get.dart' as g;
import 'package:mime/mime.dart';

import 'shared_prefs_service.dart';
import 'package:flutter_extension/helper/route_helper.dart';

class ApiService {
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstant.BASE_URL,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: <String, dynamic>{
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        validateStatus: (int? statusCode) =>
            statusCode != null && statusCode >= 200 && statusCode < 300,
      ),
    );
    _configureInterceptors();
  }

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  static const String imgUrl = ApiConstant.IMAGE_URL;
  static const bool showAPICalls = true;
  static const String _refreshTokenKey = 'refresh_token';
  static const int _maxRetryCount = 2;
  static const String _retryCountExtraKey = 'retry_count';
  static const String _hasRetriedAfterRefreshExtraKey = 'retried_after_refresh';

  late final Dio _dio;
  late final Dio _refreshDio;
  int _callCount = 0;
  bool _isRefreshingToken = false;
  Future<String?>? _refreshFuture;

  void _initializeRefreshClient() {
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstant.BASE_URL,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: <String, dynamic>{
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        validateStatus: (int? statusCode) =>
            statusCode != null && statusCode >= 200 && statusCode < 300,
      ),
    );
  }

  void _configureInterceptors() {
    _initializeRefreshClient();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (RequestOptions options, RequestInterceptorHandler handler) async {
              final bool authReq = options.extra['authReq'] == true;
              if (authReq) {
                final String? token = await SharedPrefsService.get(
                  AppConstants.TOKEN,
                );
                if (token != null && token.isNotEmpty) {
                  options.headers[HttpHeaders.authorizationHeader] =
                      'Bearer $token';
                }
              }
              if (showAPICalls) {
                _callCount++;
                debugPrint('🆔 $_callCount');
                debugPrint('➡️ [${options.method}] ${options.uri}');
                debugPrint('📨 Headers: ${_pretty(options.headers)}');
                if (options.queryParameters.isNotEmpty) {
                  debugPrint('🔎 Query: ${_pretty(options.queryParameters)}');
                }
                if (options.data != null) {
                  debugPrint('📤 Request Body: ${_pretty(options.data)}');
                }
              }
              handler.next(options);
            },
        onResponse:
            (Response<dynamic> response, ResponseInterceptorHandler handler) {
              if (showAPICalls) {
                debugPrint(
                  '⬅️ [${response.requestOptions.method}] ${response.requestOptions.uri}',
                );
                debugPrint('✅ Status Code: ${response.statusCode}');
                debugPrint('📦 Response Body: ${_pretty(response.data)}');
              }
              handler.next(response);
            },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final RequestOptions req = error.requestOptions;
          final int? statusCode = error.response?.statusCode;
          debugPrint('❗ [${req.method}] ${req.uri}');
          debugPrint('❗ Status Code: $statusCode');
          debugPrint('❗ Error: ${error.message}');
          if (error.response?.data != null) {
            debugPrint('❗ Error Body: ${_pretty(error.response?.data)}');
          }

          final bool authReq = req.extra['authReq'] == true;
          if (authReq && statusCode == 401) {
            final bool hasRetried =
                req.extra[_hasRetriedAfterRefreshExtraKey] == true;
            if (!hasRetried) {
              final Response<dynamic>? retried = await _retryAfterTokenRefresh(
                req,
              );
              if (retried != null) {
                handler.resolve(retried);
                return;
              }
            }
            _checkTokenExpiry(authReq, error.response);
          }

          if (_shouldRetryError(error) && _canRetry(req)) {
            final Response<dynamic>? retried = await _retryRequest(
              req,
              retryReason: error.type.name,
            );
            if (retried != null) {
              handler.resolve(retried);
              return;
            }
          }

          _showLaterRetrySnackbar();

          handler.reject(
            DioException(
              requestOptions: req,
              response: error.response,
              type: error.type,
              error: ApiException.fromDioException(error),
              message: error.message,
            ),
          );
        },
      ),
    );
  }

  void _showLaterRetrySnackbar() {
    if (!g.Get.isSnackbarOpen) {
      showCustomSnackBar('Please try again later.', getXSnackBar: true);
    }
  }

  bool _shouldRetryError(DioException error) {
    final int? statusCode = error.response?.statusCode;
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.type == DioExceptionType.badResponse &&
            statusCode != null &&
            statusCode >= 500) ||
        error.type == DioExceptionType.unknown;
  }

  bool _canRetry(RequestOptions requestOptions) {
    final int retryCount =
        (requestOptions.extra[_retryCountExtraKey] as int?) ?? 0;
    return retryCount < _maxRetryCount;
  }

  Future<Response<dynamic>?> _retryRequest(
    RequestOptions requestOptions, {
    required String retryReason,
  }) async {
    if (!_canRetry(requestOptions)) return null;

    final int retryCount =
        (requestOptions.extra[_retryCountExtraKey] as int?) ?? 0;
    final int nextRetryCount = retryCount + 1;

    await Future<void>.delayed(Duration(milliseconds: 300 * nextRetryCount));

    final Options retryOptions = Options(
      method: requestOptions.method,
      headers: Map<String, dynamic>.from(requestOptions.headers),
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      followRedirects: requestOptions.followRedirects,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      validateStatus: requestOptions.validateStatus,
      sendTimeout: requestOptions.sendTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
      extra: <String, dynamic>{
        ...requestOptions.extra,
        _retryCountExtraKey: nextRetryCount,
      },
    );

    if (showAPICalls) {
      debugPrint(
        '🔁 Retrying (${nextRetryCount}/$_maxRetryCount) because $retryReason',
      );
    }

    try {
      return await _dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: retryOptions,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Response<dynamic>?> _retryAfterTokenRefresh(
    RequestOptions requestOptions,
  ) async {
    final String? freshAccessToken = await _refreshAccessToken();
    if (freshAccessToken == null || freshAccessToken.isEmpty) {
      return null;
    }

    final Map<String, dynamic> headers = Map<String, dynamic>.from(
      requestOptions.headers,
    );
    headers[HttpHeaders.authorizationHeader] = 'Bearer $freshAccessToken';

    final Options retryOptions = Options(
      method: requestOptions.method,
      headers: headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      followRedirects: requestOptions.followRedirects,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      validateStatus: requestOptions.validateStatus,
      sendTimeout: requestOptions.sendTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
      extra: <String, dynamic>{
        ...requestOptions.extra,
        _hasRetriedAfterRefreshExtraKey: true,
      },
    );

    try {
      return await _dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: retryOptions,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> _refreshAccessToken() async {
    if (_isRefreshingToken && _refreshFuture != null) {
      return _refreshFuture;
    }
    _isRefreshingToken = true;

    _refreshFuture = () async {
      try {
        final String? refreshToken = await SharedPrefsService.get(
          _refreshTokenKey,
        );
        if (refreshToken == null || refreshToken.isEmpty) return null;

        final Response<dynamic> response = await _refreshDio.post<dynamic>(
          ApiConstant.REFRESH_TOKEN,
          data: <String, dynamic>{'refreshToken': refreshToken},
        );

        if ((response.statusCode ?? 0) < 200 ||
            (response.statusCode ?? 0) >= 300) {
          return null;
        }

        final dynamic data = response.data;
        String? accessToken;
        String? nextRefreshToken;
        if (data is Map) {
          accessToken =
              (data['accessToken'] ?? data['token'] ?? data['access_token'])
                  as String?;
          nextRefreshToken =
              (data['refreshToken'] ?? data['refresh_token']) as String?;
        }

        if (accessToken == null || accessToken.isEmpty) return null;

        await SharedPrefsService.set(AppConstants.TOKEN, accessToken);
        if (nextRefreshToken != null && nextRefreshToken.isNotEmpty) {
          await SharedPrefsService.set(_refreshTokenKey, nextRefreshToken);
        }
        return accessToken;
      } catch (_) {
        return null;
      } finally {
        _isRefreshingToken = false;
      }
    }();

    return _refreshFuture;
  }

  Options _options({
    bool authReq = false,
    bool isMultipart = false,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
  }) {
    final Map<String, dynamic> mergedHeaders = <String, dynamic>{
      HttpHeaders.acceptHeader: 'application/json',
      if (!isMultipart) HttpHeaders.contentTypeHeader: 'application/json',
      ...?headers,
    };
    return Options(
      headers: mergedHeaders,
      extra: <String, dynamic>{'authReq': authReq, ...?extra},
    );
  }

  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool authReq = false,
    CancelToken? cancelToken,
  }) {
    return _dio.get<dynamic>(
      endpoint,
      queryParameters: queryParams,
      options: _options(authReq: authReq),
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool isMultiPart = false,
    bool authReq = false,
    CancelToken? cancelToken,
  }) async {
    if (isMultiPart) {
      final FormData formData = await _buildFormDataFromMap(data);
      return _dio.post<dynamic>(
        endpoint,
        data: formData,
        options: _options(authReq: authReq, isMultipart: true),
        cancelToken: cancelToken,
      );
    }
    return _dio.post<dynamic>(
      endpoint,
      data: data,
      options: _options(authReq: authReq),
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> postRaw(
    String endpoint,
    dynamic data, {
    bool authReq = false,
    CancelToken? cancelToken,
  }) {
    return _dio.post<dynamic>(
      endpoint,
      data: data,
      options: _options(authReq: authReq),
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool authReq = false,
    CancelToken? cancelToken,
  }) {
    return _dio.put<dynamic>(
      endpoint,
      data: data,
      options: _options(authReq: authReq),
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data, {
    bool authReq = false,
    CancelToken? cancelToken,
  }) async {
    final bool hasFile = data.values.any((dynamic value) => value is File);
    if (hasFile) {
      final FormData formData = await _buildFormDataFromMap(data);
      return _dio.patch<dynamic>(
        endpoint,
        data: formData,
        options: _options(authReq: authReq, isMultipart: true),
        cancelToken: cancelToken,
      );
    }
    return _dio.patch<dynamic>(
      endpoint,
      data: data,
      options: _options(authReq: authReq),
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    bool authReq = false,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<dynamic>(
      endpoint,
      data: data,
      queryParameters: queryParams,
      options: _options(authReq: authReq),
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> head(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool authReq = false,
  }) {
    return _dio.head<dynamic>(
      endpoint,
      queryParameters: queryParams,
      options: _options(authReq: authReq),
    );
  }

  Future<Response<dynamic>> optionsRequest(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool authReq = false,
  }) {
    return _dio.request<dynamic>(
      endpoint,
      queryParameters: queryParams,
      options: _options(authReq: authReq).copyWith(method: 'OPTIONS'),
    );
  }

  Future<Response<dynamic>> patchMultipartData(
    String endpoint,
    Map<String, dynamic> body, {
    required List<MultipartBody> multipartBody,
    bool authReq = false,
    ValueChanged<double>? onProgress,
    CancelToken? cancelToken,
  }) async {
    final FormData formData = await _buildFormData(body, multipartBody);
    return _dio.patch<dynamic>(
      endpoint,
      data: formData,
      options: _options(authReq: authReq, isMultipart: true),
      cancelToken: cancelToken,
      onSendProgress: onProgress == null
          ? null
          : (int sent, int total) {
              if (total <= 0) return;
              onProgress((sent / total).clamp(0.0, 1.0));
            },
    );
  }

  Future<Response<dynamic>> postMultipartData(
    String endpoint,
    Map<String, dynamic> body, {
    required List<MultipartBody> multipartBody,
    bool authReq = false,
    ValueChanged<double>? onProgress,
    CancelToken? cancelToken,
  }) async {
    final FormData formData = await _buildFormData(body, multipartBody);
    return _dio.post<dynamic>(
      endpoint,
      data: formData,
      options: _options(authReq: authReq, isMultipart: true),
      cancelToken: cancelToken,
      onSendProgress: onProgress == null
          ? null
          : (int sent, int total) {
              if (total <= 0) return;
              onProgress((sent / total).clamp(0.0, 1.0));
            },
    );
  }

  Future<void> setToken(String token) async {
    await SharedPrefsService.set(AppConstants.TOKEN, token);
    debugPrint('💾 Token Saved');
  }

  Future<void> setRefreshToken(String refreshToken) async {
    await SharedPrefsService.set(_refreshTokenKey, refreshToken);
    debugPrint('💾 Refresh Token Saved');
  }

  static String? getImgUrl(String? img) {
    if (img == null || img.isEmpty) return null;
    return imgUrl + img;
  }

  Future<FormData> _buildFormDataFromMap(Map<String, dynamic> data) async {
    final FormData formData = FormData();
    for (final MapEntry<String, dynamic> entry in data.entries) {
      final dynamic value = entry.value;
      if (value == null) continue;
      if (value is File) {
        formData.files.add(
          MapEntry<String, MultipartFile>(
            entry.key,
            await MultipartFile.fromFile(
              value.path,
              contentType: _getDioMediaType(lookupMimeType(value.path)),
              filename: value.uri.pathSegments.isEmpty
                  ? '${entry.key}.bin'
                  : value.uri.pathSegments.last,
            ),
          ),
        );
      } else if (value is List || value is Map) {
        formData.fields.add(
          MapEntry<String, String>(entry.key, jsonEncode(value)),
        );
      } else {
        formData.fields.add(
          MapEntry<String, String>(entry.key, value.toString()),
        );
      }
    }
    return formData;
  }

  Future<FormData> _buildFormData(
    Map<String, dynamic> body,
    List<MultipartBody> multipartBody,
  ) async {
    final FormData formData = FormData();

    body.forEach((String key, dynamic value) {
      if (value == null) return;
      if (value is Map || value is List) {
        formData.fields.add(MapEntry<String, String>(key, jsonEncode(value)));
      } else {
        formData.fields.add(MapEntry<String, String>(key, value.toString()));
      }
    });

    for (final MultipartBody element in multipartBody) {
      if (await element.file.exists()) {
        formData.files.add(
          MapEntry<String, MultipartFile>(
            element.key,
            await MultipartFile.fromFile(
              element.file.path,
              contentType: _getDioMediaType(lookupMimeType(element.file.path)),
              filename: element.file.uri.pathSegments.isEmpty
                  ? 'upload.bin'
                  : element.file.uri.pathSegments.last,
            ),
          ),
        );
      }

      if (element.thumbnail != null && await element.thumbnail!.exists()) {
        final File thumbnailFile = element.thumbnail!;
        formData.files.add(
          MapEntry<String, MultipartFile>(
            'thumbnail',
            await MultipartFile.fromFile(
              thumbnailFile.path,
              contentType: _getDioMediaType(lookupMimeType(thumbnailFile.path)),
              filename: thumbnailFile.uri.pathSegments.isEmpty
                  ? 'thumbnail.bin'
                  : thumbnailFile.uri.pathSegments.last,
            ),
          ),
        );
      }
    }
    return formData;
  }

  DioMediaType _getDioMediaType(String? mimeType) {
    if (mimeType != null && mimeType.contains('/')) {
      final List<String> parts = mimeType.split('/');
      if (parts.length == 2) {
        return DioMediaType(parts[0], parts[1]);
      }
    }
    return DioMediaType('application', 'octet-stream');
  }

  String _pretty(dynamic value) {
    try {
      if (value is String) {
        final dynamic decoded = jsonDecode(value);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
      if (value is Map || value is List) {
        return const JsonEncoder.withIndent('  ').convert(value);
      }
      return value.toString();
    } catch (_) {
      return value.toString();
    }
  }

  void _checkTokenExpiry(bool authReq, Response<dynamic>? response) async {
    if (!authReq || response?.statusCode != 401) return;
    debugPrint('⚠️ Session expired (401). Performing logout.');

    // Clear session data
    await SharedPrefsService.remove(AppConstants.TOKEN);

    // Redirect to login screen
    g.Get.offAllNamed(AppRoutes.loginScreen);

    // Show notification
    showCustomSnackBar(
      'Session expired. Please log in again.',
      isError: true,
      getXSnackBar: true,
    );
  }
}

class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.rawError,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Object? rawError;

  factory ApiException.fromDioException(DioException error) {
    final int? statusCode = error.response?.statusCode;
    final dynamic responseData = error.response?.data;
    String? code;
    String message = 'Unexpected network error occurred.';

    if (responseData is Map) {
      code = responseData['code']?.toString();
      message =
          (responseData['message'] ??
                  responseData['error'] ??
                  responseData['detail'] ??
                  message)
              .toString();
    } else if (responseData is String && responseData.isNotEmpty) {
      message = responseData;
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          message = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.sendTimeout:
          message = 'Request timeout while sending data.';
          break;
        case DioExceptionType.receiveTimeout:
          message = 'Server took too long to respond.';
          break;
        case DioExceptionType.connectionError:
          message = 'No internet connection.';
          break;
        case DioExceptionType.cancel:
          message = 'Request was cancelled.';
          break;
        default:
          message = error.message ?? message;
      }
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      code: code,
      rawError: error.error,
    );
  }

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message, code: $code)';
}
