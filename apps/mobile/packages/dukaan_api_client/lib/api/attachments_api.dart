//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AttachmentsApi {
  AttachmentsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/v1/attachments/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] businessId (required):
  ///
  /// * [String] file (required):
  Future<Response> apiV1AttachmentsCreateWithHttpInfo(String businessId, String file,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/attachments/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['multipart/form-data', 'application/x-www-form-urlencoded'];

    bool hasFields = false;
    final mp = MultipartRequest('POST', Uri.parse(path));
    if (businessId != null) {
      hasFields = true;
      mp.fields[r'business_id'] = parameterToString(businessId);
    }
    if (file != null) {
      hasFields = true;
      mp.fields[r'file'] = parameterToString(file);
    }
    if (hasFields) {
      postBody = mp;
    }

    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] businessId (required):
  ///
  /// * [String] file (required):
  Future<Attachment?> apiV1AttachmentsCreate(String businessId, String file,) async {
    final response = await apiV1AttachmentsCreateWithHttpInfo(businessId, file,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Attachment',) as Attachment;
    
    }
    return null;
  }

  /// Get-or-create the invoice PDF for a posted sale (idempotent).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> apiV1SalesInvoiceCreateWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/sales/{id}/invoice/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get-or-create the invoice PDF for a posted sale (idempotent).
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Attachment?> apiV1SalesInvoiceCreate(String id,) async {
    final response = await apiV1SalesInvoiceCreateWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Attachment',) as Attachment;
    
    }
    return null;
  }
}
