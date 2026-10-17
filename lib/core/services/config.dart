import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig{
  static String get appwriteEndpoint => dotenv.env['APPWRITE_ENDPOINT'] ?? '';
  static String get appwriteProjectId => dotenv.env['APPWRITE_PROJECT_ID'] ?? '';
  static String get appwriteDatabaseId => dotenv.env['APPWRITE_DATABASE_ID'] ?? '';
  static String get appwriteShoppingDatabaseId => dotenv.env['APPWRITE_ShoppingDatabase_Id'] ?? '';
  static String get appwriteOrdertableId => dotenv.env['APPWRITE_Ordertable_Id'] ?? '';
  static String get appwriteProducttableId => dotenv.env['APPWRITE_Producttable_Id'] ?? '';
  static String get appwriteBannertableId => dotenv.env['APPWRITE_Bannertable_Id'] ?? '';
  static String get appwriteSellerstableId => dotenv.env['APPWRITE_Sellerstable_Id'] ?? '';
}