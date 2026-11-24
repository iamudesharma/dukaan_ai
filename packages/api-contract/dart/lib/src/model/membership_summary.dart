//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'membership_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MembershipSummary {
  /// Returns a new [MembershipSummary] instance.
  MembershipSummary({
    required this.businessId,

    required this.businessName,

    required this.role,
  });

  @JsonKey(name: r'business_id', required: true, includeIfNull: false)
  final String businessId;

  @JsonKey(name: r'business_name', required: true, includeIfNull: false)
  final String businessName;

  /// * `OWNER` - Owner * `MANAGER` - Manager * `CASHIER` - Cashier
  @JsonKey(name: r'role', required: true, includeIfNull: false)
  final MembershipSummaryRoleEnum role;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MembershipSummary &&
          other.businessId == businessId &&
          other.businessName == businessName &&
          other.role == role;

  @override
  int get hashCode =>
      businessId.hashCode + businessName.hashCode + role.hashCode;

  factory MembershipSummary.fromJson(Map<String, dynamic> json) =>
      _$MembershipSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$MembershipSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `OWNER` - Owner * `MANAGER` - Manager * `CASHIER` - Cashier
enum MembershipSummaryRoleEnum {
  @JsonValue(r'OWNER')
  OWNER(r'OWNER'),
  @JsonValue(r'MANAGER')
  MANAGER(r'MANAGER'),
  @JsonValue(r'CASHIER')
  CASHIER(r'CASHIER');

  const MembershipSummaryRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
