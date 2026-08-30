import jwt from 'jsonwebtoken';
import { notificarAdelantamientos } from '../servicios/notificaciones.js';

// Cache en memoria de la última tabla calculada por reto.
// TODO (equipo): si se necesita más de una instancia del servidor,
// mover este cache a Redis.
export const cacheTabla = new Map();

function verificarJwt(token) {
  return jwt.verify(token, process.env.JWT_SECRET);
}

export function montarTiempoReal(io) {
  // Autenticación del socket: sin token válido no hay conexión.
  io.use(async (socket, next) => {
    try {
      socket.usuario = verificarJwt(socket.handshake.auth.token);
      next();
    } catch {
      next(new Error('no autorizado'));
    }
  });

  io.on('connection', (socket) => {
    socket.on('reto:unirse', (retoId) => {
      if (typeof retoId !== 'string') return;
      socket.join(`reto:${retoId}`);
      socket.emit('tabla:actual', cacheTabla.get(retoId) ?? []);
    });
  });
}

export async function obtenerTabla(prisma, retoId) {
  return prisma.$queryRaw`
    SELECT f.id, f.nombre, COALESCE(SUM(a.pasos), 0)::int AS total,
           RANK() OVER (ORDER BY COALESCE(SUM(a.pasos), 0) DESC) AS puesto
    FROM ficha f
    JOIN usuario u ON u.ficha_id = f.id
    LEFT JOIN aporte a ON a.usuario_id = u.id AND a.reto_id = ${retoId}
    GROUP BY f.id, f.nombre
    ORDER BY total DESC, f.nombre ASC`;
}

export async function registrarAporte(prisma, io, usuarioId, retoId, pasos) {
  const tablaAnterior = cacheTabla.get(retoId) ?? await obtenerTabla(prisma, retoId);
  const usuario = await prisma.usuario.findUnique({ where: { id: usuarioId } });
  if (!usuario) throw Object.assign(new Error('Usuario no encontrado'), { status: 404 });
  const aporte = await prisma.aporte.create({
    data: { usuarioId, retoId, fichaId: usuario.fichaId, pasos },
  });
  const tabla = await obtenerTabla(prisma, retoId);

  cacheTabla.set(retoId, tabla);
  io.to(`reto:${retoId}`).emit('tabla:actual', tabla);
  notificarAdelantamientos(prisma, tablaAnterior, tabla).catch((error) => console.error('No fue posible enviar la notificación push', error));
  return aporte;
}
