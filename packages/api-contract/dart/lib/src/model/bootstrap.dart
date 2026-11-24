//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/bootstrap_user.dart';
import 'package:dukaanai_api_client/src/model/bootstrap_location.dart';
import 'package:dukaanai_api_client/src/model/bootstrap_business.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bootstrap.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Bootstrap {
  /// Returns a new [Bootstrap] instance.
  Bootstrap({
    required this.user,

    required this.business,

    required this.locations,

    required this.permissions,
  });

  @JsonKey(name: r'user', required: true, includeIfNull: false)
  final BootstrapUser user;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final BootstrapBusiness business;

  @JsonKey(name: r'locations', required: true, includeIfNull: false)
  final List<BootstrapLocation> locations;

  @JsonKey(name: r'permissions', required: true, includeIfNull: false)
  final List<String> permissions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bootstrap &&
          other.user == user &&
          other.business == business &&
          other.locations == locations &&
          other.permissions == permissions;

  @override
  int get hashCode =>
      user.hashCode +
      business.hashCode +
      locations.hashCode +
      permissions.hashCode;

  factory Bootstrap.fromJson(Map<String, dynamic> json) =>
      _$BootstrapFromJson(json);

  Map<String, dynamic> toJson() => _$BootstrapToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
