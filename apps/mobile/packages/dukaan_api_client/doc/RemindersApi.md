# openapi.api.RemindersApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1RemindersCreate**](RemindersApi.md#apiv1reminderscreate) | **POST** /api/v1/reminders/ | 


# **apiV1RemindersCreate**
> Reminder apiV1RemindersCreate(reminderCreate)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = RemindersApi();
final reminderCreate = ReminderCreate(); // ReminderCreate | 

try {
    final result = api_instance.apiV1RemindersCreate(reminderCreate);
    print(result);
} catch (e) {
    print('Exception when calling RemindersApi->apiV1RemindersCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reminderCreate** | [**ReminderCreate**](ReminderCreate.md)|  | 

### Return type

[**Reminder**](Reminder.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

