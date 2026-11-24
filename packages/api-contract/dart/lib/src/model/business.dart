//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/location.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'business.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Business {
  /// Returns a new [Business] instance.
  Business({
    required this.id,

    required this.name,

    this.legalName,

    this.currency,

    this.timezone,

    this.gstEnabled,

    this.negativeStockAllowed,

    required this.isActive,

    required this.role,

    required this.locations,

    this.locationName,

    this.stateCode,

    this.gstin,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'legal_name', required: false, includeIfNull: false)
  final String? legalName;

  @JsonKey(name: r'currency', required: false, includeIfNull: false)
  final String? currency;

  @JsonKey(name: r'timezone', required: false, includeIfNull: false)
  final String? timezone;

  @JsonKey(name: r'gst_enabled', required: false, includeIfNull: false)
  final bool? gstEnabled;

  @JsonKey(
    name: r'negative_stock_allowed',
    required: false,
    includeIfNull: false,
  )
  final bool? negativeStockAllowed;

  @JsonKey(name: r'is_active', required: true, includeIfNull: false)
  final bool isActive;

  @JsonKey(name: r'role', required: true, includeIfNull: true)
  final String? role;

  @JsonKey(name: r'locations', required: true, includeIfNull: false)
  final List<Location> locations;

  @JsonKey(name: r'location_name', required: false, includeIfNull: false)
  final String? locationName;

  @JsonKey(name: r'state_code', required: false, includeIfNull: false)
  final String? stateCode;

  @JsonKey(name: r'gstin', required: false, includeIfNull: false)
  final String? gstin;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Business &&
          other.id == id &&
          other.name == name &&
          other.legalName == legalName &&
          other.currency == currency &&
          other.timezone == timezone &&
          other.gstEnabled == gstEnabled &&
          other.negativeStockAllowed == negativeStockAllowed &&
          other.isActive == isActive &&
          other.role == role &&
          other.locations == locations &&
          other.locationName == locationName &&
          other.stateCode == stateCode &&
          other.gstin == gstin;

  @override
  int get hashCode =>
      id.hashCode +
      name.hashCode +
      legalName.hashCode +
      currency.hashCode +
      timezone.hashCode +
      gstEnabled.hashCode +
      negativeStockAllowed.hashCode +
      isActive.hashCode +
      (role == null ? 0 : role.hashCode) +
      locations.hashCode +
      locationName.hashCode +
      stateCode.hashCode +
      gstin.hashCode;

  factory Business.fromJson(Map<String, dynamic> json) =>
      _$BusinessFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
