import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final int id;
  final String title;
  final double price;
  final bool isMain;

  const MenuItem({
    required this.id,
    required this.title,
    required this.price,
    required this.isMain,
  });

  @override
  List<Object?> get props => [title, price, isMain];
}

class OrderItem extends Equatable {
  final int menuItemId;
  final int count;

  const OrderItem({required this.count, required this.menuItemId});

  @override
  List<Object?> get props => [menuItemId, count];
}

class Order extends Equatable {
  final int? id;
  final double price;
  final List<OrderItem> menuItems;

  const Order({
    this.id,
    required this.price,
    required this.menuItems,
  });

  @override
  List<Object?> get props => [id, price, menuItems];
}

class RestaurantState extends Equatable {
  final bool isLoading;
  final List<MenuItem>? menuItems;
  final List<Order>? orders;
  final String? errorMessage;

  const RestaurantState({required this.isLoading, this.menuItems, this.orders, this.errorMessage});

  @override
  List<Object?> get props => [isLoading, menuItems, orders, errorMessage];

  RestaurantState copyWith({
    required bool isLoading,
    List<MenuItem>? menuItems,
    List<Order>? orders,
    String? errorMessage,
  }) {
    return RestaurantState(
      isLoading: isLoading,
      menuItems: menuItems ?? this.menuItems,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
