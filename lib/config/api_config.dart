class ApiConfig {
  static const String _baseUrl = 'https://voyant-server.vercel.app/api';
  static const String _localAndroidEmulator = 'http://10.0.2.2:3000/api';

  static String get baseUrl => _localAndroidEmulator;
  /*static String get baseUrl {
    //using emulator url
    return 'https://voyant-server.vercel.app/api';
  }*/
}
