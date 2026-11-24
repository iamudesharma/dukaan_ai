//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'patched_party.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PatchedParty {
  /// Returns a new [PatchedParty] instance.
  PatchedParty({
    this.id,

    this.business,

    this.name,

    this.kind,

    this.phoneE164,

    this.gstin,

    this.stateCode,

    this.address,

    this.isActive,

    this.receivableMinor = 0,

    this.payableMinor = 0,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'business', required: false, includeIfNull: false)
  final String? business;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  /// * `CUSTOMER` - Customer * `SUPPLIER` - Supplier * `BOTH` - Customer and supplier
  @JsonKey(name: r'kind', required: false, includeIfNull: false)
  final PatchedPartyKindEnum? kind;

  @JsonKey(name: r'phone_e164', required: false, includeIfNull: false)
  final String? phoneE164;

  @JsonKey(name: r'gstin', required: false, includeIfNull: false)
  final String? gstin;

  @JsonKey(name: r'state_code', required: false, includeIfNull: false)
  final String? stateCode;

  @JsonKey(name: r'address', required: false, includeIfNull: false)
  final String? address;

  @JsonKey(name: r'is_active', required: false, includeIfNull: false)
  final bool? isActive;

  @JsonKey(
    defaultValue: 0,
    name: r'receivable_minor',
    required: false,
    includeIfNull: false,
  )
  final int? receivableMinor;

  @JsonKey(
    defaultValue: 0,
    name: r'payable_minor',
    required: false,
    includeIfNull: false,
  )
  final int? payableMinor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatchedParty &&
          other.id == id &&
          other.business == business &&
          other.name == name &&
          other.kind == kind &&
          other.phoneE164 == phoneE164 &&
          other.gstin == gstin &&
          other.stateCode == stateCode &&
          other.address == address &&
          other.isActive == isActive &&
          other.receivableMinor == receivableMinor &&
          other.payableMinor == payableMinor;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      name.hashCode +
      kind.hashCode +
      phoneE164.hashCode +
      gstin.hashCode +
      stateCode.hashCode +
      address.hashCode +
      isActive.hashCode +
      receivableMinor.hashCode +
      payableMinor.hashCode;

  factory PatchedParty.fromJson(Map<String, dynamic> json) =>
      _$PatchedPartyFromJson(json);

  Map<String, dynamic> toJson() => _$PatchedPartyToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `CUSTOMER` - Customer * `SUPPLIER` - Supplier * `BOTH` - Customer and supplier
enum PatchedPartyKindEnum {
  @JsonValue(r'CUSTOMER')
  CUSTOMER(r'CUSTOMER'),
  @JsonValue(r'SUPPLIER')
  SUPPLIER(r'SUPPLIER'),
  @JsonValue(r'BOTH')
  BOTH(r'BOTH');

  const PatchedPartyKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
