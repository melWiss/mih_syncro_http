import 'dart:async';

import 'package:http/http.dart' as h;
import 'package:mih_syncro_http/src/repo/http_extension.dart';
import 'package:mih_syncro_http/src/repo/impl/json.dart';
import 'package:mih_syncro_http/src/repo/interface.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

class SynchronizedHttp {
  final RepoInterface _requestsRepo = JsonRepo(name: HttpType.REQUEST);
  final RepoInterface _responsesRepo = JsonRepo(name: HttpType.RESPONSE);
  final SimpleConnectionChecker _connection = SimpleConnectionChecker();

  // BehaviorSubject<h.Request> _requestController = BehaviorSubject<h.Request>();
  // BehaviorSubject<h.Response> _responseController =
  //     BehaviorSubject<h.Response>();

  Future<h.Response> get(Uri url, {Map<String, String>? headers}) async {
    try {
      var response = await h.get(url, headers: headers);
      await _responsesRepo.write(response.toJson());
      return response;
    } catch (e) {
      var cached = await _responsesRepo.get(url.path);
      return ResponseMethods.fromJson(cached);
    }
  }
}
