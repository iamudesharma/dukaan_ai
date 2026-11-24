import 'package:dukaanai_api_client/src/model/assistant_proposal.dart';
import 'package:dukaanai_api_client/src/model/attachment.dart';
import 'package:dukaanai_api_client/src/model/audit_event.dart';
import 'package:dukaanai_api_client/src/model/auth_capabilities.dart';
import 'package:dukaanai_api_client/src/model/auth_token_response.dart';
import 'package:dukaanai_api_client/src/model/auth_user.dart';
import 'package:dukaanai_api_client/src/model/bootstrap.dart';
import 'package:dukaanai_api_client/src/model/bootstrap_business.dart';
import 'package:dukaanai_api_client/src/model/bootstrap_location.dart';
import 'package:dukaanai_api_client/src/model/bootstrap_user.dart';
import 'package:dukaanai_api_client/src/model/business.dart';
import 'package:dukaanai_api_client/src/model/dashboard.dart';
import 'package:dukaanai_api_client/src/model/dashboard_books.dart';
import 'package:dukaanai_api_client/src/model/dashboard_today.dart';
import 'package:dukaanai_api_client/src/model/expense.dart';
import 'package:dukaanai_api_client/src/model/expense_create.dart';
import 'package:dukaanai_api_client/src/model/gst_registration.dart';
import 'package:dukaanai_api_client/src/model/gmail_connect.dart';
import 'package:dukaanai_api_client/src/model/gmail_extracted.dart';
import 'package:dukaanai_api_client/src/model/gmail_import.dart';
import 'package:dukaanai_api_client/src/model/gmail_import_result.dart';
import 'package:dukaanai_api_client/src/model/gmail_imports.dart';
import 'package:dukaanai_api_client/src/model/gmail_message.dart';
import 'package:dukaanai_api_client/src/model/gmail_messages.dart';
import 'package:dukaanai_api_client/src/model/gmail_status.dart';
import 'package:dukaanai_api_client/src/model/health.dart';
import 'package:dukaanai_api_client/src/model/import_confirm.dart';
import 'package:dukaanai_api_client/src/model/import_confirm_response.dart';
import 'package:dukaanai_api_client/src/model/import_dry_run.dart';
import 'package:dukaanai_api_client/src/model/import_dry_run_preview.dart';
import 'package:dukaanai_api_client/src/model/import_job.dart';
import 'package:dukaanai_api_client/src/model/import_job_list.dart';
import 'package:dukaanai_api_client/src/model/invitation.dart';
import 'package:dukaanai_api_client/src/model/location.dart';
import 'package:dukaanai_api_client/src/model/login.dart';
import 'package:dukaanai_api_client/src/model/logout_request.dart';
import 'package:dukaanai_api_client/src/model/me.dart';
import 'package:dukaanai_api_client/src/model/membership.dart';
import 'package:dukaanai_api_client/src/model/membership_summary.dart';
import 'package:dukaanai_api_client/src/model/message_response.dart';
import 'package:dukaanai_api_client/src/model/notification_device.dart';
import 'package:dukaanai_api_client/src/model/notification_device_registration.dart';
import 'package:dukaanai_api_client/src/model/opening_balance_create.dart';
import 'package:dukaanai_api_client/src/model/otp_response.dart';
import 'package:dukaanai_api_client/src/model/otp_send.dart';
import 'package:dukaanai_api_client/src/model/otp_verify.dart';
import 'package:dukaanai_api_client/src/model/outstanding_document.dart';
import 'package:dukaanai_api_client/src/model/paginated_assistant_proposal_list.dart';
import 'package:dukaanai_api_client/src/model/paginated_party_list.dart';
import 'package:dukaanai_api_client/src/model/paginated_product_list.dart';
import 'package:dukaanai_api_client/src/model/party.dart';
import 'package:dukaanai_api_client/src/model/party_ledger_entry.dart';
import 'package:dukaanai_api_client/src/model/party_ledger_report.dart';
import 'package:dukaanai_api_client/src/model/password_change.dart';
import 'package:dukaanai_api_client/src/model/password_reset_confirm.dart';
import 'package:dukaanai_api_client/src/model/password_reset_request.dart';
import 'package:dukaanai_api_client/src/model/patched_business.dart';
import 'package:dukaanai_api_client/src/model/patched_gst_registration.dart';
import 'package:dukaanai_api_client/src/model/patched_location.dart';
import 'package:dukaanai_api_client/src/model/patched_membership.dart';
import 'package:dukaanai_api_client/src/model/patched_party.dart';
import 'package:dukaanai_api_client/src/model/patched_product.dart';
import 'package:dukaanai_api_client/src/model/patched_reminder_update.dart';
import 'package:dukaanai_api_client/src/model/payment.dart';
import 'package:dukaanai_api_client/src/model/payment_allocation.dart';
import 'package:dukaanai_api_client/src/model/payment_allocation_input.dart';
import 'package:dukaanai_api_client/src/model/payment_allocation_review.dart';
import 'package:dukaanai_api_client/src/model/payment_allocation_totals.dart';
import 'package:dukaanai_api_client/src/model/payment_create.dart';
import 'package:dukaanai_api_client/src/model/payment_reallocation.dart';
import 'package:dukaanai_api_client/src/model/product.dart';
import 'package:dukaanai_api_client/src/model/product_pack.dart';
import 'package:dukaanai_api_client/src/model/purchase.dart';
import 'package:dukaanai_api_client/src/model/purchase_create.dart';
import 'package:dukaanai_api_client/src/model/purchase_line.dart';
import 'package:dukaanai_api_client/src/model/purchase_line_input.dart';
import 'package:dukaanai_api_client/src/model/refresh_request.dart';
import 'package:dukaanai_api_client/src/model/refresh_response.dart';
import 'package:dukaanai_api_client/src/model/reminder.dart';
import 'package:dukaanai_api_client/src/model/reminder_create.dart';
import 'package:dukaanai_api_client/src/model/reverse.dart';
import 'package:dukaanai_api_client/src/model/sale.dart';
import 'package:dukaanai_api_client/src/model/sale_create.dart';
import 'package:dukaanai_api_client/src/model/sale_line.dart';
import 'package:dukaanai_api_client/src/model/sale_line_input.dart';
import 'package:dukaanai_api_client/src/model/sales_metrics.dart';
import 'package:dukaanai_api_client/src/model/session_revoke_all_request.dart';
import 'package:dukaanai_api_client/src/model/session_revoke_all_response.dart';
import 'package:dukaanai_api_client/src/model/signup.dart';
import 'package:dukaanai_api_client/src/model/stock_adjustment.dart';
import 'package:dukaanai_api_client/src/model/stock_movement.dart';
import 'package:dukaanai_api_client/src/model/stock_report.dart';
import 'package:dukaanai_api_client/src/model/stock_report_row.dart';
import 'package:dukaanai_api_client/src/model/transfer.dart';
import 'package:dukaanai_api_client/src/model/transfer_create.dart';
import 'package:dukaanai_api_client/src/model/transfer_line.dart';
import 'package:dukaanai_api_client/src/model/transfer_line_input.dart';
import 'package:dukaanai_api_client/src/model/valuation_inventory.dart';
import 'package:dukaanai_api_client/src/model/valuation_report.dart';
import 'package:dukaanai_api_client/src/model/valuation_row.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'AssistantProposal':
      return AssistantProposal.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Attachment':
      return Attachment.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'AuditEvent':
      return AuditEvent.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'AuthCapabilities':
      return AuthCapabilities.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AuthTokenResponse':
      return AuthTokenResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AuthUser':
      return AuthUser.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Bootstrap':
      return Bootstrap.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'BootstrapBusiness':
      return BootstrapBusiness.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'BootstrapLocation':
      return BootstrapLocation.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'BootstrapUser':
      return BootstrapUser.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Business':
      return Business.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Dashboard':
      return Dashboard.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'DashboardBooks':
      return DashboardBooks.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DashboardToday':
      return DashboardToday.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Expense':
      return Expense.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ExpenseCreate':
      return ExpenseCreate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GSTRegistration':
      return GSTRegistration.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GmailConnect':
      return GmailConnect.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'GmailExtracted':
      return GmailExtracted.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GmailImport':
      return GmailImport.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'GmailImportResult':
      return GmailImportResult.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GmailImports':
      return GmailImports.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'GmailMessage':
      return GmailMessage.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'GmailMessages':
      return GmailMessages.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GmailStatus':
      return GmailStatus.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Health':
      return Health.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ImportConfirm':
      return ImportConfirm.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ImportConfirmResponse':
      return ImportConfirmResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ImportDryRun':
      return ImportDryRun.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ImportDryRunPreview':
      return ImportDryRunPreview.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ImportJob':
      return ImportJob.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ImportJobList':
      return ImportJobList.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Invitation':
      return Invitation.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Location':
      return Location.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Login':
      return Login.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'LogoutRequest':
      return LogoutRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Me':
      return Me.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Membership':
      return Membership.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MembershipSummary':
      return MembershipSummary.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MessageResponse':
      return MessageResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'NotificationDevice':
      return NotificationDevice.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'NotificationDeviceRegistration':
      return NotificationDeviceRegistration.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'OpeningBalanceCreate':
      return OpeningBalanceCreate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OtpResponse':
      return OtpResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'OtpSend':
      return OtpSend.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'OtpVerify':
      return OtpVerify.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'OutstandingDocument':
      return OutstandingDocument.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PaginatedAssistantProposalList':
      return PaginatedAssistantProposalList.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'PaginatedPartyList':
      return PaginatedPartyList.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PaginatedProductList':
      return PaginatedProductList.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Party':
      return Party.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PartyLedgerEntry':
      return PartyLedgerEntry.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PartyLedgerReport':
      return PartyLedgerReport.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PasswordChange':
      return PasswordChange.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PasswordResetConfirm':
      return PasswordResetConfirm.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PasswordResetRequest':
      return PasswordResetRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PatchedBusiness':
      return PatchedBusiness.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PatchedGSTRegistration':
      return PatchedGSTRegistration.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PatchedLocation':
      return PatchedLocation.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PatchedMembership':
      return PatchedMembership.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PatchedParty':
      return PatchedParty.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PatchedProduct':
      return PatchedProduct.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PatchedReminderUpdate':
      return PatchedReminderUpdate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Payment':
      return Payment.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PaymentAllocation':
      return PaymentAllocation.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PaymentAllocationInput':
      return PaymentAllocationInput.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PaymentAllocationReview':
      return PaymentAllocationReview.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PaymentAllocationTotals':
      return PaymentAllocationTotals.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PaymentCreate':
      return PaymentCreate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PaymentReallocation':
      return PaymentReallocation.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Product':
      return Product.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ProductPack':
      return ProductPack.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Purchase':
      return Purchase.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PurchaseCreate':
      return PurchaseCreate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PurchaseLine':
      return PurchaseLine.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PurchaseLineInput':
      return PurchaseLineInput.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RefreshRequest':
      return RefreshRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RefreshResponse':
      return RefreshResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Reminder':
      return Reminder.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ReminderCreate':
      return ReminderCreate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Reverse':
      return Reverse.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Sale':
      return Sale.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SaleCreate':
      return SaleCreate.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SaleLine':
      return SaleLine.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SaleLineInput':
      return SaleLineInput.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SalesMetrics':
      return SalesMetrics.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SessionRevokeAllRequest':
      return SessionRevokeAllRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SessionRevokeAllResponse':
      return SessionRevokeAllResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Signup':
      return Signup.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'StockAdjustment':
      return StockAdjustment.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'StockMovement':
      return StockMovement.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'StockReport':
      return StockReport.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'StockReportRow':
      return StockReportRow.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Transfer':
      return Transfer.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'TransferCreate':
      return TransferCreate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TransferLine':
      return TransferLine.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'TransferLineInput':
      return TransferLineInput.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ValuationInventory':
      return ValuationInventory.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ValuationReport':
      return ValuationReport.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ValuationRow':
      return ValuationRow.fromJson(value as Map<String, dynamic>) as ReturnType;
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map(
                (dynamic v) => deserialize<BaseType, BaseType>(
                  v,
                  targetType,
                  growable: growable,
                ),
              ),
            )
            as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}
