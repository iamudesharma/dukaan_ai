//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'patched_gst_registration.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PatchedGSTRegistration {
  /// Returns a new [PatchedGSTRegistration] instance.
  PatchedGSTRegistration({
    this.id,

    this.business,

    this.gstin,

    this.legalName,

    this.address,

    this.stateCode,

    this.invoicePrefix,

    this.isActive,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'business', required: false, includeIfNull: false)
  final String? business;

  @JsonKey(name: r'gstin', required: false, includeIfNull: false)
  final String? gstin;

  @JsonKey(name: r'legal_name', required: false, includeIfNull: false)
  final String? legalName;

  @JsonKey(name: r'address', required: false, includeIfNull: false)
  final String? address;

  @JsonKey(name: r'state_code', required: false, includeIfNull: false)
  final String? stateCode;

  @JsonKey(name: r'invoice_prefix', required: false, includeIfNull: false)
  final String? invoicePrefix;

  @JsonKey(name: r'is_active', required: false, includeIfNull: false)
  final bool? isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatchedGSTRegistration &&
          other.id == id &&
          other.business == business &&
          other.gstin == gstin &&
          other.legalName == legalName &&
          other.address == address &&
          other.stateCode == stateCode &&
          other.invoicePrefix == invoicePrefix &&
          other.isActive == isActive;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      gstin.hashCode +
      legalName.hashCode +
      address.hashCode +
      stateCode.hashCode +
      invoicePrefix.hashCode +
      isActive.hashCode;

  factory PatchedGSTRegistration.fromJson(Map<String, dynamic> json) =>
      _$PatchedGSTRegistrationFromJson(json);

  Map<String, dynamic> toJson() => _$PatchedGSTRegistrationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
