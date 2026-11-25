//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transfer_line_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TransferLineInput {
  /// Returns a new [TransferLineInput] instance.
  TransferLineInput({required this.packId, required this.quantity});

  @JsonKey(name: r'pack_id', required: true, includeIfNull: false)
  final String packId;

  @JsonKey(name: r'quantity', required: true, includeIfNull: false)
  final double quantity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferLineInput &&
          other.packId == packId &&
          other.quantity == quantity;

  @override
  int get hashCode => packId.hashCode + quantity.hashCode;

  factory TransferLineInput.fromJson(Map<String, dynamic> json) =>
      _$TransferLineInputFromJson(json);

  Map<String, dynamic> toJson() => _$TransferLineInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
