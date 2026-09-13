# openapi.model.Product

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | [readonly] 
**business** | **String** |  | 
**name** | **String** |  | 
**sku** | **String** |  | [optional] 
**baseUnit** | [**BaseUnitEnum**](BaseUnitEnum.md) |  | [optional] 
**trackInventory** | **bool** |  | [optional] 
**hsnSac** | **String** |  | [optional] 
**taxRateBps** | **int** |  | [optional] 
**lowStockThreshold** | **double** |  | [optional] 
**isActive** | **bool** |  | [optional] 
**defaultPackId** | **String** |  | [readonly] 
**stockQuantity** | **String** |  | [readonly] 
**isLowStock** | **String** |  | [readonly] 
**packs** | [**List<ProductPack>**](ProductPack.md) |  | [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


