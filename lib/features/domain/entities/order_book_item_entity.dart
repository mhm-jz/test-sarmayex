import 'package:equatable/equatable.dart';

final class OrderBookItemEntity extends Equatable {
  final double price;
  final double amount;

  const OrderBookItemEntity({
    required this.price,
    required this.amount,
  });
  @override
  List<Object?> get props => [price, amount];
}
