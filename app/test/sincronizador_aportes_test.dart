import 'package:flutter_test/flutter_test.dart';
import 'package:p7_reto_pasos/datos/servicios/sincronizador_aportes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('envía solo el delta y no lo duplica', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final sincronizador = SincronizadorAportes(
      prefs,
      reloj: () => DateTime(2026, 8, 30, 12),
    );
    final enviados = <int>[];
    await sincronizador.sincronizar(
      retoId: 'reto-1',
      pasosAcumulados: 120,
      enviar: (pasos, _) async => enviados.add(pasos),
    );
    await sincronizador.sincronizar(
      retoId: 'reto-1',
      pasosAcumulados: 120,
      enviar: (pasos, _) async => enviados.add(pasos),
    );
    await sincronizador.sincronizar(
      retoId: 'reto-1',
      pasosAcumulados: 145,
      enviar: (pasos, _) async => enviados.add(pasos),
    );
    expect(enviados, [120, 25]);
  });
}
