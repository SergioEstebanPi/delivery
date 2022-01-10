import 'dart:convert';

ResponseApi responseApiFromJson(String str) => ResponseApi.fromJson(json.decode(str));

String responseApiToJson(ResponseApi data) => json.encode(data.toJson());

class ResponseApi {
  late String message;
  dynamic error;
  late bool success;
  late dynamic data;

  ResponseApi({
    required this.message,
    required this.error,
    required this.success,
    this.data,
  });

  ResponseApi.fromJson(Map<String, dynamic> json){
    message = json["message"];
    error = json["error"];
    success = json["success"];
    try {
      data = json['data'];
    } catch(e){
      print('Exception data $e');
    }
  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "error": error,
    "success": success,
    "data": data,
  };
}