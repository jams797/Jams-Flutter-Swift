import 'package:jams_flutter_swift/core/helpers/models/router_model.dart';

class VarRouters {
  static final RouterModel splash = RouterModel(name: "splash", path: "/");
  static final RouterModel login = RouterModel(name: "login", path: "/login");
  static final RouterModel home = RouterModel(name: "home", path: "/app");
  static final RouterModel scan = RouterModel(name: "scan", path: "scan");
  static final RouterModel detail = RouterModel(name: "detail", path: "detail");
  static final RouterModel result = RouterModel(name: "result", path: "result");
}