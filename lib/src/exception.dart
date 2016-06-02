class CoffeeException implements Exception {
  final String message;

  CoffeeException([this.message = ""]);

  String toString() => "CoffeeCliException: $message";
}

