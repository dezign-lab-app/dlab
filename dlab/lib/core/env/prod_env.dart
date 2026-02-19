import 'env.dart';

class ProdEnv extends Env {
  const ProdEnv();

  @override
  String get name => 'prod';

  @override
  String get baseUrl => 'https://app.dezign-lab.com/api';

  @override
  bool get enableNetworkLogs => false;
}
