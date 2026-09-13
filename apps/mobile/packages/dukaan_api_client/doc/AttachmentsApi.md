# openapi.api.AttachmentsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1AttachmentsCreate**](AttachmentsApi.md#apiv1attachmentscreate) | **POST** /api/v1/attachments/ | 
[**apiV1SalesInvoiceCreate**](AttachmentsApi.md#apiv1salesinvoicecreate) | **POST** /api/v1/sales/{id}/invoice/ | 


# **apiV1AttachmentsCreate**
> Attachment apiV1AttachmentsCreate(businessId, file)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = AttachmentsApi();
final businessId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final file = file_example; // String | 

try {
    final result = api_instance.apiV1AttachmentsCreate(businessId, file);
    print(result);
} catch (e) {
    print('Exception when calling AttachmentsApi->apiV1AttachmentsCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **businessId** | **String**|  | 
 **file** | **String**|  | 

### Return type

[**Attachment**](Attachment.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: multipart/form-data, application/x-www-form-urlencoded
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1SalesInvoiceCreate**
> Attachment apiV1SalesInvoiceCreate(id)



Get-or-create the invoice PDF for a posted sale (idempotent).

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = AttachmentsApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.apiV1SalesInvoiceCreate(id);
    print(result);
} catch (e) {
    print('Exception when calling AttachmentsApi->apiV1SalesInvoiceCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Attachment**](Attachment.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

