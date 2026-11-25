//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transfer_line.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TransferLine {
  /// Returns a new [TransferLine] instance.
  TransferLine({
    required this.id,

    required this.product,

    required this.pack,

    required this.quantity,

    required this.conversionFactor,

    required this.baseQuantity,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'product', required: true, includeIfNull: false)
  final String product;

  @JsonKey(name: r'pack', required: true, includeIfNull: false)
  final String pack;

  @JsonKey(name: r'quantity', required: true, includeIfNull: false)
  final double quantity;

  @JsonKey(name: r'conversion_factor', required: true, includeIfNull: false)
  final double conversionFactor;

  @JsonKey(name: r'base_quantity', required: true, includeIfNull: false)
  final double baseQuantity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferLine &&
          other.id == id &&
          other.product == product &&
          other.pack == pack &&
          other.quantity == quantity &&
          other.conversionFactor == conversionFactor &&
          other.baseQuantity == baseQuantity;

  @override
  int get hashCode =>
      id.hashCode +
      product.hashCode +
      pack.hashCode +
      quantity.hashCode +
      conversionFactor.hashCode +
      baseQuantity.hashCode;

  factory TransferLine.fromJson(Map<String, dynamic> json) =>
      _$TransferLineFromJson(json);

  Map<String, dynamic> toJson() => _$TransferLineToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
