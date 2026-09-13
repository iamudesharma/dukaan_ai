# openapi.api.ActivityApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1ActivityRetrieve**](ActivityApi.md#apiv1activityretrieve) | **GET** /api/v1/activity/ | 


# **apiV1ActivityRetrieve**
> apiV1ActivityRetrieve(businessId, kind, locationId)



Newest-first audit feed over append-only AuditEvent.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ActivityApi();
final businessId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final kind = kind_example; // String | 
final locationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.apiV1ActivityRetrieve(businessId, kind, locationId);
} catch (e) {
    print('Exception when calling ActivityApi->apiV1ActivityRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **businessId** | **String**|  | 
 **kind** | **String**|  | [optional] 
 **locationId** | **String**|  | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

