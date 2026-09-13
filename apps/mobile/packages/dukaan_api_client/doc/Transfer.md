# openapi.model.Transfer

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | [readonly] 
**business** | **String** |  | 
**fromLocation** | **String** |  | 
**toLocation** | **String** |  | 
**status** | [**Status3f8Enum**](Status3f8Enum.md) |  | [optional] 
**number** | **String** |  | 
**documentDate** | [**DateTime**](DateTime.md) |  | 
**note** | **String** |  | [optional] 
**negativeStockAcknowledged** | **bool** |  | [optional] 
**negativeStockReason** | **String** |  | [optional] 
**postedAt** | [**DateTime**](DateTime.md) |  | 
**reversalReason** | **String** |  | [optional] 
**reversedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**lines** | [**List<TransferLine>**](TransferLine.md) |  | [readonly] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


