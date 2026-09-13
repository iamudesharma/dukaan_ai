# openapi.api.SearchApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1SearchRetrieve**](SearchApi.md#apiv1searchretrieve) | **GET** /api/v1/search/ | 


# **apiV1SearchRetrieve**
> apiV1SearchRetrieve(businessId, q, types)



Scoped global search over parties, products, and documents.  Cashiers see sales, customers, and products only — supplier and purchase rows stay manager-visible, mirroring the report gating.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = SearchApi();
final businessId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final q = q_example; // String | 
final types = types_example; // String | 

try {
    api_instance.apiV1SearchRetrieve(businessId, q, types);
} catch (e) {
    print('Exception when calling SearchApi->apiV1SearchRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **businessId** | **String**|  | 
 **q** | **String**|  | 
 **types** | **String**|  | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

