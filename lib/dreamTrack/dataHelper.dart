class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  DatabaseHelper._internal();


  factory DatabaseHelper() {
    return _instance;
  }

  //create db 
  //crud operations
}