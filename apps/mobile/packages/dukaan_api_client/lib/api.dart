//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library openapi.api;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'api/activity_api.dart';
part 'api/api_api.dart';
part 'api/assistant_api.dart';
part 'api/attachments_api.dart';
part 'api/exports_api.dart';
part 'api/healthz_api.dart';
part 'api/readyz_api.dart';
part 'api/reminders_api.dart';
part 'api/search_api.dart';

part 'model/assistant_proposal.dart';
part 'model/assistant_proposal_status_enum.dart';
part 'model/attachment.dart';
part 'model/attachment_status_enum.dart';
part 'model/base_unit_enum.dart';
part 'model/business.dart';
part 'model/channel_enum.dart';
part 'model/direction_enum.dart';
part 'model/expense.dart';
part 'model/export_create.dart';
part 'model/export_job.dart';
part 'model/export_job_status_enum.dart';
part 'model/format_enum.dart';
part 'model/gst_registration.dart';
part 'model/input_type_enum.dart';
part 'model/interpret.dart';
part 'model/invitation.dart';
part 'model/invitation_status_enum.dart';
part 'model/kind_enum.dart';
part 'model/location.dart';
part 'model/membership.dart';
part 'model/method_enum.dart';
part 'model/party.dart';
part 'model/patched_business.dart';
part 'model/patched_gst_registration.dart';
part 'model/patched_location.dart';
part 'model/patched_membership.dart';
part 'model/patched_party.dart';
part 'model/patched_product.dart';
part 'model/payment.dart';
part 'model/payment_allocation.dart';
part 'model/payment_method_enum.dart';
part 'model/price_mode_enum.dart';
part 'model/product.dart';
part 'model/product_pack.dart';
part 'model/purchase.dart';
part 'model/purchase_line.dart';
part 'model/reminder.dart';
part 'model/reminder_create.dart';
part 'model/reminder_status_enum.dart';
part 'model/report_enum.dart';
part 'model/role_enum.dart';
part 'model/sale.dart';
part 'model/sale_line.dart';
part 'model/status3f8_enum.dart';
part 'model/transfer.dart';
part 'model/transfer_line.dart';


/// An [ApiClient] instance that uses the default values obtained from
/// the OpenAPI specification file.
var defaultApiClient = ApiClient();

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
const _deepEquality = DeepCollectionEquality();
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

bool _isEpochMarker(String? pattern) => pattern == _dateEpochMarker || pattern == '/$_dateEpochMarker/';
