import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:p7_reto_pasos/datos/servicios/contador_pasos.dart';

void main() {
  test('conserva el acumulado después de que el contador se reinicia', () async {
    SharedPreferences.setMockInitialValues({'pasos_dia': '2026-08-30', 'pasos_ultima_lectura': 120, 'pasos_acumulados': 50});
    final contador = ContadorPasos(await SharedPreferences.getInstance());
    expect(await contador.procesarLectura(140, ahora: DateTime(2026, 8, 30)), 70);
    expect(await contador.procesarLectura(5, ahora: DateTime(2026, 8, 30)), 75);
    expect(await contador.procesarLectura(8, ahora: DateTime(2026, 8, 30)), 78);
  });
}
