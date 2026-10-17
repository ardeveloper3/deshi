import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
part 'app_database.g.dart';

class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get productName => text().withLength(min: 1, max: 50)();
  TextColumn get customerName => text().withLength(min: 1, max: 100)();
  TextColumn get weight => text().withLength(min: 1, max: 20)();
  RealColumn get price => real()();
  IntColumn get quantity => integer()();
  TextColumn get address => text().withLength(min: 1, max: 100)();
  TextColumn get phone => text().withLength(min: 1, max: 20)();
  TextColumn get status => text()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Orders])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(
        driftDatabase(
          name: 'order_manager',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 5;

  //migration here
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 3) {
        await m.addColumn(orders, orders.phone);
      }
      if (from < 4) {
        await m.addColumn(orders, orders.customerName);
      }
      if (from < 5) {
        await m.addColumn(orders, orders.syncStatus);
      }
    },
  );

  //insertOrder
  Future<String> insertOrder({
    required String productName,
    required String customerName,
    required String weight,
    required double price,
    required int quantity,
    required String address,
    required String status,
    required String phone,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await into(orders).insert(
      OrdersCompanion.insert(
        id: id,
        productName: productName,
        customerName: customerName,
        weight: weight,
        price: price,
        quantity: quantity,
        address: address,
        status: status,
        phone: phone,
      ),
    );
    return id;
  }

  Stream<List<Order>> watchOrders() {
    return (select(orders)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .watch();
  }

  Future<List<Order>> getPendingOrders() {
    return (select(orders)
          ..where((order) => order.syncStatus.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  Future<void> markOrderSynced(String id) {
    return (update(orders)..where((order) => order.id.equals(id))).write(
      const OrdersCompanion(syncStatus: Value('synced')),
    );
  }

  Future<Order?> getLatestOrder() {
    return (select(orders)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
  }
}

final appDatabase = AppDatabase();
