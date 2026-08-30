import 'package:dio/dio.dart';

class ApiCliente {
  final Dio _dio;
  ApiCliente(String urlBase, {String? token}) : _dio = Dio(BaseOptions(
    baseUrl: urlBase,
    headers: token == null ? {} : {'Authorization': 'Bearer $token'},
    connectTimeout: const Duration(seconds: 90),
    receiveTimeout: const Duration(seconds: 90),
  ));

  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final respuesta = await _dio.post('/api/auth/login', data: {'correo': correo, 'contrasena': contrasena});
    return Map<String, dynamic>.from(respuesta.data as Map);
  }

  Future<List<Map<String, dynamic>>> tabla(String retoId) async {
    final respuesta = await _dio.get('/api/retos/$retoId/tabla');
    return (respuesta.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> enviarAporte(String retoId, int pasos, int minutos) async {
    await _dio.post('/api/aportes', data: {
      'retoId': retoId,
      'pasos': pasos,
      'minutos': minutos,
    });
  }
}
