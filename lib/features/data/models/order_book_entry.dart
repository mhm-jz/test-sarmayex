final class OrderBookEntryModel {
  final double price;
  final double amount;

  const OrderBookEntryModel({
    required this.price,
    required this.amount,
  });

  factory OrderBookEntryModel.fromJsonValue(dynamic json) {
    if (json is List && json.length >= 2) {
      return OrderBookEntryModel(
        price: _requiredDouble(json[0], fieldName: 'price'),
        amount: _requiredDouble(json[1], fieldName: 'amount'),
      );
    }

    if (json is Map<String, dynamic>) {
      final rawPrice = json['p'] ?? json['price'];
      final rawAmount =
          json['a'] ?? json['amount'] ?? json['quantity'] ?? json['qty'];

      if (rawPrice == null || rawAmount == null) {
        throw FormatException('Invalid order book entry: $json');
      }

      return OrderBookEntryModel(
        price: _requiredDouble(rawPrice, fieldName: 'price'),
        amount: _requiredDouble(rawAmount, fieldName: 'amount'),
      );
    }

    throw FormatException('Invalid order book entry: $json');
  }
}

double _requiredDouble(
  Object? value, {
  required String fieldName,
}) {
  if (value == null) {
    throw FormatException('Missing double field: $fieldName');
  }

  final parsed = double.tryParse(value.toString());

  if (parsed == null) {
    throw FormatException('Invalid double field "$fieldName": $value');
  }

  return parsed;
}
