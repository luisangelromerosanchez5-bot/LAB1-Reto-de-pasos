import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'datos/servicios/api_cliente.dart';
import 'datos/servicios/contador_pasos.dart';
import 'datos/servicios/cliente_tiempo_real.dart';

const urlApi = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:3000');
void main() => runApp(const ProviderScope(child: AppReto()));

class AppReto extends StatelessWidget {
  const AppReto({super.key});
  @override Widget build(BuildContext context) => MaterialApp(theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true), home: const PantallaIngreso());
}

class PantallaIngreso extends StatefulWidget { const PantallaIngreso({super.key}); @override State<PantallaIngreso> createState() => _PantallaIngresoState(); }
class _PantallaIngresoState extends State<PantallaIngreso> {
  final correo = TextEditingController(), contrasena = TextEditingController(); bool cargando = false;
  Future<void> ingresar() async {
    setState(() => cargando = true);
    try { final sesion = await ApiCliente(urlApi).login(correo.text.trim(), contrasena.text); if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PantallaReto(token: sesion['accessToken'] as String))); }
    on DioException catch (e) { _mensaje(e.response?.data?['error']?.toString() ?? 'No fue posible iniciar sesión'); }
    finally { if (mounted) setState(() => cargando = false); }
  }
  void _mensaje(String texto) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Reto de pasos')), body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [TextField(controller: correo, decoration: const InputDecoration(labelText: 'Correo')), TextField(controller: contrasena, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')), const SizedBox(height: 16), FilledButton(onPressed: cargando ? null : ingresar, child: Text(cargando ? 'Ingresando…' : 'Ingresar'))])));
}

class PantallaReto extends StatefulWidget { final String token; const PantallaReto({super.key, required this.token}); @override State<PantallaReto> createState() => _PantallaRetoState(); }
class _PantallaRetoState extends State<PantallaReto> {
  final reto = TextEditingController(), tiempoReal = ClienteTiempoReal(); List<Map<String, dynamic>> tabla = []; int pasos = 0; StreamSubscription<int>? suscripcion;
  Future<void> iniciar() async {
    if (!(await Permission.activityRecognition.request()).isGranted) { _mensaje('El permiso de actividad física es necesario para contar pasos.'); return; }
    final prefs = await SharedPreferences.getInstance();
    suscripcion?.cancel(); suscripcion = ContadorPasos(prefs).observar().listen((v) { if (mounted) setState(() => pasos = v); }, onError: (_) => _mensaje('Este dispositivo no dispone de sensor de pasos.'));
    tiempoReal.conectar(urlBase: urlApi, token: widget.token, retoId: reto.text.trim(), alRecibirTabla: (datos) { if (mounted) setState(() => tabla = (datos as List).map((e) => Map<String, dynamic>.from(e as Map)).toList()); });
    try { tabla = await ApiCliente(urlApi, token: widget.token).tabla(reto.text.trim()); if (mounted) setState(() {}); } on DioException catch (e) { _mensaje(e.response?.data?['error']?.toString() ?? 'No se pudo cargar la tabla'); }
  }
  void _mensaje(String texto) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto))); }
  @override void dispose() { suscripcion?.cancel(); tiempoReal.desconectar(); reto.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Mi reto')), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [TextField(controller: reto, decoration: const InputDecoration(labelText: 'ID del reto')), FilledButton(onPressed: iniciar, child: const Text('Conectar reto')), Card(child: ListTile(leading: const Icon(Icons.directions_walk), title: Text('$pasos pasos hoy'))), Expanded(child: ListView.builder(itemCount: tabla.length, itemBuilder: (_, i) { final fila = tabla[i]; return ListTile(leading: CircleAvatar(child: Text('${fila['puesto']}')), title: Text('${fila['nombre']}'), trailing: Text('${fila['total']} pasos')); }))])));
}
