# openapi.api.HealthzApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**healthzRetrieve**](HealthzApi.md#healthzretrieve) | **GET** /healthz/ | 


# **healthzRetrieve**
> healthzRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = HealthzApi();

try {
    api_instance.healthzRetrieve();
} catch (e) {
    print('Exception when calling HealthzApi->healthzRetrieve: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

