import 'package:dio/dio.dart';

class ApiCliente {
  final Dio _dio;
  ApiCliente(String urlBase, {String? token}) : _dio = Dio(BaseOptions(baseUrl: urlBase, headers: token == null ? {} : {'Authorization': 'Bearer $token'}));

  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final respuesta = await _dio.post('/api/auth/login', data: {'correo': correo, 'contrasena': contrasena});
    return Map<String, dynamic>.from(respuesta.data as Map);
  }

  Future<List<Map<String, dynamic>>> tabla(String retoId) async {
    final respuesta = await _dio.get('/api/retos/$retoId/tabla');
    return (respuesta.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
