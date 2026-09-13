# openapi.model.Expense

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
**status** | [**Status3f8Enum**](Status3f8Enum.md) |  | [optional] 
**number** | **String** |  | 
**documentDate** | [**DateTime**](DateTime.md) |  | 
**occurredAt** | [**DateTime**](DateTime.md) |  | [readonly] 
**category** | **String** |  | 
**payee** | **String** |  | [optional] 
**note** | **String** |  | [optional] 
**amountMinor** | **int** |  | 
**taxAmountMinor** | **int** |  | [optional] 
**totalMinor** | **int** |  | 
**paymentMethod** | [**PaymentMethodEnum**](PaymentMethodEnum.md) |  | 
**source_** | **String** |  | [optional] 
**postedAt** | [**DateTime**](DateTime.md) |  | 
**reversalReason** | **String** |  | [optional] 
**reversedAt** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


