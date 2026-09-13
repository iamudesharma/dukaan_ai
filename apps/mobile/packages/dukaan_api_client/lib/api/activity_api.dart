//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ActivityApi {
  ActivityApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Newest-first audit feed over append-only AuditEvent.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] businessId (required):
  ///
  /// * [String] kind:
  ///
  /// * [String] locationId:
  Future<Response> apiV1ActivityRetrieveWithHttpInfo(String businessId, { String? kind, String? locationId, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/activity/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'business_id', businessId));
    if (kind != null) {
      queryParams.addAll(_queryParams('', 'kind', kind));
    }
    if (locationId != null) {
      queryParams.addAll(_queryParams('', 'location_id', locationId));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Newest-first audit feed over append-only AuditEvent.
  ///
  /// Parameters:
  ///
  /// * [String] businessId (required):
  ///
  /// * [String] kind:
  ///
  /// * [String] locationId:
  Future<void> apiV1ActivityRetrieve(String businessId, { String? kind, String? locationId, }) async {
    final response = await apiV1ActivityRetrieveWithHttpInfo(businessId,  kind: kind, locationId: locationId, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
