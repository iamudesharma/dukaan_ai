# openapi.model.Sale

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
**customer** | **String** |  | [optional] 
**customerName** | **String** |  | [readonly] 
**status** | [**Status3f8Enum**](Status3f8Enum.md) |  | [optional] 
**number** | **String** |  | 
**invoiceNumber** | **String** |  | [readonly] 
**occurredAt** | [**DateTime**](DateTime.md) |  | [readonly] 
**financialYear** | **String** |  | 
**documentDate** | [**DateTime**](DateTime.md) |  | 
**priceMode** | [**PriceModeEnum**](PriceModeEnum.md) |  | [optional] 
**taxInclusive** | **bool** |  | [optional] 
**sellerName** | **String** |  | [optional] 
**sellerGstin** | **String** |  | [optional] 
**buyerName** | **String** |  | [optional] 
**buyerGstin** | **String** |  | [optional] 
**placeOfSupply** | **String** |  | [optional] 
**subtotalMinor** | **int** |  | [optional] 
**discountTotalMinor** | **int** |  | [optional] 
**taxableTotalMinor** | **int** |  | [optional] 
**taxTotalMinor** | **int** |  | [optional] 
**grandTotalMinor** | **int** |  | [optional] 
**paidTotalMinor** | **int** |  | [optional] 
**dueTotalMinor** | **int** |  | [optional] 
**negativeStockAcknowledged** | **bool** |  | [optional] 
**negativeStockReason** | **String** |  | [optional] 
**source_** | **String** |  | [optional] 
**postedAt** | [**DateTime**](DateTime.md) |  | 
**reversalReason** | **String** |  | [optional] 
**reversedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**lines** | [**List<SaleLine>**](SaleLine.md) |  | [readonly] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


