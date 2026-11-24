//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'patched_location.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PatchedLocation {
  /// Returns a new [PatchedLocation] instance.
  PatchedLocation({
    this.id,

    this.business,

    this.gstRegistration,

    this.code,

    this.name,

    this.address,

    this.stateCode,

    this.isActive,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'business', required: false, includeIfNull: false)
  final String? business;

  @JsonKey(name: r'gst_registration', required: false, includeIfNull: false)
  final String? gstRegistration;

  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final String? code;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'address', required: false, includeIfNull: false)
  final String? address;

  @JsonKey(name: r'state_code', required: false, includeIfNull: false)
  final String? stateCode;

  @JsonKey(name: r'is_active', required: false, includeIfNull: false)
  final bool? isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatchedLocation &&
          other.id == id &&
          other.business == business &&
          other.gstRegistration == gstRegistration &&
          other.code == code &&
          other.name == name &&
          other.address == address &&
          other.stateCode == stateCode &&
          other.isActive == isActive;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      (gstRegistration == null ? 0 : gstRegistration.hashCode) +
      code.hashCode +
      name.hashCode +
      address.hashCode +
      stateCode.hashCode +
      isActive.hashCode;

  factory PatchedLocation.fromJson(Map<String, dynamic> json) =>
      _$PatchedLocationFromJson(json);

  Map<String, dynamic> toJson() => _$PatchedLocationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
