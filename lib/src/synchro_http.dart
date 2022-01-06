import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as h;
import 'package:mih_syncro_http/src/repo/http_extension.dart';
import 'package:mih_syncro_http/src/repo/impl/json.dart';
import 'package:mih_syncro_http/src/repo/impl/requests.dart';
import 'package:mih_syncro_http/src/repo/interface.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';
export './repo.dart';

class SynchronizedHttp {
  final RepoInterface _requestsRepo = RequestsRepo(name: HttpType.REQUEST);
  final RepoInterface _responsesRepo = JsonRepo(name: HttpType.RESPONSE);
  final SimpleConnectionChecker _connection = SimpleConnectionChecker();

  final BehaviorSubject<Map<String, dynamic>> _requestController =
      BehaviorSubject<Map<String, dynamic>>();
  Stream<Map<String, dynamic>> get requestsStream => _requestController.stream;

  SynchronizedHttp() {
    _requestsRepo.getAll.then((value) {
      _requestController.add(value);
      h.Client client = h.Client();
      _connection.onConnectionChange.listen((event) async {
        if (event) {
          var requests = await _requestsRepo.getAll;
          requests.forEach((key, value) async {
            if (value["status"] == null ||
                (value['status'] >= 300 || value['status'] < 200)) {
              h.Request req = RequestMethods.fromJson(value);
              var res = await client.send(req);
              value['status'] = res.statusCode;
              _requestController.add(requests);
              await _requestsRepo.update(value, key: key);
            }
          });
        }
      });
    });
  }

  Future<h.Response> get(Uri url, {Map<String, String>? headers}) async {
    try {
      var response = await h.get(url, headers: headers);
      await _responsesRepo.write(response.toJson());
      return response;
    } catch (e) {
      var cached = await _responsesRepo.get(url.toString());
      return ResponseMethods.fromJson(cached);
    }
  }

  Future<h.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      var response = await h.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      // await _responsesRepo.write(response.toJson());
      return response;
    } catch (e) {
      // var cached = await _responsesRepo.get(url.toString());
      // return ResponseMethods.fromJson(cached);
      await _requestsRepo.write({
        "url": url.toString(),
        "status": null,
        "method": HttpMethods.POST,
        "headers": headers,
        "body": body,
        "type": HttpType.REQUEST,
      });
      _requestController.add(await _requestsRepo.getAll);
      throw "Will be synced when there's an internet connectivity";
    }
  }

  Stream<h.Response> streamGet(Uri url, {Map<String, String>? headers}) async* {
    yield await get(url, headers: headers);
    await for (bool connectionState in _connection.onConnectionChange) {
      if (connectionState) {
        yield await get(url, headers: headers);
      }
    }
  }
}
