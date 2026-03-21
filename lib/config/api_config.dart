class ApiConfig {
  static const String _baseUrl = 'http://localhost:3000/api';
  
  static String get baseUrl {
    //check - to see if running on emulator 
    if (const String.fromEnvironment('FLUTTER_TARGET')?.contains('emulator') == true) {
      return 'http://10.0.2.2:3000/api';
    }
    return _baseUrl;
  }
}
