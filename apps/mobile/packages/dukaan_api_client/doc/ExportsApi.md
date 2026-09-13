# openapi.api.ExportsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1ExportsCreate**](ExportsApi.md#apiv1exportscreate) | **POST** /api/v1/exports/ | 


# **apiV1ExportsCreate**
> ExportJob apiV1ExportsCreate(exportCreate)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ExportsApi();
final exportCreate = ExportCreate(); // ExportCreate | 

try {
    final result = api_instance.apiV1ExportsCreate(exportCreate);
    print(result);
} catch (e) {
    print('Exception when calling ExportsApi->apiV1ExportsCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **exportCreate** | [**ExportCreate**](ExportCreate.md)|  | 

### Return type

[**ExportJob**](ExportJob.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

