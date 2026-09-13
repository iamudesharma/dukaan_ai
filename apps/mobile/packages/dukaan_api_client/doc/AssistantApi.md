# openapi.api.AssistantApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1AssistantProposalsCreate**](AssistantApi.md#apiv1assistantproposalscreate) | **POST** /api/v1/assistant/proposals/ | 


# **apiV1AssistantProposalsCreate**
> AssistantProposal apiV1AssistantProposalsCreate(interpret)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = AssistantApi();
final interpret = Interpret(); // Interpret | 

try {
    final result = api_instance.apiV1AssistantProposalsCreate(interpret);
    print(result);
} catch (e) {
    print('Exception when calling AssistantApi->apiV1AssistantProposalsCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **interpret** | [**Interpret**](Interpret.md)|  | 

### Return type

[**AssistantProposal**](AssistantProposal.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

