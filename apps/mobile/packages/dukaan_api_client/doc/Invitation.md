# openapi.model.Invitation

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | [readonly] 
**business** | **String** |  | 
**phoneE164** | **String** |  | 
**role** | [**RoleEnum**](RoleEnum.md) |  | 
**locations** | **List<String>** |  | [optional] [default to const []]
**status** | [**InvitationStatusEnum**](InvitationStatusEnum.md) |  | [readonly] 
**expiresAt** | [**DateTime**](DateTime.md) |  | [readonly] 
**createdAt** | [**DateTime**](DateTime.md) |  | [readonly] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


