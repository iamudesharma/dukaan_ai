//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_confirm.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportConfirm {
  /// Returns a new [ImportConfirm] instance.
  ImportConfirm({this.idempotencyKey});

  @JsonKey(name: r'idempotency_key', required: false, includeIfNull: false)
  final String? idempotencyKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportConfirm && other.idempotencyKey == idempotencyKey;

  @override
  int get hashCode => idempotencyKey.hashCode;

  factory ImportConfirm.fromJson(Map<String, dynamic> json) =>
      _$ImportConfirmFromJson(json);

  Map<String, dynamic> toJson() => _$ImportConfirmToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
