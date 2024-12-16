import 'package:sqflite/sqflite.dart';

enum DataBasePath {
  menu("menu"),
  orders("orders"),
  ;

  const DataBasePath(this.path);

  final String path;
}

late final Database menuDB;
late final Database ordersDB;

Future<void> initializeDataBase() async {
  final databasesPath = await getDatabasesPath();

  menuDB = await openDatabase('$databasesPath${DataBasePath.menu}', version: 2,
      onCreate: (Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        'CREATE TABLE Menu (menuId INTEGER PRIMARY KEY NOT NULL, title TEXT, price DOUBLE, main BOOLEAN)');
  });
  // menuDB.insert(
  //   'Menu',
  //   {'title': 'Coca Cola', 'price': 10.0, 'main': false},
  //   conflictAlgorithm: ConflictAlgorithm.ignore,
  // );
  // menuDB.insert(
  //   'Menu',
  //   {'title': 'Pepsi', 'price': 5.0, 'main': false},
  //   conflictAlgorithm: ConflictAlgorithm.ignore,
  // );
  // menuDB.insert(
  //   'Menu',
  //   {'title': 'Burger', 'price': 25.0, 'main': true},
  //   conflictAlgorithm: ConflictAlgorithm.ignore,
  // );
  // menuDB.insert(
  //   'Menu',
  //   {'title': 'Cheeseburger', 'price': 22.0, 'main': true},
  //   conflictAlgorithm: ConflictAlgorithm.ignore,
  // );
  // await deleteDatabase('$databasesPath${DataBasePath.orders}');
  ordersDB = await openDatabase('$databasesPath${DataBasePath.orders}', version: 1,
      onCreate: (Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        'CREATE TABLE Orders (orderId INTEGER PRIMARY KEY NOT NULL, orderPrice DOUBLE, orderItems TEXT)');
  });
}
