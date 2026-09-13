//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class SearchApi {
  SearchApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Scoped global search over parties, products, and documents.  Cashiers see sales, customers, and products only — supplier and purchase rows stay manager-visible, mirroring the report gating.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] businessId (required):
  ///
  /// * [String] q (required):
  ///
  /// * [String] types:
  Future<Response> apiV1SearchRetrieveWithHttpInfo(String businessId, String q, { String? types, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/search/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'business_id', businessId));
      queryParams.addAll(_queryParams('', 'q', q));
    if (types != null) {
      queryParams.addAll(_queryParams('', 'types', types));
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

  /// Scoped global search over parties, products, and documents.  Cashiers see sales, customers, and products only — supplier and purchase rows stay manager-visible, mirroring the report gating.
  ///
  /// Parameters:
  ///
  /// * [String] businessId (required):
  ///
  /// * [String] q (required):
  ///
  /// * [String] types:
  Future<void> apiV1SearchRetrieve(String businessId, String q, { String? types, }) async {
    final response = await apiV1SearchRetrieveWithHttpInfo(businessId, q,  types: types, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
