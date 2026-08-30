import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'datos/servicios/api_cliente.dart';
import 'datos/servicios/cliente_tiempo_real.dart';
import 'datos/servicios/contador_pasos.dart';
import 'datos/servicios/sincronizador_aportes.dart';

const urlApi = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

void main() => runApp(const ProviderScope(child: AppReto()));

class AppReto extends StatelessWidget {
  const AppReto({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Reto de pasos',
        theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
        home: const PantallaIngreso(),
      );
}

class PantallaIngreso extends StatefulWidget {
  const PantallaIngreso({super.key});

  @override
  State<PantallaIngreso> createState() => _PantallaIngresoState();
}

class _PantallaIngresoState extends State<PantallaIngreso> {
  final correo = TextEditingController();
  final contrasena = TextEditingController();
  bool cargando = false;

  Future<void> ingresar() async {
    setState(() => cargando = true);
    try {
      final sesion = await ApiCliente(urlApi).login(correo.text.trim(), contrasena.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PantallaReto(token: sesion['accessToken'] as String),
        ),
      );
    } on DioException catch (e) {
      _mensaje(e.response?.data?['error']?.toString() ?? 'No fue posible iniciar sesión');
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void _mensaje(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  @override
  void dispose() {
    correo.dispose();
    contrasena.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Reto de pasos')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(controller: correo, decoration: const InputDecoration(labelText: 'Correo')),
              TextField(
                controller: contrasena,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: cargando ? null : ingresar,
                child: Text(cargando ? 'Ingresando…' : 'Ingresar'),
              ),
            ],
          ),
        ),
      );
}

class PantallaReto extends StatefulWidget {
  final String token;
  const PantallaReto({super.key, required this.token});

  @override
  State<PantallaReto> createState() => _PantallaRetoState();
}

class _PantallaRetoState extends State<PantallaReto> {
  final reto = TextEditingController();
  final tiempoReal = ClienteTiempoReal();
  List<Map<String, dynamic>> tabla = [];
  StreamSubscription<int>? suscripcion;
  Timer? temporizador;
  ApiCliente? api;
  SincronizadorAportes? sincronizador;
  int pasos = 0;
  bool sincronizando = false;
  bool conectado = false;

  Future<void> iniciar() async {
    final retoId = reto.text.trim();
    if (retoId.isEmpty) {
      _mensaje('Escribe el ID del reto.');
      return;
    }
    if (!(await Permission.activityRecognition.request()).isGranted) {
      _mensaje('El permiso de actividad física es necesario para contar pasos.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    api = ApiCliente(urlApi, token: widget.token);
    sincronizador = SincronizadorAportes(prefs);
    suscripcion?.cancel();
    suscripcion = ContadorPasos(prefs).observar().listen(
      (valor) {
        if (mounted) setState(() => pasos = valor);
      },
      onError: (_) => _mensaje('Este dispositivo no dispone de sensor de pasos.'),
    );
    tiempoReal.conectar(
      urlBase: urlApi,
      token: widget.token,
      retoId: retoId,
      alRecibirTabla: (datos) {
        if (mounted) {
          setState(() => tabla = (datos as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList());
        }
      },
    );
    temporizador?.cancel();
    temporizador = Timer.periodic(const Duration(hours: 1), (_) => sincronizar());
    await _cargarTabla(retoId);
    if (mounted) setState(() => conectado = true);
  }

  Future<void> _cargarTabla(String retoId) async {
    try {
      final nuevaTabla = await api!.tabla(retoId);
      if (mounted) setState(() => tabla = nuevaTabla);
    } on DioException catch (e) {
      _mensaje(e.response?.data?['error']?.toString() ?? 'No se pudo cargar la tabla');
    }
  }

  Future<void> sincronizar() async {
    if (!conectado || sincronizando || api == null || sincronizador == null) return;
    setState(() => sincronizando = true);
    try {
      final enviados = await sincronizador!.sincronizar(
        retoId: reto.text.trim(),
        pasosAcumulados: pasos,
        enviar: (delta, minutos) => api!.enviarAporte(reto.text.trim(), delta, minutos),
      );
      if (enviados > 0) _mensaje('$enviados pasos enviados al reto.');
    } on DioException catch (e) {
      _mensaje(e.response?.data?['error']?.toString() ?? 'No se pudieron sincronizar los pasos.');
    } finally {
      if (mounted) setState(() => sincronizando = false);
    }
  }

  void _mensaje(String texto) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  void dispose() {
    suscripcion?.cancel();
    temporizador?.cancel();
    tiempoReal.desconectar();
    reto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Mi reto')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(controller: reto, decoration: const InputDecoration(labelText: 'ID del reto')),
              const SizedBox(height: 8),
              FilledButton(onPressed: iniciar, child: const Text('Conectar reto')),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_walk),
                  title: Text('$pasos pasos hoy'),
                  subtitle: const Text('Se envían automáticamente cada hora.'),
                  trailing: OutlinedButton(
                    onPressed: conectado && !sincronizando ? sincronizar : null,
                    child: Text(sincronizando ? 'Enviando…' : 'Sincronizar ahora'),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tabla.length,
                  itemBuilder: (_, i) {
                    final fila = tabla[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${fila['puesto']}')),
                      title: Text('${fila['nombre']}'),
                      trailing: Text('${fila['total']} pasos'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
}
