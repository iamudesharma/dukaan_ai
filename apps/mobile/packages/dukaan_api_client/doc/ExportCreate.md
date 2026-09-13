# openapi.model.ExportCreate

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**businessId** | **String** |  | 
**report** | [**ReportEnum**](ReportEnum.md) |  | 
**format** | [**FormatEnum**](FormatEnum.md) |  | [optional] [default to FormatEnum.CSV]
**locationId** | **String** |  | [optional] 
**fromDate** | [**DateTime**](DateTime.md) |  | [optional] 
**toDate** | [**DateTime**](DateTime.md) |  | [optional] 
**groupBy** | **String** |  | [optional] [default to 'day']

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


