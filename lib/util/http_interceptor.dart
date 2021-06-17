import 'package:http_interceptor/http_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiInterceptor implements InterceptorContract {

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("accessToken");

    data.headers["Content-Type"] = "application/json";
    data.headers["Authorization"] = "Bearer " + token!;

    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async => data;
}