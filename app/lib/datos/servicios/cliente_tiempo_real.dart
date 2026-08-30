import 'package:socket_io_client/socket_io_client.dart' as io_client;

/// Conecta con el WebSocket del backend (src/tiempo-real/tabla.js) y expone
/// las actualizaciones de la tabla de posiciones (RF-04).
/// TODO (equipo): inyectar el token JWT real en `auth` y convertir el mapa
/// recibido en la entidad `TablaPosiciones` del dominio.
class ClienteTiempoReal {
  io_client.Socket? _socket;

  void conectar({required String urlBase, required String token, required String retoId, required Function(dynamic) alRecibirTabla}) {
    _socket = io_client.io(
      urlBase,
      io_client.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .build(),
    );
    _socket!.on('tabla:actual', alRecibirTabla);
    _socket!.onConnect((_) => _socket!.emit('reto:unirse', retoId));
  }

  void desconectar() => _socket?.dispose();
}
