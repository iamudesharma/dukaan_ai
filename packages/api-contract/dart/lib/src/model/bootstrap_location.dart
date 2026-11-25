//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bootstrap_location.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BootstrapLocation {
  /// Returns a new [BootstrapLocation] instance.
  BootstrapLocation({
    required this.id,

    required this.name,

    required this.code,

    required this.stateCode,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'state_code', required: true, includeIfNull: false)
  final String stateCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BootstrapLocation &&
          other.id == id &&
          other.name == name &&
          other.code == code &&
          other.stateCode == stateCode;

  @override
  int get hashCode =>
      id.hashCode + name.hashCode + code.hashCode + stateCode.hashCode;

  factory BootstrapLocation.fromJson(Map<String, dynamic> json) =>
      _$BootstrapLocationFromJson(json);

  Map<String, dynamic> toJson() => _$BootstrapLocationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
