import 'package:flutter/material.dart';

import 'state.dart';
import 'controller.dart';
import 'repository.dart';
import 'data_base.dart';

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = RestaurantControllerImpl(
      repository: RestaurantRepositoryImpl(
        menu: menuDB,
        orders: ordersDB,
      ),
    );

    controller.loadMenu();

    return StreamBuilder<RestaurantState>(
      stream: controller.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || (snapshot.data?.isLoading != null && snapshot.data!.isLoading)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data?.errorMessage != null) {
          return _Error(message: snapshot.data!.errorMessage!);
        }

        final menuItems = snapshot.data!.menuItems!;
        final orders = snapshot.data?.orders;

        return Column(
          children: [
            _Menu(
              menuItems: menuItems,
              makeOrder: controller.addOrder,
            ),
            SizedBox(height: 20),
            if (orders != null)
              _Orders(
                orders: orders,
                menuItems: menuItems,
              )
            else
              ElevatedButton(
                onPressed: controller.loadOrders,
                child: Text('Load previous orders'),
              ),
            SizedBox(height: 40.0),
          ],
        );
      },
    );
  }
}

class _Error extends StatelessWidget {
  final String message;
  const _Error({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

class _Menu extends StatefulWidget {
  final List<MenuItem> menuItems;
  final void Function(Order order) makeOrder;

  const _Menu({required this.menuItems, required this.makeOrder});

  @override
  State<_Menu> createState() => __MenuState();
}

class __MenuState extends State<_Menu> {
  Order? order;

  void _addOrRemoveToOrder(MenuItem menuItem) {
    if (order == null) {
      order = Order(
        price: menuItem.price,
        menuItems: [OrderItem(count: 1, menuItemId: menuItem.id)],
      );
    } else {
      List<OrderItem> orderItems = List.from(order!.menuItems);
      double lastPrice = order?.price ?? 0.0;

      final orderItem = OrderItem(count: 1, menuItemId: menuItem.id);
      if (orderItems.where((el) => el.menuItemId == menuItem.id).isEmpty) {
        orderItems.add(orderItem);
        lastPrice += menuItem.price;
      } else {
        final removedItem = orderItems.firstWhere((el) => el.menuItemId == menuItem.id);
        lastPrice -= menuItem.price * removedItem.count;
        orderItems.remove(removedItem);
      }

      order = Order(price: lastPrice, menuItems: orderItems);
    }

    setState(() {});
  }

  void _increaseCountOfItem(OrderItem orderItem) {
    if (order == null) return;

    List<OrderItem> orderItems = List.from(order!.menuItems);
    final itemPrice =
        widget.menuItems.firstWhere((menuItem) => menuItem.id == orderItem.menuItemId).price;
    double lastPrice = order!.price;

    lastPrice += itemPrice;

    order = Order(
        price: lastPrice,
        menuItems: orderItems
            .map(
              (el) => el.menuItemId == orderItem.menuItemId
                  ? OrderItem(count: el.count + 1, menuItemId: el.menuItemId)
                  : el,
            )
            .toList());
    setState(() {});
  }

  void _decreaseCountOfItem(OrderItem orderItem) {
    if (order == null) return;

    List<OrderItem> orderItems = List.from(order!.menuItems);
    final itemPrice =
        widget.menuItems.firstWhere((menuItem) => menuItem.id == orderItem.menuItemId).price;
    double lastPrice = order!.price;

    lastPrice -= itemPrice;

    order = Order(
        price: lastPrice,
        menuItems: orderItems
            .map(
              (el) => el.menuItemId == orderItem.menuItemId
                  ? OrderItem(count: el.count - 1, menuItemId: el.menuItemId)
                  : el,
            )
            .toList());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Menu',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        ...widget.menuItems.map(
          (el) => _MenuItem(
            item: el,
            onTap: () => _addOrRemoveToOrder(el),
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          'Pre-order',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        SizedBox(height: 10.0),
        if (order != null) ...[
          ...order!.menuItems.map(
            (e) => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: e.count > 1 ? () => _decreaseCountOfItem(e) : null,
                  icon: Icon(
                    Icons.exposure_minus_1_rounded,
                  ),
                ),
                Text(widget.menuItems.firstWhere((i) => i.id == e.menuItemId).title),
                Text('count: ${e.count}'),
                IconButton(
                  onPressed: () => _increaseCountOfItem(e),
                  icon: Icon(
                    Icons.exposure_plus_1_rounded,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            'Total price: ${order!.price}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          )
        ],
        SizedBox(height: 20.0),
        if (order != null)
          ElevatedButton(
            onPressed: () => widget.makeOrder(order!),
            child: Text('Make Order'),
          ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final void Function() onTap;
  final MenuItem item;

  const _MenuItem({required this.onTap, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 100.0,
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
          child: Row(
            children: [
              SizedBox(
                width: 100.0,
                height: 100.0,
                child: Image(
                  image: AssetImage('assets/images/${item.title.toLowerCase()}.jpg'),
                ),
              ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.brown,
                    ),
                  ),
                  Text(
                    'Price: ${item.price}\$',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Orders extends StatelessWidget {
  final List<Order> orders;
  final List<MenuItem> menuItems;

  const _Orders({required this.orders, required this.menuItems});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Completed orders',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        ...orders.map((e) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Order Number: ${e.id ?? 0.0}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  ...e.menuItems.map(
                    (e) => Text(
                      '${menuItems.firstWhere((i) => i.id == e.menuItemId).title}  - ${e.count}',
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Full price: ${e.price}\$',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        })
      ],
    );
  }
}
