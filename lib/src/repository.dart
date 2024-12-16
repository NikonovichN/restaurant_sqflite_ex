import 'package:sqflite/sqflite.dart';

import 'state.dart';

abstract class RestaurantRepository {
  Future<List<MenuItem>> loadMenu();
  Future<List<Order>> loadOrders();
  Future<void> addOrder(Order order);
}

class RestaurantRepositoryImpl implements RestaurantRepository {
  final Database _menu;
  final Database _orders;

  const RestaurantRepositoryImpl({
    required Database menu,
    required Database orders,
  })  : _menu = menu,
        _orders = orders;

  @override
  Future<List<MenuItem>> loadMenu() async {
    List<Map> res = await _menu.rawQuery('SELECT * FROM Menu');
    return res
        .map((e) => MenuItem(
              id: e['menuId'],
              title: e['title'],
              price: e['price'],
              isMain: e['main'] == 1,
            ))
        .toList();
  }

  @override
  Future<List<Order>> loadOrders() async {
    List<Map> res = await _orders.rawQuery('SELECT * FROM Orders');
    return res.map((e) {
      final items = (e['orderItems'] as String).replaceAll('(', '').replaceAll(')', '').split(', ');
      return Order(
        id: e['orderId'],
        price: e['orderPrice'],
        menuItems: items
            .map(
              (e) => OrderItem(
                count: int.parse(e.split(':')[0]),
                menuItemId: int.parse(
                  e.split(':')[1],
                ),
              ),
            )
            .toList(),
      );
    }).toList();
  }

  @override
  Future<void> addOrder(Order order) async {
    _orders.insert(
      'Orders',
      {
        'orderPrice': order.price,
        'orderItems': order.menuItems.map((e) => '${e.count}:${e.menuItemId}').toString()
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
