import 'package:shared_preferences/shared_preferences.dart';

typedef EnviarAporte = Future<void> Function(int pasos, int minutos);

/// Envía solo los pasos que aún no llegaron al servidor para un reto.
/// La marca local se actualiza únicamente después de una respuesta exitosa,
/// evitando duplicados si la aplicación se cierra o se queda sin red.
class SincronizadorAportes {
  final SharedPreferences prefs;
  final DateTime Function() ahora;

  SincronizadorAportes(this.prefs, {DateTime Function()? reloj})
      : ahora = reloj ?? DateTime.now;

  String _pasosKey(String retoId) => 'pasos_enviados_$retoId';
  String _instanteKey(String retoId) => 'instante_ultimo_envio_$retoId';

  Future<int> sincronizar({
    required String retoId,
    required int pasosAcumulados,
    required EnviarAporte enviar,
  }) async {
    final anterior = prefs.getInt(_pasosKey(retoId));
    final delta = anterior == null || pasosAcumulados < anterior
        ? pasosAcumulados
        : pasosAcumulados - anterior;
    if (delta == 0) return 0;

    final fechaActual = ahora();
    final ultimoMillis = prefs.getInt(_instanteKey(retoId));
    final desde = ultimoMillis == null
        ? DateTime(fechaActual.year, fechaActual.month, fechaActual.day)
        : DateTime.fromMillisecondsSinceEpoch(ultimoMillis);
    final minutos = fechaActual.difference(desde).inMinutes.clamp(1, 24 * 60) as int;

    await enviar(delta, minutos);
    await prefs.setInt(_pasosKey(retoId), pasosAcumulados);
    await prefs.setInt(_instanteKey(retoId), fechaActual.millisecondsSinceEpoch);
    return delta;
  }
}
