# openapi.api.ApiApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1AssistantProposalsCancelCreate**](ApiApi.md#apiv1assistantproposalscancelcreate) | **POST** /api/v1/assistant/proposals/{id}/cancel/ | 
[**apiV1AssistantProposalsConfirmCreate**](ApiApi.md#apiv1assistantproposalsconfirmcreate) | **POST** /api/v1/assistant/proposals/{id}/confirm/ | 
[**apiV1AssistantProposalsList**](ApiApi.md#apiv1assistantproposalslist) | **GET** /api/v1/assistant/proposals/ | 
[**apiV1AssistantProposalsRetrieve**](ApiApi.md#apiv1assistantproposalsretrieve) | **GET** /api/v1/assistant/proposals/{id}/ | 
[**apiV1AssistantProposalsReviseCreate**](ApiApi.md#apiv1assistantproposalsrevisecreate) | **POST** /api/v1/assistant/proposals/{id}/revise/ | 
[**apiV1AssistantProposalsRevisionsRetrieve**](ApiApi.md#apiv1assistantproposalsrevisionsretrieve) | **GET** /api/v1/assistant/proposals/{id}/revisions/ | 
[**apiV1AttachmentsPresignCreate**](ApiApi.md#apiv1attachmentspresigncreate) | **POST** /api/v1/attachments/presign/ | 
[**apiV1AttachmentsRetrieve**](ApiApi.md#apiv1attachmentsretrieve) | **GET** /api/v1/attachments/ | 
[**apiV1AttachmentsRetrieve2**](ApiApi.md#apiv1attachmentsretrieve2) | **GET** /api/v1/attachments/{id}/ | 
[**apiV1AuthLoginCreate**](ApiApi.md#apiv1authlogincreate) | **POST** /api/v1/auth/login/ | 
[**apiV1AuthLogoutAllCreate**](ApiApi.md#apiv1authlogoutallcreate) | **POST** /api/v1/auth/logout-all/ | 
[**apiV1AuthLogoutCreate**](ApiApi.md#apiv1authlogoutcreate) | **POST** /api/v1/auth/logout/ | 
[**apiV1AuthOtpSendCreate**](ApiApi.md#apiv1authotpsendcreate) | **POST** /api/v1/auth/otp/send/ | 
[**apiV1AuthOtpVerifyCreate**](ApiApi.md#apiv1authotpverifycreate) | **POST** /api/v1/auth/otp/verify/ | 
[**apiV1AuthPasswordChangeCreate**](ApiApi.md#apiv1authpasswordchangecreate) | **POST** /api/v1/auth/password/change/ | 
[**apiV1AuthPasswordResetConfirmCreate**](ApiApi.md#apiv1authpasswordresetconfirmcreate) | **POST** /api/v1/auth/password/reset/confirm/ | 
[**apiV1AuthPasswordResetCreate**](ApiApi.md#apiv1authpasswordresetcreate) | **POST** /api/v1/auth/password/reset/ | 
[**apiV1AuthRefreshCreate**](ApiApi.md#apiv1authrefreshcreate) | **POST** /api/v1/auth/refresh/ | 
[**apiV1AuthSignupCreate**](ApiApi.md#apiv1authsignupcreate) | **POST** /api/v1/auth/signup/ | 
[**apiV1BootstrapRetrieve**](ApiApi.md#apiv1bootstrapretrieve) | **GET** /api/v1/bootstrap/ | 
[**apiV1BusinessesCreate**](ApiApi.md#apiv1businessescreate) | **POST** /api/v1/businesses/ | 
[**apiV1BusinessesList**](ApiApi.md#apiv1businesseslist) | **GET** /api/v1/businesses/ | 
[**apiV1BusinessesPartialUpdate**](ApiApi.md#apiv1businessespartialupdate) | **PATCH** /api/v1/businesses/{id}/ | 
[**apiV1BusinessesRetrieve**](ApiApi.md#apiv1businessesretrieve) | **GET** /api/v1/businesses/{id}/ | 
[**apiV1BusinessesUpdate**](ApiApi.md#apiv1businessesupdate) | **PUT** /api/v1/businesses/{id}/ | 
[**apiV1DevicesCreate**](ApiApi.md#apiv1devicescreate) | **POST** /api/v1/devices/ | 
[**apiV1DevicesDestroy**](ApiApi.md#apiv1devicesdestroy) | **DELETE** /api/v1/devices/{id}/ | 
[**apiV1DevicesRetrieve**](ApiApi.md#apiv1devicesretrieve) | **GET** /api/v1/devices/ | 
[**apiV1ExpensesCreate**](ApiApi.md#apiv1expensescreate) | **POST** /api/v1/expenses/ | 
[**apiV1ExpensesList**](ApiApi.md#apiv1expenseslist) | **GET** /api/v1/expenses/ | 
[**apiV1ExpensesRetrieve**](ApiApi.md#apiv1expensesretrieve) | **GET** /api/v1/expenses/{id}/ | 
[**apiV1ExpensesReverseCreate**](ApiApi.md#apiv1expensesreversecreate) | **POST** /api/v1/expenses/{id}/reverse/ | 
[**apiV1ExportsRetrieve**](ApiApi.md#apiv1exportsretrieve) | **GET** /api/v1/exports/ | 
[**apiV1ExportsRetrieve2**](ApiApi.md#apiv1exportsretrieve2) | **GET** /api/v1/exports/{id}/ | 
[**apiV1GstRegistrationsCreate**](ApiApi.md#apiv1gstregistrationscreate) | **POST** /api/v1/gst-registrations/ | 
[**apiV1GstRegistrationsList**](ApiApi.md#apiv1gstregistrationslist) | **GET** /api/v1/gst-registrations/ | 
[**apiV1GstRegistrationsPartialUpdate**](ApiApi.md#apiv1gstregistrationspartialupdate) | **PATCH** /api/v1/gst-registrations/{id}/ | 
[**apiV1GstRegistrationsRetrieve**](ApiApi.md#apiv1gstregistrationsretrieve) | **GET** /api/v1/gst-registrations/{id}/ | 
[**apiV1InvitationsAcceptCreate**](ApiApi.md#apiv1invitationsacceptcreate) | **POST** /api/v1/invitations/{id}/accept/ | 
[**apiV1InvitationsCreate**](ApiApi.md#apiv1invitationscreate) | **POST** /api/v1/invitations/ | 
[**apiV1InvitationsList**](ApiApi.md#apiv1invitationslist) | **GET** /api/v1/invitations/ | 
[**apiV1InvitationsRetrieve**](ApiApi.md#apiv1invitationsretrieve) | **GET** /api/v1/invitations/{id}/ | 
[**apiV1InvitationsRevokeCreate**](ApiApi.md#apiv1invitationsrevokecreate) | **POST** /api/v1/invitations/{id}/revoke/ | 
[**apiV1LocationsCreate**](ApiApi.md#apiv1locationscreate) | **POST** /api/v1/locations/ | 
[**apiV1LocationsDestroy**](ApiApi.md#apiv1locationsdestroy) | **DELETE** /api/v1/locations/{id}/ | 
[**apiV1LocationsList**](ApiApi.md#apiv1locationslist) | **GET** /api/v1/locations/ | 
[**apiV1LocationsPartialUpdate**](ApiApi.md#apiv1locationspartialupdate) | **PATCH** /api/v1/locations/{id}/ | 
[**apiV1LocationsRetrieve**](ApiApi.md#apiv1locationsretrieve) | **GET** /api/v1/locations/{id}/ | 
[**apiV1LocationsUpdate**](ApiApi.md#apiv1locationsupdate) | **PUT** /api/v1/locations/{id}/ | 
[**apiV1MePartialUpdate**](ApiApi.md#apiv1mepartialupdate) | **PATCH** /api/v1/me/ | 
[**apiV1MeRetrieve**](ApiApi.md#apiv1meretrieve) | **GET** /api/v1/me/ | 
[**apiV1MembershipsCreate**](ApiApi.md#apiv1membershipscreate) | **POST** /api/v1/memberships/ | 
[**apiV1MembershipsDestroy**](ApiApi.md#apiv1membershipsdestroy) | **DELETE** /api/v1/memberships/{id}/ | 
[**apiV1MembershipsList**](ApiApi.md#apiv1membershipslist) | **GET** /api/v1/memberships/ | 
[**apiV1MembershipsPartialUpdate**](ApiApi.md#apiv1membershipspartialupdate) | **PATCH** /api/v1/memberships/{id}/ | 
[**apiV1MembershipsRetrieve**](ApiApi.md#apiv1membershipsretrieve) | **GET** /api/v1/memberships/{id}/ | 
[**apiV1MembershipsRevokeCreate**](ApiApi.md#apiv1membershipsrevokecreate) | **POST** /api/v1/memberships/{id}/revoke/ | 
[**apiV1MembershipsUpdate**](ApiApi.md#apiv1membershipsupdate) | **PUT** /api/v1/memberships/{id}/ | 
[**apiV1NotificationPreferencesPartialUpdate**](ApiApi.md#apiv1notificationpreferencespartialupdate) | **PATCH** /api/v1/notification-preferences/ | 
[**apiV1NotificationPreferencesRetrieve**](ApiApi.md#apiv1notificationpreferencesretrieve) | **GET** /api/v1/notification-preferences/ | 
[**apiV1PartiesCreate**](ApiApi.md#apiv1partiescreate) | **POST** /api/v1/parties/ | 
[**apiV1PartiesDestroy**](ApiApi.md#apiv1partiesdestroy) | **DELETE** /api/v1/parties/{id}/ | 
[**apiV1PartiesList**](ApiApi.md#apiv1partieslist) | **GET** /api/v1/parties/ | 
[**apiV1PartiesPartialUpdate**](ApiApi.md#apiv1partiespartialupdate) | **PATCH** /api/v1/parties/{id}/ | 
[**apiV1PartiesRetrieve**](ApiApi.md#apiv1partiesretrieve) | **GET** /api/v1/parties/{id}/ | 
[**apiV1PartiesUpdate**](ApiApi.md#apiv1partiesupdate) | **PUT** /api/v1/parties/{id}/ | 
[**apiV1PartyLedgerOpeningBalancesCreate**](ApiApi.md#apiv1partyledgeropeningbalancescreate) | **POST** /api/v1/party-ledger/opening-balances/ | 
[**apiV1PaymentsCreate**](ApiApi.md#apiv1paymentscreate) | **POST** /api/v1/payments/ | 
[**apiV1PaymentsList**](ApiApi.md#apiv1paymentslist) | **GET** /api/v1/payments/ | 
[**apiV1PaymentsRetrieve**](ApiApi.md#apiv1paymentsretrieve) | **GET** /api/v1/payments/{id}/ | 
[**apiV1PaymentsReverseCreate**](ApiApi.md#apiv1paymentsreversecreate) | **POST** /api/v1/payments/{id}/reverse/ | 
[**apiV1ProductsCreate**](ApiApi.md#apiv1productscreate) | **POST** /api/v1/products/ | 
[**apiV1ProductsDestroy**](ApiApi.md#apiv1productsdestroy) | **DELETE** /api/v1/products/{id}/ | 
[**apiV1ProductsList**](ApiApi.md#apiv1productslist) | **GET** /api/v1/products/ | 
[**apiV1ProductsPartialUpdate**](ApiApi.md#apiv1productspartialupdate) | **PATCH** /api/v1/products/{id}/ | 
[**apiV1ProductsRetrieve**](ApiApi.md#apiv1productsretrieve) | **GET** /api/v1/products/{id}/ | 
[**apiV1ProductsUpdate**](ApiApi.md#apiv1productsupdate) | **PUT** /api/v1/products/{id}/ | 
[**apiV1PurchasesCreate**](ApiApi.md#apiv1purchasescreate) | **POST** /api/v1/purchases/ | 
[**apiV1PurchasesList**](ApiApi.md#apiv1purchaseslist) | **GET** /api/v1/purchases/ | 
[**apiV1PurchasesRetrieve**](ApiApi.md#apiv1purchasesretrieve) | **GET** /api/v1/purchases/{id}/ | 
[**apiV1PurchasesReverseCreate**](ApiApi.md#apiv1purchasesreversecreate) | **POST** /api/v1/purchases/{id}/reverse/ | 
[**apiV1RemindersRetrieve**](ApiApi.md#apiv1remindersretrieve) | **GET** /api/v1/reminders/ | 
[**apiV1RemindersRetrieve2**](ApiApi.md#apiv1remindersretrieve2) | **GET** /api/v1/reminders/{id}/ | 
[**apiV1RemindersSuggestionsRetrieve**](ApiApi.md#apiv1reminderssuggestionsretrieve) | **GET** /api/v1/reminders/suggestions/ | 
[**apiV1ReportsDashboardRetrieve**](ApiApi.md#apiv1reportsdashboardretrieve) | **GET** /api/v1/reports/dashboard/ | 
[**apiV1ReportsDayBookRetrieve**](ApiApi.md#apiv1reportsdaybookretrieve) | **GET** /api/v1/reports/day-book/ | 
[**apiV1ReportsExportRetrieve**](ApiApi.md#apiv1reportsexportretrieve) | **GET** /api/v1/reports/export/ | 
[**apiV1ReportsGstRetrieve**](ApiApi.md#apiv1reportsgstretrieve) | **GET** /api/v1/reports/gst/ | 
[**apiV1ReportsPartyBalancesRetrieve**](ApiApi.md#apiv1reportspartybalancesretrieve) | **GET** /api/v1/reports/party-balances/ | 
[**apiV1ReportsPartyLedgerRetrieve**](ApiApi.md#apiv1reportspartyledgerretrieve) | **GET** /api/v1/reports/party-ledger/ | 
[**apiV1ReportsPurchasesRetrieve**](ApiApi.md#apiv1reportspurchasesretrieve) | **GET** /api/v1/reports/purchases/ | 
[**apiV1ReportsSalesRetrieve**](ApiApi.md#apiv1reportssalesretrieve) | **GET** /api/v1/reports/sales/ | 
[**apiV1ReportsStockRetrieve**](ApiApi.md#apiv1reportsstockretrieve) | **GET** /api/v1/reports/stock/ | 
[**apiV1ReportsStockValuationRetrieve**](ApiApi.md#apiv1reportsstockvaluationretrieve) | **GET** /api/v1/reports/stock-valuation/ | 
[**apiV1SalesCreate**](ApiApi.md#apiv1salescreate) | **POST** /api/v1/sales/ | 
[**apiV1SalesList**](ApiApi.md#apiv1saleslist) | **GET** /api/v1/sales/ | 
[**apiV1SalesRetrieve**](ApiApi.md#apiv1salesretrieve) | **GET** /api/v1/sales/{id}/ | 
[**apiV1SalesReverseCreate**](ApiApi.md#apiv1salesreversecreate) | **POST** /api/v1/sales/{id}/reverse/ | 
[**apiV1StockAdjustmentsCreate**](ApiApi.md#apiv1stockadjustmentscreate) | **POST** /api/v1/stock/adjustments/ | 
[**apiV1StockMovementsRetrieve**](ApiApi.md#apiv1stockmovementsretrieve) | **GET** /api/v1/stock/movements/ | 
[**apiV1TransfersCreate**](ApiApi.md#apiv1transferscreate) | **POST** /api/v1/transfers/ | 
[**apiV1TransfersList**](ApiApi.md#apiv1transferslist) | **GET** /api/v1/transfers/ | 
[**apiV1TransfersRetrieve**](ApiApi.md#apiv1transfersretrieve) | **GET** /api/v1/transfers/{id}/ | 
[**apiV1TransfersReverseCreate**](ApiApi.md#apiv1transfersreversecreate) | **POST** /api/v1/transfers/{id}/reverse/ | 


# **apiV1AssistantProposalsCancelCreate**
> AssistantProposal apiV1AssistantProposalsCancelCreate(id, assistantProposal)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 
final assistantProposal = AssistantProposal(); // AssistantProposal | 

try {
    final result = api_instance.apiV1AssistantProposalsCancelCreate(id, assistantProposal);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1AssistantProposalsCancelCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **assistantProposal** | [**AssistantProposal**](AssistantProposal.md)|  | [optional] 

### Return type

[**AssistantProposal**](AssistantProposal.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AssistantProposalsConfirmCreate**
> AssistantProposal apiV1AssistantProposalsConfirmCreate(id, assistantProposal)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 
final assistantProposal = AssistantProposal(); // AssistantProposal | 

try {
    final result = api_instance.apiV1AssistantProposalsConfirmCreate(id, assistantProposal);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1AssistantProposalsConfirmCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **assistantProposal** | [**AssistantProposal**](AssistantProposal.md)|  | [optional] 

### Return type

[**AssistantProposal**](AssistantProposal.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AssistantProposalsList**
> List<AssistantProposal> apiV1AssistantProposalsList()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    final result = api_instance.apiV1AssistantProposalsList();
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1AssistantProposalsList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<AssistantProposal>**](AssistantProposal.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AssistantProposalsRetrieve**
> AssistantProposal apiV1AssistantProposalsRetrieve(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 

try {
    final result = api_instance.apiV1AssistantProposalsRetrieve(id);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1AssistantProposalsRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**AssistantProposal**](AssistantProposal.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AssistantProposalsReviseCreate**
> AssistantProposal apiV1AssistantProposalsReviseCreate(id, assistantProposal)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 
final assistantProposal = AssistantProposal(); // AssistantProposal | 

try {
    final result = api_instance.apiV1AssistantProposalsReviseCreate(id, assistantProposal);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1AssistantProposalsReviseCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **assistantProposal** | [**AssistantProposal**](AssistantProposal.md)|  | [optional] 

### Return type

[**AssistantProposal**](AssistantProposal.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AssistantProposalsRevisionsRetrieve**
> AssistantProposal apiV1AssistantProposalsRevisionsRetrieve(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 

try {
    final result = api_instance.apiV1AssistantProposalsRevisionsRetrieve(id);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1AssistantProposalsRevisionsRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**AssistantProposal**](AssistantProposal.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AttachmentsPresignCreate**
> apiV1AttachmentsPresignCreate()



Dev presign: direct multipart upload instructions.  Production Supabase private-storage signing plugs in here behind the same response shape; until bucket credentials exist the client uploads straight to ``upload_url``. The shape (mode/upload_url/key) is what clients code against.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1AttachmentsPresignCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1AttachmentsPresignCreate: $e\n');
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

# **apiV1AttachmentsRetrieve**
> apiV1AttachmentsRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1AttachmentsRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1AttachmentsRetrieve: $e\n');
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

# **apiV1AttachmentsRetrieve2**
> apiV1AttachmentsRetrieve2(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.apiV1AttachmentsRetrieve2(id);
} catch (e) {
    print('Exception when calling ApiApi->apiV1AttachmentsRetrieve2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AuthLoginCreate**
> apiV1AuthLoginCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1AuthLoginCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1AuthLoginCreate: $e\n');
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

# **apiV1AuthLogoutAllCreate**
> apiV1AuthLogoutAllCreate()



Revoke every session for the caller on all devices.  Records a revocation timestamp; access and refresh tokens issued at or before it are rejected everywhere (see SessionRevocation). The presented tokens are additionally blacklisted so they fail fast with a clear code.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1AuthLogoutAllCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1AuthLogoutAllCreate: $e\n');
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

# **apiV1AuthLogoutCreate**
> apiV1AuthLogoutCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1AuthLogoutCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1AuthLogoutCreate: $e\n');
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

# **apiV1AuthOtpSendCreate**
> apiV1AuthOtpSendCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1AuthOtpSendCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1AuthOtpSendCreate: $e\n');
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

# **apiV1AuthOtpVerifyCreate**
> apiV1AuthOtpVerifyCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1AuthOtpVerifyCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1AuthOtpVerifyCreate: $e\n');
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

# **apiV1AuthPasswordChangeCreate**
> apiV1AuthPasswordChangeCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1AuthPasswordChangeCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1AuthPasswordChangeCreate: $e\n');
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

# **apiV1AuthPasswordResetConfirmCreate**
> apiV1AuthPasswordResetConfirmCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1AuthPasswordResetConfirmCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1AuthPasswordResetConfirmCreate: $e\n');
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

# **apiV1AuthPasswordResetCreate**
> apiV1AuthPasswordResetCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1AuthPasswordResetCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1AuthPasswordResetCreate: $e\n');
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

# **apiV1AuthRefreshCreate**
> apiV1AuthRefreshCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1AuthRefreshCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1AuthRefreshCreate: $e\n');
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

# **apiV1AuthSignupCreate**
> apiV1AuthSignupCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1AuthSignupCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1AuthSignupCreate: $e\n');
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

# **apiV1BootstrapRetrieve**
> apiV1BootstrapRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1BootstrapRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1BootstrapRetrieve: $e\n');
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

# **apiV1BusinessesCreate**
> Business apiV1BusinessesCreate(business)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final business = Business(); // Business | 

try {
    final result = api_instance.apiV1BusinessesCreate(business);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1BusinessesCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **business** | [**Business**](Business.md)|  | 

### Return type

[**Business**](Business.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1BusinessesList**
> List<Business> apiV1BusinessesList()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    final result = api_instance.apiV1BusinessesList();
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1BusinessesList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<Business>**](Business.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1BusinessesPartialUpdate**
> Business apiV1BusinessesPartialUpdate(id, patchedBusiness)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 
final patchedBusiness = PatchedBusiness(); // PatchedBusiness | 

try {
    final result = api_instance.apiV1BusinessesPartialUpdate(id, patchedBusiness);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1BusinessesPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **patchedBusiness** | [**PatchedBusiness**](PatchedBusiness.md)|  | [optional] 

### Return type

[**Business**](Business.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1BusinessesRetrieve**
> Business apiV1BusinessesRetrieve(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 

try {
    final result = api_instance.apiV1BusinessesRetrieve(id);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1BusinessesRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Business**](Business.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1BusinessesUpdate**
> Business apiV1BusinessesUpdate(id, business)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 
final business = Business(); // Business | 

try {
    final result = api_instance.apiV1BusinessesUpdate(id, business);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1BusinessesUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **business** | [**Business**](Business.md)|  | 

### Return type

[**Business**](Business.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1DevicesCreate**
> apiV1DevicesCreate()



Register/list the caller's own push device tokens.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1DevicesCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1DevicesCreate: $e\n');
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

# **apiV1DevicesDestroy**
> apiV1DevicesDestroy(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 56; // int | 

try {
    api_instance.apiV1DevicesDestroy(id);
} catch (e) {
    print('Exception when calling ApiApi->apiV1DevicesDestroy: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1DevicesRetrieve**
> apiV1DevicesRetrieve()



Register/list the caller's own push device tokens.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1DevicesRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1DevicesRetrieve: $e\n');
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

# **apiV1ExpensesCreate**
> apiV1ExpensesCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1ExpensesCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1ExpensesCreate: $e\n');
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

# **apiV1ExpensesList**
> List<Expense> apiV1ExpensesList()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    final result = api_instance.apiV1ExpensesList();
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1ExpensesList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<Expense>**](Expense.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ExpensesRetrieve**
> Expense apiV1ExpensesRetrieve(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this expense.

try {
    final result = api_instance.apiV1ExpensesRetrieve(id);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1ExpensesRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this expense. | 

### Return type

[**Expense**](Expense.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ExpensesReverseCreate**
> Expense apiV1ExpensesReverseCreate(id, expense)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this expense.
final expense = Expense(); // Expense | 

try {
    final result = api_instance.apiV1ExpensesReverseCreate(id, expense);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1ExpensesReverseCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this expense. | 
 **expense** | [**Expense**](Expense.md)|  | 

### Return type

[**Expense**](Expense.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ExportsRetrieve**
> apiV1ExportsRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1ExportsRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1ExportsRetrieve: $e\n');
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

# **apiV1ExportsRetrieve2**
> apiV1ExportsRetrieve2(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.apiV1ExportsRetrieve2(id);
} catch (e) {
    print('Exception when calling ApiApi->apiV1ExportsRetrieve2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1GstRegistrationsCreate**
> GSTRegistration apiV1GstRegistrationsCreate(gSTRegistration)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final gSTRegistration = GSTRegistration(); // GSTRegistration | 

try {
    final result = api_instance.apiV1GstRegistrationsCreate(gSTRegistration);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1GstRegistrationsCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **gSTRegistration** | [**GSTRegistration**](GSTRegistration.md)|  | 

### Return type

[**GSTRegistration**](GSTRegistration.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1GstRegistrationsList**
> List<GSTRegistration> apiV1GstRegistrationsList()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    final result = api_instance.apiV1GstRegistrationsList();
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1GstRegistrationsList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<GSTRegistration>**](GSTRegistration.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1GstRegistrationsPartialUpdate**
> GSTRegistration apiV1GstRegistrationsPartialUpdate(id, patchedGSTRegistration)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this gst registration.
final patchedGSTRegistration = PatchedGSTRegistration(); // PatchedGSTRegistration | 

try {
    final result = api_instance.apiV1GstRegistrationsPartialUpdate(id, patchedGSTRegistration);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1GstRegistrationsPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this gst registration. | 
 **patchedGSTRegistration** | [**PatchedGSTRegistration**](PatchedGSTRegistration.md)|  | [optional] 

### Return type

[**GSTRegistration**](GSTRegistration.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1GstRegistrationsRetrieve**
> GSTRegistration apiV1GstRegistrationsRetrieve(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this gst registration.

try {
    final result = api_instance.apiV1GstRegistrationsRetrieve(id);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1GstRegistrationsRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this gst registration. | 

### Return type

[**GSTRegistration**](GSTRegistration.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1InvitationsAcceptCreate**
> Invitation apiV1InvitationsAcceptCreate(id, invitation)



Join the invited business.  The invitation token proves the invite; the verified phone number must match the invitation. The invitee is usually not a member yet, so the single invitation row is read under a staff scope that is restored immediately; acceptance still requires the unguessable token plus the matching verified phone number. The business is then added to the connection scope exactly like onboarding, so the membership insert passes the database check.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 
final invitation = Invitation(); // Invitation | 

try {
    final result = api_instance.apiV1InvitationsAcceptCreate(id, invitation);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1InvitationsAcceptCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **invitation** | [**Invitation**](Invitation.md)|  | 

### Return type

[**Invitation**](Invitation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1InvitationsCreate**
> Invitation apiV1InvitationsCreate(invitation)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final invitation = Invitation(); // Invitation | 

try {
    final result = api_instance.apiV1InvitationsCreate(invitation);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1InvitationsCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invitation** | [**Invitation**](Invitation.md)|  | 

### Return type

[**Invitation**](Invitation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1InvitationsList**
> List<Invitation> apiV1InvitationsList()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    final result = api_instance.apiV1InvitationsList();
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1InvitationsList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<Invitation>**](Invitation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1InvitationsRetrieve**
> Invitation apiV1InvitationsRetrieve(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 

try {
    final result = api_instance.apiV1InvitationsRetrieve(id);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1InvitationsRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Invitation**](Invitation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1InvitationsRevokeCreate**
> Invitation apiV1InvitationsRevokeCreate(id, invitation)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 
final invitation = Invitation(); // Invitation | 

try {
    final result = api_instance.apiV1InvitationsRevokeCreate(id, invitation);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1InvitationsRevokeCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **invitation** | [**Invitation**](Invitation.md)|  | 

### Return type

[**Invitation**](Invitation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1LocationsCreate**
> Location apiV1LocationsCreate(location)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final location = Location(); // Location | 

try {
    final result = api_instance.apiV1LocationsCreate(location);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1LocationsCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **location** | [**Location**](Location.md)|  | 

### Return type

[**Location**](Location.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1LocationsDestroy**
> apiV1LocationsDestroy(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this location.

try {
    api_instance.apiV1LocationsDestroy(id);
} catch (e) {
    print('Exception when calling ApiApi->apiV1LocationsDestroy: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this location. | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1LocationsList**
> List<Location> apiV1LocationsList()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    final result = api_instance.apiV1LocationsList();
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1LocationsList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<Location>**](Location.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1LocationsPartialUpdate**
> Location apiV1LocationsPartialUpdate(id, patchedLocation)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this location.
final patchedLocation = PatchedLocation(); // PatchedLocation | 

try {
    final result = api_instance.apiV1LocationsPartialUpdate(id, patchedLocation);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1LocationsPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this location. | 
 **patchedLocation** | [**PatchedLocation**](PatchedLocation.md)|  | [optional] 

### Return type

[**Location**](Location.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1LocationsRetrieve**
> Location apiV1LocationsRetrieve(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this location.

try {
    final result = api_instance.apiV1LocationsRetrieve(id);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1LocationsRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this location. | 

### Return type

[**Location**](Location.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1LocationsUpdate**
> Location apiV1LocationsUpdate(id, location)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this location.
final location = Location(); // Location | 

try {
    final result = api_instance.apiV1LocationsUpdate(id, location);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1LocationsUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this location. | 
 **location** | [**Location**](Location.md)|  | 

### Return type

[**Location**](Location.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1MePartialUpdate**
> apiV1MePartialUpdate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1MePartialUpdate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1MePartialUpdate: $e\n');
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

# **apiV1MeRetrieve**
> apiV1MeRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1MeRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1MeRetrieve: $e\n');
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

# **apiV1MembershipsCreate**
> Membership apiV1MembershipsCreate(membership)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final membership = Membership(); // Membership | 

try {
    final result = api_instance.apiV1MembershipsCreate(membership);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1MembershipsCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **membership** | [**Membership**](Membership.md)|  | 

### Return type

[**Membership**](Membership.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1MembershipsDestroy**
> apiV1MembershipsDestroy(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 

try {
    api_instance.apiV1MembershipsDestroy(id);
} catch (e) {
    print('Exception when calling ApiApi->apiV1MembershipsDestroy: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1MembershipsList**
> List<Membership> apiV1MembershipsList()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    final result = api_instance.apiV1MembershipsList();
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1MembershipsList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<Membership>**](Membership.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1MembershipsPartialUpdate**
> Membership apiV1MembershipsPartialUpdate(id, patchedMembership)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 
final patchedMembership = PatchedMembership(); // PatchedMembership | 

try {
    final result = api_instance.apiV1MembershipsPartialUpdate(id, patchedMembership);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1MembershipsPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **patchedMembership** | [**PatchedMembership**](PatchedMembership.md)|  | [optional] 

### Return type

[**Membership**](Membership.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1MembershipsRetrieve**
> Membership apiV1MembershipsRetrieve(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 

try {
    final result = api_instance.apiV1MembershipsRetrieve(id);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1MembershipsRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Membership**](Membership.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1MembershipsRevokeCreate**
> Membership apiV1MembershipsRevokeCreate(id, membership)



Deactivate a membership and force the member to sign in again.  Deactivation alone already blocks the business (every endpoint checks membership), but without session revocation the removed member keeps a valid identity token. Revoking sessions closes that gap; the member keeps access to their other businesses after signing in again.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 
final membership = Membership(); // Membership | 

try {
    final result = api_instance.apiV1MembershipsRevokeCreate(id, membership);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1MembershipsRevokeCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **membership** | [**Membership**](Membership.md)|  | 

### Return type

[**Membership**](Membership.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1MembershipsUpdate**
> Membership apiV1MembershipsUpdate(id, membership)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = id_example; // String | 
final membership = Membership(); // Membership | 

try {
    final result = api_instance.apiV1MembershipsUpdate(id, membership);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1MembershipsUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **membership** | [**Membership**](Membership.md)|  | 

### Return type

[**Membership**](Membership.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1NotificationPreferencesPartialUpdate**
> apiV1NotificationPreferencesPartialUpdate()



Get or update the caller's notification toggles for one business.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1NotificationPreferencesPartialUpdate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1NotificationPreferencesPartialUpdate: $e\n');
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

# **apiV1NotificationPreferencesRetrieve**
> apiV1NotificationPreferencesRetrieve()



Get or update the caller's notification toggles for one business.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1NotificationPreferencesRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1NotificationPreferencesRetrieve: $e\n');
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

# **apiV1PartiesCreate**
> Party apiV1PartiesCreate(party)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final party = Party(); // Party | 

try {
    final result = api_instance.apiV1PartiesCreate(party);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1PartiesCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **party** | [**Party**](Party.md)|  | 

### Return type

[**Party**](Party.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PartiesDestroy**
> apiV1PartiesDestroy(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this party.

try {
    api_instance.apiV1PartiesDestroy(id);
} catch (e) {
    print('Exception when calling ApiApi->apiV1PartiesDestroy: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this party. | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PartiesList**
> List<Party> apiV1PartiesList()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    final result = api_instance.apiV1PartiesList();
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1PartiesList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<Party>**](Party.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PartiesPartialUpdate**
> Party apiV1PartiesPartialUpdate(id, patchedParty)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this party.
final patchedParty = PatchedParty(); // PatchedParty | 

try {
    final result = api_instance.apiV1PartiesPartialUpdate(id, patchedParty);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1PartiesPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this party. | 
 **patchedParty** | [**PatchedParty**](PatchedParty.md)|  | [optional] 

### Return type

[**Party**](Party.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PartiesRetrieve**
> Party apiV1PartiesRetrieve(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this party.

try {
    final result = api_instance.apiV1PartiesRetrieve(id);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1PartiesRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this party. | 

### Return type

[**Party**](Party.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PartiesUpdate**
> Party apiV1PartiesUpdate(id, party)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this party.
final party = Party(); // Party | 

try {
    final result = api_instance.apiV1PartiesUpdate(id, party);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1PartiesUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this party. | 
 **party** | [**Party**](Party.md)|  | 

### Return type

[**Party**](Party.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PartyLedgerOpeningBalancesCreate**
> apiV1PartyLedgerOpeningBalancesCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1PartyLedgerOpeningBalancesCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1PartyLedgerOpeningBalancesCreate: $e\n');
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

# **apiV1PaymentsCreate**
> apiV1PaymentsCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1PaymentsCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1PaymentsCreate: $e\n');
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

# **apiV1PaymentsList**
> List<Payment> apiV1PaymentsList()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    final result = api_instance.apiV1PaymentsList();
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1PaymentsList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<Payment>**](Payment.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PaymentsRetrieve**
> Payment apiV1PaymentsRetrieve(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this payment.

try {
    final result = api_instance.apiV1PaymentsRetrieve(id);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1PaymentsRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this payment. | 

### Return type

[**Payment**](Payment.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PaymentsReverseCreate**
> Payment apiV1PaymentsReverseCreate(id, payment)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this payment.
final payment = Payment(); // Payment | 

try {
    final result = api_instance.apiV1PaymentsReverseCreate(id, payment);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1PaymentsReverseCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this payment. | 
 **payment** | [**Payment**](Payment.md)|  | 

### Return type

[**Payment**](Payment.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ProductsCreate**
> Product apiV1ProductsCreate(product)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final product = Product(); // Product | 

try {
    final result = api_instance.apiV1ProductsCreate(product);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1ProductsCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **product** | [**Product**](Product.md)|  | 

### Return type

[**Product**](Product.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ProductsDestroy**
> apiV1ProductsDestroy(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this product.

try {
    api_instance.apiV1ProductsDestroy(id);
} catch (e) {
    print('Exception when calling ApiApi->apiV1ProductsDestroy: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this product. | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ProductsList**
> List<Product> apiV1ProductsList()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    final result = api_instance.apiV1ProductsList();
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1ProductsList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<Product>**](Product.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ProductsPartialUpdate**
> Product apiV1ProductsPartialUpdate(id, patchedProduct)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this product.
final patchedProduct = PatchedProduct(); // PatchedProduct | 

try {
    final result = api_instance.apiV1ProductsPartialUpdate(id, patchedProduct);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1ProductsPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this product. | 
 **patchedProduct** | [**PatchedProduct**](PatchedProduct.md)|  | [optional] 

### Return type

[**Product**](Product.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ProductsRetrieve**
> Product apiV1ProductsRetrieve(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this product.

try {
    final result = api_instance.apiV1ProductsRetrieve(id);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1ProductsRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this product. | 

### Return type

[**Product**](Product.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ProductsUpdate**
> Product apiV1ProductsUpdate(id, product)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this product.
final product = Product(); // Product | 

try {
    final result = api_instance.apiV1ProductsUpdate(id, product);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1ProductsUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this product. | 
 **product** | [**Product**](Product.md)|  | 

### Return type

[**Product**](Product.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PurchasesCreate**
> apiV1PurchasesCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1PurchasesCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1PurchasesCreate: $e\n');
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

# **apiV1PurchasesList**
> List<Purchase> apiV1PurchasesList()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    final result = api_instance.apiV1PurchasesList();
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1PurchasesList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<Purchase>**](Purchase.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PurchasesRetrieve**
> Purchase apiV1PurchasesRetrieve(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this purchase.

try {
    final result = api_instance.apiV1PurchasesRetrieve(id);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1PurchasesRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this purchase. | 

### Return type

[**Purchase**](Purchase.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PurchasesReverseCreate**
> Purchase apiV1PurchasesReverseCreate(id, purchase)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this purchase.
final purchase = Purchase(); // Purchase | 

try {
    final result = api_instance.apiV1PurchasesReverseCreate(id, purchase);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1PurchasesReverseCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this purchase. | 
 **purchase** | [**Purchase**](Purchase.md)|  | 

### Return type

[**Purchase**](Purchase.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RemindersRetrieve**
> apiV1RemindersRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1RemindersRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1RemindersRetrieve: $e\n');
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

# **apiV1RemindersRetrieve2**
> apiV1RemindersRetrieve2(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.apiV1RemindersRetrieve2(id);
} catch (e) {
    print('Exception when calling ApiApi->apiV1RemindersRetrieve2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RemindersSuggestionsRetrieve**
> apiV1RemindersSuggestionsRetrieve()



Computed follow-ups: overdue receivables first, then low stock.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1RemindersSuggestionsRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1RemindersSuggestionsRetrieve: $e\n');
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

# **apiV1ReportsDashboardRetrieve**
> apiV1ReportsDashboardRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1ReportsDashboardRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1ReportsDashboardRetrieve: $e\n');
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

# **apiV1ReportsDayBookRetrieve**
> apiV1ReportsDayBookRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1ReportsDayBookRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1ReportsDayBookRetrieve: $e\n');
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

# **apiV1ReportsExportRetrieve**
> apiV1ReportsExportRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1ReportsExportRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1ReportsExportRetrieve: $e\n');
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

# **apiV1ReportsGstRetrieve**
> apiV1ReportsGstRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1ReportsGstRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1ReportsGstRetrieve: $e\n');
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

# **apiV1ReportsPartyBalancesRetrieve**
> apiV1ReportsPartyBalancesRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1ReportsPartyBalancesRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1ReportsPartyBalancesRetrieve: $e\n');
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

# **apiV1ReportsPartyLedgerRetrieve**
> apiV1ReportsPartyLedgerRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1ReportsPartyLedgerRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1ReportsPartyLedgerRetrieve: $e\n');
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

# **apiV1ReportsPurchasesRetrieve**
> apiV1ReportsPurchasesRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1ReportsPurchasesRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1ReportsPurchasesRetrieve: $e\n');
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

# **apiV1ReportsSalesRetrieve**
> apiV1ReportsSalesRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1ReportsSalesRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1ReportsSalesRetrieve: $e\n');
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

# **apiV1ReportsStockRetrieve**
> apiV1ReportsStockRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1ReportsStockRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1ReportsStockRetrieve: $e\n');
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

# **apiV1ReportsStockValuationRetrieve**
> apiV1ReportsStockValuationRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1ReportsStockValuationRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1ReportsStockValuationRetrieve: $e\n');
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

# **apiV1SalesCreate**
> apiV1SalesCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1SalesCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1SalesCreate: $e\n');
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

# **apiV1SalesList**
> List<Sale> apiV1SalesList()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    final result = api_instance.apiV1SalesList();
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1SalesList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<Sale>**](Sale.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1SalesRetrieve**
> Sale apiV1SalesRetrieve(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this sale.

try {
    final result = api_instance.apiV1SalesRetrieve(id);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1SalesRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this sale. | 

### Return type

[**Sale**](Sale.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1SalesReverseCreate**
> Sale apiV1SalesReverseCreate(id, sale)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this sale.
final sale = Sale(); // Sale | 

try {
    final result = api_instance.apiV1SalesReverseCreate(id, sale);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1SalesReverseCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this sale. | 
 **sale** | [**Sale**](Sale.md)|  | 

### Return type

[**Sale**](Sale.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1StockAdjustmentsCreate**
> apiV1StockAdjustmentsCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1StockAdjustmentsCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1StockAdjustmentsCreate: $e\n');
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

# **apiV1StockMovementsRetrieve**
> apiV1StockMovementsRetrieve()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1StockMovementsRetrieve();
} catch (e) {
    print('Exception when calling ApiApi->apiV1StockMovementsRetrieve: $e\n');
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

# **apiV1TransfersCreate**
> apiV1TransfersCreate()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    api_instance.apiV1TransfersCreate();
} catch (e) {
    print('Exception when calling ApiApi->apiV1TransfersCreate: $e\n');
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

# **apiV1TransfersList**
> List<Transfer> apiV1TransfersList()



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();

try {
    final result = api_instance.apiV1TransfersList();
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1TransfersList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<Transfer>**](Transfer.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1TransfersRetrieve**
> Transfer apiV1TransfersRetrieve(id)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this stock transfer.

try {
    final result = api_instance.apiV1TransfersRetrieve(id);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1TransfersRetrieve: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this stock transfer. | 

### Return type

[**Transfer**](Transfer.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1TransfersReverseCreate**
> Transfer apiV1TransfersReverseCreate(id, transfer)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApiApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | A UUID string identifying this stock transfer.
final transfer = Transfer(); // Transfer | 

try {
    final result = api_instance.apiV1TransfersReverseCreate(id, transfer);
    print(result);
} catch (e) {
    print('Exception when calling ApiApi->apiV1TransfersReverseCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| A UUID string identifying this stock transfer. | 
 **transfer** | [**Transfer**](Transfer.md)|  | 

### Return type

[**Transfer**](Transfer.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json, application/x-www-form-urlencoded, multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

