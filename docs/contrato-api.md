# Contrato de la API · P7 Reto de pasos entre fichas

> Plantilla inicial. El equipo debe completar y ajustar cada endpoint a medida
> que se codifica (semana 1: acordar; semana 2: implementar).

| Método | Ruta | Descripción | Respuesta |
|---|---|---|---|
| POST | /api/auth/login | Autentica al aprendiz o instructor | 200 · { accessToken, refreshToken } |
| POST | /api/retos | Crea un reto (rol instructor) | 201 · { id } |
| GET | /api/retos/:id/tabla | Tabla de posiciones actual del reto | 200 · arreglo |
| POST | /api/aportes | Registra el delta de pasos autenticado | 201 · { ok, aporte } · 401 sin token · 422 incremento no plausible |
| POST | /api/auth/token-dispositivo | Registra el token FCM del usuario autenticado | 204 |

## Eventos de WebSocket (Socket.IO)

| Evento | Dirección | Payload | Descripción |
|---|---|---|---|
| `reto:unirse` | cliente → servidor | `retoId` | Suscribe el socket autenticado a la sala del reto |
| `tabla:actual` | servidor → cliente | arreglo de fichas con `total` y `puesto` | Se emite al suscribirse y tras cada aporte nuevo |

## Pendiente por definir con el equipo

- Formato exacto de errores (¿`{ error }` o `{ mensaje, codigo }`?).
- Paginación de `/api/retos/:id/tabla` si el número de fichas crece.
- Esquema de las notificaciones push (RF-05): payload que se envía a FCM.
