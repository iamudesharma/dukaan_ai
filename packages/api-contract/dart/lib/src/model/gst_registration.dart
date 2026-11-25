//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gst_registration.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GSTRegistration {
  /// Returns a new [GSTRegistration] instance.
  GSTRegistration({
    required this.id,

    required this.business,

    required this.gstin,

    required this.legalName,

    this.address,

    required this.stateCode,

    this.invoicePrefix,

    this.isActive,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  @JsonKey(name: r'gstin', required: true, includeIfNull: false)
  final String gstin;

  @JsonKey(name: r'legal_name', required: true, includeIfNull: false)
  final String legalName;

  @JsonKey(name: r'address', required: false, includeIfNull: false)
  final String? address;

  @JsonKey(name: r'state_code', required: true, includeIfNull: false)
  final String stateCode;

  @JsonKey(name: r'invoice_prefix', required: false, includeIfNull: false)
  final String? invoicePrefix;

  @JsonKey(name: r'is_active', required: false, includeIfNull: false)
  final bool? isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GSTRegistration &&
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

  factory GSTRegistration.fromJson(Map<String, dynamic> json) =>
      _$GSTRegistrationFromJson(json);

  Map<String, dynamic> toJson() => _$GSTRegistrationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
