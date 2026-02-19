import 'env.dart';

class DevEnv extends Env {
  const DevEnv();

  @override
  String get name => 'dev';

  @override
  String get baseUrl => 'https://dev.app.dezign-lab.com/api';

  @override
  bool get enableNetworkLogs => true;
}
