enum Env {
  production,
  development,
}

class Config {
  Config._();

  static const env = Env.development;

  static const serverUrl = 'https://www.shirne.com/api/';
  static const imgServer = '';
}
