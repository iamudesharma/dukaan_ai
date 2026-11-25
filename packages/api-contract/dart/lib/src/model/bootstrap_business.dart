//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bootstrap_business.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BootstrapBusiness {
  /// Returns a new [BootstrapBusiness] instance.
  BootstrapBusiness({
    required this.id,

    required this.name,

    required this.legalName,

    required this.currency,

    required this.timezone,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'legal_name', required: true, includeIfNull: false)
  final String legalName;

  @JsonKey(name: r'currency', required: true, includeIfNull: false)
  final String currency;

  @JsonKey(name: r'timezone', required: true, includeIfNull: false)
  final String timezone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BootstrapBusiness &&
          other.id == id &&
          other.name == name &&
          other.legalName == legalName &&
          other.currency == currency &&
          other.timezone == timezone;

  @override
  int get hashCode =>
      id.hashCode +
      name.hashCode +
      legalName.hashCode +
      currency.hashCode +
      timezone.hashCode;

  factory BootstrapBusiness.fromJson(Map<String, dynamic> json) =>
      _$BootstrapBusinessFromJson(json);

  Map<String, dynamic> toJson() => _$BootstrapBusinessToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
