//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ApiApi {
  ApiApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/v1/assistant/proposals/{id}/cancel/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [AssistantProposal] assistantProposal:
  Future<Response> apiV1AssistantProposalsCancelCreateWithHttpInfo(String id, { AssistantProposal? assistantProposal, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/assistant/proposals/{id}/cancel/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = assistantProposal;

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
  /// * [String] id (required):
  ///
  /// * [AssistantProposal] assistantProposal:
  Future<AssistantProposal?> apiV1AssistantProposalsCancelCreate(String id, { AssistantProposal? assistantProposal, }) async {
    final response = await apiV1AssistantProposalsCancelCreateWithHttpInfo(id,  assistantProposal: assistantProposal, );
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

  /// Performs an HTTP 'POST /api/v1/assistant/proposals/{id}/confirm/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [AssistantProposal] assistantProposal:
  Future<Response> apiV1AssistantProposalsConfirmCreateWithHttpInfo(String id, { AssistantProposal? assistantProposal, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/assistant/proposals/{id}/confirm/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = assistantProposal;

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
  /// * [String] id (required):
  ///
  /// * [AssistantProposal] assistantProposal:
  Future<AssistantProposal?> apiV1AssistantProposalsConfirmCreate(String id, { AssistantProposal? assistantProposal, }) async {
    final response = await apiV1AssistantProposalsConfirmCreateWithHttpInfo(id,  assistantProposal: assistantProposal, );
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

  /// Performs an HTTP 'GET /api/v1/assistant/proposals/' operation and returns the [Response].
  Future<Response> apiV1AssistantProposalsListWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/assistant/proposals/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<List<AssistantProposal>?> apiV1AssistantProposalsList() async {
    final response = await apiV1AssistantProposalsListWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<AssistantProposal>') as List)
        .cast<AssistantProposal>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/assistant/proposals/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> apiV1AssistantProposalsRetrieveWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/assistant/proposals/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  Future<AssistantProposal?> apiV1AssistantProposalsRetrieve(String id,) async {
    final response = await apiV1AssistantProposalsRetrieveWithHttpInfo(id,);
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

  /// Performs an HTTP 'POST /api/v1/assistant/proposals/{id}/revise/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [AssistantProposal] assistantProposal:
  Future<Response> apiV1AssistantProposalsReviseCreateWithHttpInfo(String id, { AssistantProposal? assistantProposal, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/assistant/proposals/{id}/revise/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = assistantProposal;

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
  /// * [String] id (required):
  ///
  /// * [AssistantProposal] assistantProposal:
  Future<AssistantProposal?> apiV1AssistantProposalsReviseCreate(String id, { AssistantProposal? assistantProposal, }) async {
    final response = await apiV1AssistantProposalsReviseCreateWithHttpInfo(id,  assistantProposal: assistantProposal, );
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

  /// Performs an HTTP 'GET /api/v1/assistant/proposals/{id}/revisions/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> apiV1AssistantProposalsRevisionsRetrieveWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/assistant/proposals/{id}/revisions/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  Future<AssistantProposal?> apiV1AssistantProposalsRevisionsRetrieve(String id,) async {
    final response = await apiV1AssistantProposalsRevisionsRetrieveWithHttpInfo(id,);
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

  /// Dev presign: direct multipart upload instructions.  Production Supabase private-storage signing plugs in here behind the same response shape; until bucket credentials exist the client uploads straight to ``upload_url``. The shape (mode/upload_url/key) is what clients code against.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> apiV1AttachmentsPresignCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/attachments/presign/';

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

  /// Dev presign: direct multipart upload instructions.  Production Supabase private-storage signing plugs in here behind the same response shape; until bucket credentials exist the client uploads straight to ``upload_url``. The shape (mode/upload_url/key) is what clients code against.
  Future<void> apiV1AttachmentsPresignCreate() async {
    final response = await apiV1AttachmentsPresignCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/attachments/' operation and returns the [Response].
  Future<Response> apiV1AttachmentsRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/attachments/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1AttachmentsRetrieve() async {
    final response = await apiV1AttachmentsRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/attachments/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> apiV1AttachmentsRetrieve2WithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/attachments/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  Future<void> apiV1AttachmentsRetrieve2(String id,) async {
    final response = await apiV1AttachmentsRetrieve2WithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/auth/login/' operation and returns the [Response].
  Future<Response> apiV1AuthLoginCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/login/';

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

  Future<void> apiV1AuthLoginCreate() async {
    final response = await apiV1AuthLoginCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Revoke every session for the caller on all devices.  Records a revocation timestamp; access and refresh tokens issued at or before it are rejected everywhere (see SessionRevocation). The presented tokens are additionally blacklisted so they fail fast with a clear code.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> apiV1AuthLogoutAllCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/logout-all/';

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

  /// Revoke every session for the caller on all devices.  Records a revocation timestamp; access and refresh tokens issued at or before it are rejected everywhere (see SessionRevocation). The presented tokens are additionally blacklisted so they fail fast with a clear code.
  Future<void> apiV1AuthLogoutAllCreate() async {
    final response = await apiV1AuthLogoutAllCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/auth/logout/' operation and returns the [Response].
  Future<Response> apiV1AuthLogoutCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/logout/';

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

  Future<void> apiV1AuthLogoutCreate() async {
    final response = await apiV1AuthLogoutCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/auth/otp/send/' operation and returns the [Response].
  Future<Response> apiV1AuthOtpSendCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/otp/send/';

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

  Future<void> apiV1AuthOtpSendCreate() async {
    final response = await apiV1AuthOtpSendCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/auth/otp/verify/' operation and returns the [Response].
  Future<Response> apiV1AuthOtpVerifyCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/otp/verify/';

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

  Future<void> apiV1AuthOtpVerifyCreate() async {
    final response = await apiV1AuthOtpVerifyCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/auth/password/change/' operation and returns the [Response].
  Future<Response> apiV1AuthPasswordChangeCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/password/change/';

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

  Future<void> apiV1AuthPasswordChangeCreate() async {
    final response = await apiV1AuthPasswordChangeCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/auth/password/reset/confirm/' operation and returns the [Response].
  Future<Response> apiV1AuthPasswordResetConfirmCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/password/reset/confirm/';

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

  Future<void> apiV1AuthPasswordResetConfirmCreate() async {
    final response = await apiV1AuthPasswordResetConfirmCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/auth/password/reset/' operation and returns the [Response].
  Future<Response> apiV1AuthPasswordResetCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/password/reset/';

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

  Future<void> apiV1AuthPasswordResetCreate() async {
    final response = await apiV1AuthPasswordResetCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/auth/refresh/' operation and returns the [Response].
  Future<Response> apiV1AuthRefreshCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/refresh/';

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

  Future<void> apiV1AuthRefreshCreate() async {
    final response = await apiV1AuthRefreshCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/auth/signup/' operation and returns the [Response].
  Future<Response> apiV1AuthSignupCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/signup/';

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

  Future<void> apiV1AuthSignupCreate() async {
    final response = await apiV1AuthSignupCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/bootstrap/' operation and returns the [Response].
  Future<Response> apiV1BootstrapRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/bootstrap/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1BootstrapRetrieve() async {
    final response = await apiV1BootstrapRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/businesses/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [Business] business (required):
  Future<Response> apiV1BusinessesCreateWithHttpInfo(Business business,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/businesses/';

    // ignore: prefer_final_locals
    Object? postBody = business;

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
  /// * [Business] business (required):
  Future<Business?> apiV1BusinessesCreate(Business business,) async {
    final response = await apiV1BusinessesCreateWithHttpInfo(business,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Business',) as Business;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/businesses/' operation and returns the [Response].
  Future<Response> apiV1BusinessesListWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/businesses/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<List<Business>?> apiV1BusinessesList() async {
    final response = await apiV1BusinessesListWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Business>') as List)
        .cast<Business>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'PATCH /api/v1/businesses/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [PatchedBusiness] patchedBusiness:
  Future<Response> apiV1BusinessesPartialUpdateWithHttpInfo(String id, { PatchedBusiness? patchedBusiness, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/businesses/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = patchedBusiness;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'application/x-www-form-urlencoded', 'multipart/form-data'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [PatchedBusiness] patchedBusiness:
  Future<Business?> apiV1BusinessesPartialUpdate(String id, { PatchedBusiness? patchedBusiness, }) async {
    final response = await apiV1BusinessesPartialUpdateWithHttpInfo(id,  patchedBusiness: patchedBusiness, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Business',) as Business;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/businesses/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> apiV1BusinessesRetrieveWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/businesses/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Business?> apiV1BusinessesRetrieve(String id,) async {
    final response = await apiV1BusinessesRetrieveWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Business',) as Business;
    
    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/businesses/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [Business] business (required):
  Future<Response> apiV1BusinessesUpdateWithHttpInfo(String id, Business business,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/businesses/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = business;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'application/x-www-form-urlencoded', 'multipart/form-data'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [Business] business (required):
  Future<Business?> apiV1BusinessesUpdate(String id, Business business,) async {
    final response = await apiV1BusinessesUpdateWithHttpInfo(id, business,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Business',) as Business;
    
    }
    return null;
  }

  /// Register/list the caller's own push device tokens.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> apiV1DevicesCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/devices/';

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

  /// Register/list the caller's own push device tokens.
  Future<void> apiV1DevicesCreate() async {
    final response = await apiV1DevicesCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'DELETE /api/v1/devices/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  Future<Response> apiV1DevicesDestroyWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/devices/{id}/'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [int] id (required):
  Future<void> apiV1DevicesDestroy(int id,) async {
    final response = await apiV1DevicesDestroyWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Register/list the caller's own push device tokens.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> apiV1DevicesRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/devices/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Register/list the caller's own push device tokens.
  Future<void> apiV1DevicesRetrieve() async {
    final response = await apiV1DevicesRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/expenses/' operation and returns the [Response].
  Future<Response> apiV1ExpensesCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/expenses/';

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

  Future<void> apiV1ExpensesCreate() async {
    final response = await apiV1ExpensesCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/expenses/' operation and returns the [Response].
  Future<Response> apiV1ExpensesListWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/expenses/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<List<Expense>?> apiV1ExpensesList() async {
    final response = await apiV1ExpensesListWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Expense>') as List)
        .cast<Expense>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/expenses/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this expense.
  Future<Response> apiV1ExpensesRetrieveWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/expenses/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this expense.
  Future<Expense?> apiV1ExpensesRetrieve(String id,) async {
    final response = await apiV1ExpensesRetrieveWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Expense',) as Expense;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/expenses/{id}/reverse/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this expense.
  ///
  /// * [Expense] expense (required):
  Future<Response> apiV1ExpensesReverseCreateWithHttpInfo(String id, Expense expense,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/expenses/{id}/reverse/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = expense;

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
  /// * [String] id (required):
  ///   A UUID string identifying this expense.
  ///
  /// * [Expense] expense (required):
  Future<Expense?> apiV1ExpensesReverseCreate(String id, Expense expense,) async {
    final response = await apiV1ExpensesReverseCreateWithHttpInfo(id, expense,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Expense',) as Expense;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/exports/' operation and returns the [Response].
  Future<Response> apiV1ExportsRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/exports/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1ExportsRetrieve() async {
    final response = await apiV1ExportsRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/exports/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> apiV1ExportsRetrieve2WithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/exports/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  Future<void> apiV1ExportsRetrieve2(String id,) async {
    final response = await apiV1ExportsRetrieve2WithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/gst-registrations/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [GSTRegistration] gSTRegistration (required):
  Future<Response> apiV1GstRegistrationsCreateWithHttpInfo(GSTRegistration gSTRegistration,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/gst-registrations/';

    // ignore: prefer_final_locals
    Object? postBody = gSTRegistration;

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
  /// * [GSTRegistration] gSTRegistration (required):
  Future<GSTRegistration?> apiV1GstRegistrationsCreate(GSTRegistration gSTRegistration,) async {
    final response = await apiV1GstRegistrationsCreateWithHttpInfo(gSTRegistration,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GSTRegistration',) as GSTRegistration;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/gst-registrations/' operation and returns the [Response].
  Future<Response> apiV1GstRegistrationsListWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/gst-registrations/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<List<GSTRegistration>?> apiV1GstRegistrationsList() async {
    final response = await apiV1GstRegistrationsListWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<GSTRegistration>') as List)
        .cast<GSTRegistration>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'PATCH /api/v1/gst-registrations/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this gst registration.
  ///
  /// * [PatchedGSTRegistration] patchedGSTRegistration:
  Future<Response> apiV1GstRegistrationsPartialUpdateWithHttpInfo(String id, { PatchedGSTRegistration? patchedGSTRegistration, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/gst-registrations/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = patchedGSTRegistration;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'application/x-www-form-urlencoded', 'multipart/form-data'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this gst registration.
  ///
  /// * [PatchedGSTRegistration] patchedGSTRegistration:
  Future<GSTRegistration?> apiV1GstRegistrationsPartialUpdate(String id, { PatchedGSTRegistration? patchedGSTRegistration, }) async {
    final response = await apiV1GstRegistrationsPartialUpdateWithHttpInfo(id,  patchedGSTRegistration: patchedGSTRegistration, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GSTRegistration',) as GSTRegistration;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/gst-registrations/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this gst registration.
  Future<Response> apiV1GstRegistrationsRetrieveWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/gst-registrations/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this gst registration.
  Future<GSTRegistration?> apiV1GstRegistrationsRetrieve(String id,) async {
    final response = await apiV1GstRegistrationsRetrieveWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GSTRegistration',) as GSTRegistration;
    
    }
    return null;
  }

  /// Join the invited business.  The invitation token proves the invite; the verified phone number must match the invitation. The invitee is usually not a member yet, so the single invitation row is read under a staff scope that is restored immediately; acceptance still requires the unguessable token plus the matching verified phone number. The business is then added to the connection scope exactly like onboarding, so the membership insert passes the database check.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [Invitation] invitation (required):
  Future<Response> apiV1InvitationsAcceptCreateWithHttpInfo(String id, Invitation invitation,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/invitations/{id}/accept/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = invitation;

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

  /// Join the invited business.  The invitation token proves the invite; the verified phone number must match the invitation. The invitee is usually not a member yet, so the single invitation row is read under a staff scope that is restored immediately; acceptance still requires the unguessable token plus the matching verified phone number. The business is then added to the connection scope exactly like onboarding, so the membership insert passes the database check.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [Invitation] invitation (required):
  Future<Invitation?> apiV1InvitationsAcceptCreate(String id, Invitation invitation,) async {
    final response = await apiV1InvitationsAcceptCreateWithHttpInfo(id, invitation,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Invitation',) as Invitation;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/invitations/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [Invitation] invitation (required):
  Future<Response> apiV1InvitationsCreateWithHttpInfo(Invitation invitation,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/invitations/';

    // ignore: prefer_final_locals
    Object? postBody = invitation;

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
  /// * [Invitation] invitation (required):
  Future<Invitation?> apiV1InvitationsCreate(Invitation invitation,) async {
    final response = await apiV1InvitationsCreateWithHttpInfo(invitation,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Invitation',) as Invitation;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/invitations/' operation and returns the [Response].
  Future<Response> apiV1InvitationsListWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/invitations/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<List<Invitation>?> apiV1InvitationsList() async {
    final response = await apiV1InvitationsListWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Invitation>') as List)
        .cast<Invitation>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/invitations/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> apiV1InvitationsRetrieveWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/invitations/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Invitation?> apiV1InvitationsRetrieve(String id,) async {
    final response = await apiV1InvitationsRetrieveWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Invitation',) as Invitation;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/invitations/{id}/revoke/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [Invitation] invitation (required):
  Future<Response> apiV1InvitationsRevokeCreateWithHttpInfo(String id, Invitation invitation,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/invitations/{id}/revoke/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = invitation;

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
  /// * [String] id (required):
  ///
  /// * [Invitation] invitation (required):
  Future<Invitation?> apiV1InvitationsRevokeCreate(String id, Invitation invitation,) async {
    final response = await apiV1InvitationsRevokeCreateWithHttpInfo(id, invitation,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Invitation',) as Invitation;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/locations/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [Location] location (required):
  Future<Response> apiV1LocationsCreateWithHttpInfo(Location location,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/locations/';

    // ignore: prefer_final_locals
    Object? postBody = location;

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
  /// * [Location] location (required):
  Future<Location?> apiV1LocationsCreate(Location location,) async {
    final response = await apiV1LocationsCreateWithHttpInfo(location,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Location',) as Location;
    
    }
    return null;
  }

  /// Performs an HTTP 'DELETE /api/v1/locations/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this location.
  Future<Response> apiV1LocationsDestroyWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/locations/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this location.
  Future<void> apiV1LocationsDestroy(String id,) async {
    final response = await apiV1LocationsDestroyWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/locations/' operation and returns the [Response].
  Future<Response> apiV1LocationsListWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/locations/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<List<Location>?> apiV1LocationsList() async {
    final response = await apiV1LocationsListWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Location>') as List)
        .cast<Location>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'PATCH /api/v1/locations/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this location.
  ///
  /// * [PatchedLocation] patchedLocation:
  Future<Response> apiV1LocationsPartialUpdateWithHttpInfo(String id, { PatchedLocation? patchedLocation, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/locations/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = patchedLocation;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'application/x-www-form-urlencoded', 'multipart/form-data'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this location.
  ///
  /// * [PatchedLocation] patchedLocation:
  Future<Location?> apiV1LocationsPartialUpdate(String id, { PatchedLocation? patchedLocation, }) async {
    final response = await apiV1LocationsPartialUpdateWithHttpInfo(id,  patchedLocation: patchedLocation, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Location',) as Location;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/locations/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this location.
  Future<Response> apiV1LocationsRetrieveWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/locations/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this location.
  Future<Location?> apiV1LocationsRetrieve(String id,) async {
    final response = await apiV1LocationsRetrieveWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Location',) as Location;
    
    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/locations/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this location.
  ///
  /// * [Location] location (required):
  Future<Response> apiV1LocationsUpdateWithHttpInfo(String id, Location location,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/locations/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = location;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'application/x-www-form-urlencoded', 'multipart/form-data'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this location.
  ///
  /// * [Location] location (required):
  Future<Location?> apiV1LocationsUpdate(String id, Location location,) async {
    final response = await apiV1LocationsUpdateWithHttpInfo(id, location,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Location',) as Location;
    
    }
    return null;
  }

  /// Performs an HTTP 'PATCH /api/v1/me/' operation and returns the [Response].
  Future<Response> apiV1MePartialUpdateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/me/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  Future<void> apiV1MePartialUpdate() async {
    final response = await apiV1MePartialUpdateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/me/' operation and returns the [Response].
  Future<Response> apiV1MeRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/me/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1MeRetrieve() async {
    final response = await apiV1MeRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/memberships/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [Membership] membership (required):
  Future<Response> apiV1MembershipsCreateWithHttpInfo(Membership membership,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/memberships/';

    // ignore: prefer_final_locals
    Object? postBody = membership;

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
  /// * [Membership] membership (required):
  Future<Membership?> apiV1MembershipsCreate(Membership membership,) async {
    final response = await apiV1MembershipsCreateWithHttpInfo(membership,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Membership',) as Membership;
    
    }
    return null;
  }

  /// Performs an HTTP 'DELETE /api/v1/memberships/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> apiV1MembershipsDestroyWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/memberships/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  Future<void> apiV1MembershipsDestroy(String id,) async {
    final response = await apiV1MembershipsDestroyWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/memberships/' operation and returns the [Response].
  Future<Response> apiV1MembershipsListWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/memberships/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<List<Membership>?> apiV1MembershipsList() async {
    final response = await apiV1MembershipsListWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Membership>') as List)
        .cast<Membership>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'PATCH /api/v1/memberships/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [PatchedMembership] patchedMembership:
  Future<Response> apiV1MembershipsPartialUpdateWithHttpInfo(String id, { PatchedMembership? patchedMembership, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/memberships/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = patchedMembership;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'application/x-www-form-urlencoded', 'multipart/form-data'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [PatchedMembership] patchedMembership:
  Future<Membership?> apiV1MembershipsPartialUpdate(String id, { PatchedMembership? patchedMembership, }) async {
    final response = await apiV1MembershipsPartialUpdateWithHttpInfo(id,  patchedMembership: patchedMembership, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Membership',) as Membership;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/memberships/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> apiV1MembershipsRetrieveWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/memberships/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Membership?> apiV1MembershipsRetrieve(String id,) async {
    final response = await apiV1MembershipsRetrieveWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Membership',) as Membership;
    
    }
    return null;
  }

  /// Deactivate a membership and force the member to sign in again.  Deactivation alone already blocks the business (every endpoint checks membership), but without session revocation the removed member keeps a valid identity token. Revoking sessions closes that gap; the member keeps access to their other businesses after signing in again.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [Membership] membership (required):
  Future<Response> apiV1MembershipsRevokeCreateWithHttpInfo(String id, Membership membership,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/memberships/{id}/revoke/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = membership;

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

  /// Deactivate a membership and force the member to sign in again.  Deactivation alone already blocks the business (every endpoint checks membership), but without session revocation the removed member keeps a valid identity token. Revoking sessions closes that gap; the member keeps access to their other businesses after signing in again.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [Membership] membership (required):
  Future<Membership?> apiV1MembershipsRevokeCreate(String id, Membership membership,) async {
    final response = await apiV1MembershipsRevokeCreateWithHttpInfo(id, membership,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Membership',) as Membership;
    
    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/memberships/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [Membership] membership (required):
  Future<Response> apiV1MembershipsUpdateWithHttpInfo(String id, Membership membership,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/memberships/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = membership;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'application/x-www-form-urlencoded', 'multipart/form-data'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [Membership] membership (required):
  Future<Membership?> apiV1MembershipsUpdate(String id, Membership membership,) async {
    final response = await apiV1MembershipsUpdateWithHttpInfo(id, membership,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Membership',) as Membership;
    
    }
    return null;
  }

  /// Get or update the caller's notification toggles for one business.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> apiV1NotificationPreferencesPartialUpdateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/notification-preferences/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get or update the caller's notification toggles for one business.
  Future<void> apiV1NotificationPreferencesPartialUpdate() async {
    final response = await apiV1NotificationPreferencesPartialUpdateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get or update the caller's notification toggles for one business.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> apiV1NotificationPreferencesRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/notification-preferences/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Get or update the caller's notification toggles for one business.
  Future<void> apiV1NotificationPreferencesRetrieve() async {
    final response = await apiV1NotificationPreferencesRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/parties/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [Party] party (required):
  Future<Response> apiV1PartiesCreateWithHttpInfo(Party party,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/parties/';

    // ignore: prefer_final_locals
    Object? postBody = party;

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
  /// * [Party] party (required):
  Future<Party?> apiV1PartiesCreate(Party party,) async {
    final response = await apiV1PartiesCreateWithHttpInfo(party,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Party',) as Party;
    
    }
    return null;
  }

  /// Performs an HTTP 'DELETE /api/v1/parties/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this party.
  Future<Response> apiV1PartiesDestroyWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/parties/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this party.
  Future<void> apiV1PartiesDestroy(String id,) async {
    final response = await apiV1PartiesDestroyWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/parties/' operation and returns the [Response].
  Future<Response> apiV1PartiesListWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/parties/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<List<Party>?> apiV1PartiesList() async {
    final response = await apiV1PartiesListWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Party>') as List)
        .cast<Party>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'PATCH /api/v1/parties/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this party.
  ///
  /// * [PatchedParty] patchedParty:
  Future<Response> apiV1PartiesPartialUpdateWithHttpInfo(String id, { PatchedParty? patchedParty, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/parties/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = patchedParty;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'application/x-www-form-urlencoded', 'multipart/form-data'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this party.
  ///
  /// * [PatchedParty] patchedParty:
  Future<Party?> apiV1PartiesPartialUpdate(String id, { PatchedParty? patchedParty, }) async {
    final response = await apiV1PartiesPartialUpdateWithHttpInfo(id,  patchedParty: patchedParty, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Party',) as Party;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/parties/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this party.
  Future<Response> apiV1PartiesRetrieveWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/parties/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this party.
  Future<Party?> apiV1PartiesRetrieve(String id,) async {
    final response = await apiV1PartiesRetrieveWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Party',) as Party;
    
    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/parties/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this party.
  ///
  /// * [Party] party (required):
  Future<Response> apiV1PartiesUpdateWithHttpInfo(String id, Party party,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/parties/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = party;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'application/x-www-form-urlencoded', 'multipart/form-data'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this party.
  ///
  /// * [Party] party (required):
  Future<Party?> apiV1PartiesUpdate(String id, Party party,) async {
    final response = await apiV1PartiesUpdateWithHttpInfo(id, party,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Party',) as Party;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/party-ledger/opening-balances/' operation and returns the [Response].
  Future<Response> apiV1PartyLedgerOpeningBalancesCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/party-ledger/opening-balances/';

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

  Future<void> apiV1PartyLedgerOpeningBalancesCreate() async {
    final response = await apiV1PartyLedgerOpeningBalancesCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/payments/' operation and returns the [Response].
  Future<Response> apiV1PaymentsCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/payments/';

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

  Future<void> apiV1PaymentsCreate() async {
    final response = await apiV1PaymentsCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/payments/' operation and returns the [Response].
  Future<Response> apiV1PaymentsListWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/payments/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<List<Payment>?> apiV1PaymentsList() async {
    final response = await apiV1PaymentsListWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Payment>') as List)
        .cast<Payment>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/payments/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this payment.
  Future<Response> apiV1PaymentsRetrieveWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/payments/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this payment.
  Future<Payment?> apiV1PaymentsRetrieve(String id,) async {
    final response = await apiV1PaymentsRetrieveWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Payment',) as Payment;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/payments/{id}/reverse/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this payment.
  ///
  /// * [Payment] payment (required):
  Future<Response> apiV1PaymentsReverseCreateWithHttpInfo(String id, Payment payment,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/payments/{id}/reverse/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = payment;

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
  /// * [String] id (required):
  ///   A UUID string identifying this payment.
  ///
  /// * [Payment] payment (required):
  Future<Payment?> apiV1PaymentsReverseCreate(String id, Payment payment,) async {
    final response = await apiV1PaymentsReverseCreateWithHttpInfo(id, payment,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Payment',) as Payment;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/products/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [Product] product (required):
  Future<Response> apiV1ProductsCreateWithHttpInfo(Product product,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/products/';

    // ignore: prefer_final_locals
    Object? postBody = product;

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
  /// * [Product] product (required):
  Future<Product?> apiV1ProductsCreate(Product product,) async {
    final response = await apiV1ProductsCreateWithHttpInfo(product,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Product',) as Product;
    
    }
    return null;
  }

  /// Performs an HTTP 'DELETE /api/v1/products/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this product.
  Future<Response> apiV1ProductsDestroyWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/products/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this product.
  Future<void> apiV1ProductsDestroy(String id,) async {
    final response = await apiV1ProductsDestroyWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/products/' operation and returns the [Response].
  Future<Response> apiV1ProductsListWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/products/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<List<Product>?> apiV1ProductsList() async {
    final response = await apiV1ProductsListWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Product>') as List)
        .cast<Product>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'PATCH /api/v1/products/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this product.
  ///
  /// * [PatchedProduct] patchedProduct:
  Future<Response> apiV1ProductsPartialUpdateWithHttpInfo(String id, { PatchedProduct? patchedProduct, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/products/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = patchedProduct;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'application/x-www-form-urlencoded', 'multipart/form-data'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this product.
  ///
  /// * [PatchedProduct] patchedProduct:
  Future<Product?> apiV1ProductsPartialUpdate(String id, { PatchedProduct? patchedProduct, }) async {
    final response = await apiV1ProductsPartialUpdateWithHttpInfo(id,  patchedProduct: patchedProduct, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Product',) as Product;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/products/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this product.
  Future<Response> apiV1ProductsRetrieveWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/products/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this product.
  Future<Product?> apiV1ProductsRetrieve(String id,) async {
    final response = await apiV1ProductsRetrieveWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Product',) as Product;
    
    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/products/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this product.
  ///
  /// * [Product] product (required):
  Future<Response> apiV1ProductsUpdateWithHttpInfo(String id, Product product,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/products/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = product;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'application/x-www-form-urlencoded', 'multipart/form-data'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this product.
  ///
  /// * [Product] product (required):
  Future<Product?> apiV1ProductsUpdate(String id, Product product,) async {
    final response = await apiV1ProductsUpdateWithHttpInfo(id, product,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Product',) as Product;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/purchases/' operation and returns the [Response].
  Future<Response> apiV1PurchasesCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/purchases/';

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

  Future<void> apiV1PurchasesCreate() async {
    final response = await apiV1PurchasesCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/purchases/' operation and returns the [Response].
  Future<Response> apiV1PurchasesListWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/purchases/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<List<Purchase>?> apiV1PurchasesList() async {
    final response = await apiV1PurchasesListWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Purchase>') as List)
        .cast<Purchase>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/purchases/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this purchase.
  Future<Response> apiV1PurchasesRetrieveWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/purchases/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this purchase.
  Future<Purchase?> apiV1PurchasesRetrieve(String id,) async {
    final response = await apiV1PurchasesRetrieveWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Purchase',) as Purchase;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/purchases/{id}/reverse/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this purchase.
  ///
  /// * [Purchase] purchase (required):
  Future<Response> apiV1PurchasesReverseCreateWithHttpInfo(String id, Purchase purchase,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/purchases/{id}/reverse/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = purchase;

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
  /// * [String] id (required):
  ///   A UUID string identifying this purchase.
  ///
  /// * [Purchase] purchase (required):
  Future<Purchase?> apiV1PurchasesReverseCreate(String id, Purchase purchase,) async {
    final response = await apiV1PurchasesReverseCreateWithHttpInfo(id, purchase,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Purchase',) as Purchase;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/reminders/' operation and returns the [Response].
  Future<Response> apiV1RemindersRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/reminders/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1RemindersRetrieve() async {
    final response = await apiV1RemindersRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/reminders/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> apiV1RemindersRetrieve2WithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/reminders/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  Future<void> apiV1RemindersRetrieve2(String id,) async {
    final response = await apiV1RemindersRetrieve2WithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Computed follow-ups: overdue receivables first, then low stock.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> apiV1RemindersSuggestionsRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/reminders/suggestions/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Computed follow-ups: overdue receivables first, then low stock.
  Future<void> apiV1RemindersSuggestionsRetrieve() async {
    final response = await apiV1RemindersSuggestionsRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/reports/dashboard/' operation and returns the [Response].
  Future<Response> apiV1ReportsDashboardRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/reports/dashboard/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1ReportsDashboardRetrieve() async {
    final response = await apiV1ReportsDashboardRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/reports/day-book/' operation and returns the [Response].
  Future<Response> apiV1ReportsDayBookRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/reports/day-book/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1ReportsDayBookRetrieve() async {
    final response = await apiV1ReportsDayBookRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/reports/export/' operation and returns the [Response].
  Future<Response> apiV1ReportsExportRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/reports/export/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1ReportsExportRetrieve() async {
    final response = await apiV1ReportsExportRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/reports/gst/' operation and returns the [Response].
  Future<Response> apiV1ReportsGstRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/reports/gst/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1ReportsGstRetrieve() async {
    final response = await apiV1ReportsGstRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/reports/party-balances/' operation and returns the [Response].
  Future<Response> apiV1ReportsPartyBalancesRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/reports/party-balances/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1ReportsPartyBalancesRetrieve() async {
    final response = await apiV1ReportsPartyBalancesRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/reports/party-ledger/' operation and returns the [Response].
  Future<Response> apiV1ReportsPartyLedgerRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/reports/party-ledger/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1ReportsPartyLedgerRetrieve() async {
    final response = await apiV1ReportsPartyLedgerRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/reports/purchases/' operation and returns the [Response].
  Future<Response> apiV1ReportsPurchasesRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/reports/purchases/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1ReportsPurchasesRetrieve() async {
    final response = await apiV1ReportsPurchasesRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/reports/sales/' operation and returns the [Response].
  Future<Response> apiV1ReportsSalesRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/reports/sales/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1ReportsSalesRetrieve() async {
    final response = await apiV1ReportsSalesRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/reports/stock/' operation and returns the [Response].
  Future<Response> apiV1ReportsStockRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/reports/stock/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1ReportsStockRetrieve() async {
    final response = await apiV1ReportsStockRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/reports/stock-valuation/' operation and returns the [Response].
  Future<Response> apiV1ReportsStockValuationRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/reports/stock-valuation/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1ReportsStockValuationRetrieve() async {
    final response = await apiV1ReportsStockValuationRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/sales/' operation and returns the [Response].
  Future<Response> apiV1SalesCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/sales/';

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

  Future<void> apiV1SalesCreate() async {
    final response = await apiV1SalesCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/sales/' operation and returns the [Response].
  Future<Response> apiV1SalesListWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/sales/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<List<Sale>?> apiV1SalesList() async {
    final response = await apiV1SalesListWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Sale>') as List)
        .cast<Sale>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/sales/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this sale.
  Future<Response> apiV1SalesRetrieveWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/sales/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this sale.
  Future<Sale?> apiV1SalesRetrieve(String id,) async {
    final response = await apiV1SalesRetrieveWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Sale',) as Sale;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/sales/{id}/reverse/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this sale.
  ///
  /// * [Sale] sale (required):
  Future<Response> apiV1SalesReverseCreateWithHttpInfo(String id, Sale sale,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/sales/{id}/reverse/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = sale;

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
  /// * [String] id (required):
  ///   A UUID string identifying this sale.
  ///
  /// * [Sale] sale (required):
  Future<Sale?> apiV1SalesReverseCreate(String id, Sale sale,) async {
    final response = await apiV1SalesReverseCreateWithHttpInfo(id, sale,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Sale',) as Sale;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/stock/adjustments/' operation and returns the [Response].
  Future<Response> apiV1StockAdjustmentsCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/stock/adjustments/';

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

  Future<void> apiV1StockAdjustmentsCreate() async {
    final response = await apiV1StockAdjustmentsCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/stock/movements/' operation and returns the [Response].
  Future<Response> apiV1StockMovementsRetrieveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/stock/movements/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<void> apiV1StockMovementsRetrieve() async {
    final response = await apiV1StockMovementsRetrieveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/v1/transfers/' operation and returns the [Response].
  Future<Response> apiV1TransfersCreateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/transfers/';

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

  Future<void> apiV1TransfersCreate() async {
    final response = await apiV1TransfersCreateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/v1/transfers/' operation and returns the [Response].
  Future<Response> apiV1TransfersListWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/transfers/';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<List<Transfer>?> apiV1TransfersList() async {
    final response = await apiV1TransfersListWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Transfer>') as List)
        .cast<Transfer>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/transfers/{id}/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this stock transfer.
  Future<Response> apiV1TransfersRetrieveWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/transfers/{id}/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this stock transfer.
  Future<Transfer?> apiV1TransfersRetrieve(String id,) async {
    final response = await apiV1TransfersRetrieveWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Transfer',) as Transfer;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/transfers/{id}/reverse/' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///   A UUID string identifying this stock transfer.
  ///
  /// * [Transfer] transfer (required):
  Future<Response> apiV1TransfersReverseCreateWithHttpInfo(String id, Transfer transfer,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/transfers/{id}/reverse/'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = transfer;

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
  /// * [String] id (required):
  ///   A UUID string identifying this stock transfer.
  ///
  /// * [Transfer] transfer (required):
  Future<Transfer?> apiV1TransfersReverseCreate(String id, Transfer transfer,) async {
    final response = await apiV1TransfersReverseCreateWithHttpInfo(id, transfer,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Transfer',) as Transfer;
    
    }
    return null;
  }
}
