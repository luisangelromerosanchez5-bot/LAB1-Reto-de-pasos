import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Convierte las lecturas acumuladas del sistema en pasos del día.
/// Las claves se actualizan antes de emitir, por lo que un reinicio del
/// teléfono no vuelve a sumar una lectura que ya se había contabilizado.
class ContadorPasos {
  final SharedPreferences prefs;
  static const _kLectura = 'pasos_ultima_lectura';
  static const _kAcum = 'pasos_acumulados';
  static const _kDia = 'pasos_dia';

  ContadorPasos(this.prefs);

  Stream<int> observar() =>
      Pedometer.stepCountStream.asyncMap((evento) => procesarLectura(evento.steps));

  /// Método separado para probar el reinicio sin un dispositivo físico.
  Future<int> procesarLectura(int lectura, {DateTime? ahora}) async {
    final fecha = _fecha(ahora ?? DateTime.now());
    if (prefs.getString(_kDia) != fecha) {
      await prefs.setString(_kDia, fecha);
      await prefs.setInt(_kAcum, 0);
      await prefs.setInt(_kLectura, lectura);
      return 0;
    }
    final anterior = prefs.getInt(_kLectura);
    if (anterior == null) {
      await prefs.setInt(_kLectura, lectura);
      return prefs.getInt(_kAcum) ?? 0;
    }
    final delta = lectura >= anterior ? lectura - anterior : lectura;
    final acumulado = (prefs.getInt(_kAcum) ?? 0) + delta;
    await prefs.setInt(_kLectura, lectura);
    await prefs.setInt(_kAcum, acumulado);
    return acumulado;
  }

  static String _fecha(DateTime fecha) =>
      '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
}
