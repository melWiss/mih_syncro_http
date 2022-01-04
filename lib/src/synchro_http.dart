import 'package:mih_syncro_http/src/repo/http_extension.dart';
import 'package:mih_syncro_http/src/repo/impl/json.dart';
import 'package:mih_syncro_http/src/repo/interface.dart';

class SynchronizedHttp {
  final RepoInterface _requestsRepo = JsonRepo(name: HttpType.REQUEST);
  final RepoInterface _responsesRepo = JsonRepo(name: HttpType.RESPONSE);
}
