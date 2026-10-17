import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:deshi/core/data/models/banner_item.dart';
import 'package:deshi/core/data/models/customer_profile.dart';
import 'package:deshi/core/data/local/app_database.dart';
import 'package:deshi/core/services/browser_session_diagnostics.dart';
import 'package:flutter/foundation.dart';
import 'package:deshi/core/services/config.dart';

class AppwriteService {
  static final String projectId = AppConfig.appwriteProjectId;
  static final String databaseId = AppConfig.appwriteDatabaseId;
  static final String shoppingDatabaseId = AppConfig.appwriteShoppingDatabaseId;
  static final String orderTableId = AppConfig.appwriteOrdertableId;
  static final String productTableId = AppConfig.appwriteProducttableId;
  static final String bannerTableId = AppConfig.appwriteBannertableId;
  static final String sellerTableId = AppConfig.appwriteSellerstableId;
  static const endpoint = 'https://cloud.appwrite.io/v1';

  static final Client client = Client()
    ..setEndpoint(endpoint)
    ..setProject(projectId);

  // Reuse one TablesDB service for the whole app.
  static final Account account = Account(client);
  static final TablesDB tablesDB = TablesDB(client);
  static Future<models.User?>? _sessionInitialization;
  static int _sessionInitializationCount = 0;
  static bool _anonymousSessionCreatedInProcess = false;

  static String errorMessage(Object error) {
    if (error is AppwriteException) {
      final message = error.message?.trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
      return 'Appwrite error ${error.code}';
    }
    return error.toString();
  }

  static String _stringValue(Object? value) => value?.toString().trim() ?? '';

  static int _intValue(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<models.User?> ensureUser() async {
    final pendingInitialization = _sessionInitialization;
    if (pendingInitialization != null) {
      return pendingInitialization;
    }

    final initialization = _initializeUser();
    _sessionInitialization = initialization;
    try {
      return await initialization;
    } finally {
      if (identical(_sessionInitialization, initialization)) {
        _sessionInitialization = null;
      }
    }
  }

  Future<models.User?> _initializeUser() async {
    final initializationNumber = ++_sessionInitializationCount;
    debugPrint(
      '[auth] initialization #$initializationNumber '
      '${browserSessionDiagnostic(endpoint, fallbackHeaderPresent: client.getHeaders().keys.any((key) => key.toLowerCase() == 'x-fallback-cookies'))} project=$projectId',
    );
    try {
      final user = await account.get();
      debugPrint(
        '[auth] account.get succeeded '
        'initialization #$initializationNumber '
        '${browserSessionDiagnostic(endpoint, fallbackHeaderPresent: client.getHeaders().keys.any((key) => key.toLowerCase() == 'x-fallback-cookies'))} userId=${user.$id}',
      );
      return user;
    } on AppwriteException catch (error) {
      debugPrint(
        '[auth] account.get failed '
        'initialization #$initializationNumber '
        'type=${error.type ?? 'unknown'} code=${error.code ?? 'unknown'} '
        '${browserSessionDiagnostic(endpoint, fallbackHeaderPresent: client.getHeaders().keys.any((key) => key.toLowerCase() == 'x-fallback-cookies'))}',
      );
      if (error.code != 401) {
        debugPrint(
          '[auth] session not created because this is not an unauthenticated response',
        );
        rethrow;
      }

      debugPrint('[auth] no authenticated session at startup');
      return null;
    }
  }

  Future<models.User> createGuestSession() async {
    final existing = await ensureUser();
    if (existing != null) return existing;
    if (_anonymousSessionCreatedInProcess) {
      throw StateError(
        'Guest session creation was already attempted in this app process.',
      );
    }
    await account.createAnonymousSession();
    _anonymousSessionCreatedInProcess = true;
    return account.get();
  }

  Future<models.User> login({
    required String email,
    required String password,
  }) async {
    await account.createEmailPasswordSession(
      email: email.trim(),
      password: password,
    );
    return account.get();
  }

  Future<CustomerProfile> getCustomerProfile() async {
    final user = await ensureUser();
    if (user == null) {
      throw StateError('No authenticated user');
    }
    final isAnonymous = user.email.trim().isEmpty;
    if (isAnonymous) {
      return CustomerProfile(
        userId: user.$id,
        name: '',
        phone: '',
        address: '',
        email: '',
        isAnonymous: true,
      );
    }
    final prefs = user.prefs.data;
    return CustomerProfile(
      userId: user.$id,
      name: user.name.trim().isNotEmpty
          ? user.name.trim()
          : _stringValue(prefs['customerName']),
      phone: user.phone.trim().isNotEmpty
          ? user.phone.trim()
          : _stringValue(prefs['customerPhone']),
      address: _stringValue(prefs['customerAddress']),
      email: user.email,
      isAnonymous: false,
    );
  }

  Future<CustomerProfile> saveCustomerProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    final current = await getCustomerProfile();
    final user = await account.get();
    final savedName = name.trim().isEmpty ? current.name : name.trim();
    final savedPhone = phone.trim().isEmpty ? current.phone : phone.trim();
    final savedAddress = address.trim().isEmpty
        ? current.address
        : address.trim();

    if (savedName.isNotEmpty && savedName != current.name) {
      await account.updateName(name: savedName);
    }
    final mergedPrefs = <String, dynamic>{...user.prefs.data}
      ..addAll({
        'customerName': savedName,
        'customerPhone': savedPhone,
        'customerAddress': savedAddress,
      });
    final updated = await account.updatePrefs(prefs: mergedPrefs);
    final updatedPrefs = updated.prefs.data;
    return CustomerProfile(
      userId: updated.$id,
      name: updated.name.trim().isNotEmpty
          ? updated.name.trim()
          : _stringValue(updatedPrefs['customerName']),
      phone: updated.phone.trim().isNotEmpty
          ? updated.phone.trim()
          : _stringValue(updatedPrefs['customerPhone']),
      address: _stringValue(updatedPrefs['customerAddress']),
      email: updated.email,
      isAnonymous: updated.email.trim().isEmpty,
    );
  }

  Future<CustomerProfile> registerAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim();

    if (normalizedName.isEmpty ||
        normalizedEmail.isEmpty ||
        password.length < 8) {
      throw ArgumentError(
        'Enter your name, a valid email, and a password '
        'of at least 8 characters.',
      );
    }

    final current = await ensureUser();
    if (current == null) {
      final created = await account.create(
        userId: ID.unique(),
        email: normalizedEmail,
        password: password,
        name: normalizedName,
      );
      await account.createEmailPasswordSession(
        email: normalizedEmail,
        password: password,
      );
      final authenticated = await account.get();
      if (authenticated.$id != created.$id) {
        throw StateError('Authenticated user did not match the created user.');
      }
      return getCustomerProfile();
    }

    final beforeId = current.$id;
    if (current.email.trim().isEmpty) {
      await account.updateEmail(email: normalizedEmail, password: password);
      try {
        await account.updateName(name: normalizedName);
      } on AppwriteException catch (error) {
        throw StateError(
          'Email/password conversion succeeded for user $beforeId, but '
          'updating the name failed: ${errorMessage(error)}',
        );
      }
      final converted = await account.get();
      if (converted.$id != beforeId) {
        throw StateError('Account conversion changed the authenticated user.');
      }
      return getCustomerProfile();
    }

    throw StateError('This account already has a permanent email identity.');
  }

  Future<List<models.Row>> getCurrentUserOrders() async {
    final user = await ensureUser();
    if (user == null) {
      throw StateError('No authenticated user');
    }

    const pageSize = 100;
    var offset = 0;
    final rowsById = <String, models.Row>{};
    while (true) {
      final result = await tablesDB.listRows(
        databaseId: shoppingDatabaseId,
        tableId: orderTableId,
        queries: [
          Query.equal('userId', user.$id),
          Query.orderDesc(r'$createdAt'),
          Query.limit(pageSize),
          Query.offset(offset),
        ],
      );
      for (final row in result.rows) {
        rowsById[row.$id] = row;
      }
      if (result.rows.length < pageSize) break;
      offset += pageSize;
    }
    return rowsById.values.toList();
  }
  //Order management

  Future<List<models.Row>> fetchSellers() async {
    try {
      final response = await tablesDB.listRows(
        databaseId: shoppingDatabaseId,
        tableId: sellerTableId,
      );
      return response.rows;
    } on AppwriteException catch (error) {
      debugPrint('Error fetching sellers: ${errorMessage(error)}');
      rethrow;
    }
  }

  //get banners
  Future<List<BannerItem>> getBanners() async {
    try {
      final result = await tablesDB.listRows(
        databaseId: shoppingDatabaseId,
        tableId: bannerTableId,
      );
      return result.rows
          .map(
            (row) => BannerItem(
              id: row.$id,
              imageUrl: _stringValue(row.data['imageUrl']),
              productName: _stringValue(row.data['productName']),
              quantity: _intValue(row.data['quantity']),
              price: _stringValue(row.data['price']),
              weight: _stringValue(row.data['weight']),
            ),
          )
          .toList();
    } on AppwriteException catch (error) {
      debugPrint('Error fetching banners: ${errorMessage(error)}');
      rethrow;
    }
  }

  Future<void> createOrder({
    required String rowId,
    required String productName,
    required String weight,
    required double price,
    required int quantity,
    required String address,
    required String phone,
    required String customerName,
  }) async {
    try {
      final user = await ensureUser();
      if (user == null) {
        throw StateError(
          'An authenticated user is required to create an order.',
        );
      }
      await tablesDB.createRow(
        databaseId: shoppingDatabaseId,
        tableId: orderTableId,
        rowId: rowId,
        permissions: [Permission.read(Role.user(user.$id))],
        data: {
          'userId': user.$id,
          'productName': productName,
          'weight': weight,
          // The Appwrite table defines price as a string attribute.
          'price': price.toStringAsFixed(2),
          'quantity': quantity,
          'status': 'pending',
          'address': address,
          'phone': phone,
          'customerName': customerName,
        },
      );
    } on AppwriteException catch (error) {
      // A retry can receive 409 after the first request reached Appwrite.
      if (error.code != 409) rethrow;
    }
  }

  Future<void> syncPendingOrders({
    void Function(String message)? onError,
  }) async {
    final pendingOrders = await appDatabase.getPendingOrders();
    for (final order in pendingOrders) {
      try {
        await createOrder(
          rowId: order.id,
          productName: order.productName,
          weight: order.weight,
          price: order.price,
          quantity: order.quantity,
          address: order.address,
          phone: order.phone,
          customerName: order.customerName,
        );
        await appDatabase.markOrderSynced(order.id);
      } on AppwriteException catch (error) {
        final message = errorMessage(error);
        debugPrint('Order ${order.id} will retry later: $message');
        onError?.call(message);
      }
    }
  }

  Future<List<models.Row>> fetchProducts() async {
    try {
      final response = await tablesDB.listRows(
        databaseId: shoppingDatabaseId,
        tableId: productTableId,
      );

      return response.rows;
    } on AppwriteException catch (error) {
      debugPrint('Error fetching products: ${error.message}');
      rethrow;
    }
  }
}
