//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AssistantApi {
  AssistantApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/v1/assistant/proposals/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [Interpret] interpret (required):
  Future<Response> apiV1AssistantProposalsCreateWithHttpInfo(Interpret interpret,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/assistant/proposals/';

    // ignore: prefer_final_locals
    Object? postBody = interpret;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'application/x-www-form-urlencoded', 'multipart/form-data'];


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
  /// * [Interpret] interpret (required):
  Future<AssistantProposal?> apiV1AssistantProposalsCreate(Interpret interpret,) async {
    final response = await apiV1AssistantProposalsCreateWithHttpInfo(interpret,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AssistantProposal',) as AssistantProposal;
    
    }
    return null;
  }
}
