# openapi.model.Payment

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | [readonly] 
**business** | **String** |  | 
**location** | **String** |  | 
**party** | **String** |  | [optional] 
**partyName** | **String** |  | [readonly] 
**direction** | [**DirectionEnum**](DirectionEnum.md) |  | 
**method** | [**MethodEnum**](MethodEnum.md) |  | 
**amountMinor** | **int** |  | 
**reference** | **String** |  | [optional] 
**note** | **String** |  | [optional] 
**paymentDate** | [**DateTime**](DateTime.md) |  | 
**occurredAt** | [**DateTime**](DateTime.md) |  | [readonly] 
**status** | [**Status3f8Enum**](Status3f8Enum.md) |  | [optional] 
**source_** | **String** |  | [optional] 
**reversalReason** | **String** |  | [optional] 
**reversedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**allocations** | [**List<PaymentAllocation>**](PaymentAllocation.md) |  | [readonly] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


