import admin from 'firebase-admin';

let inicializado = false;

function mensajeria() {
  if (inicializado) return admin.messaging();
  const texto = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (!texto) return null;
  admin.initializeApp({ credential: admin.credential.cert(JSON.parse(texto)) });
  inicializado = true;
  return admin.messaging();
}

/// Envía una notificación solo a fichas cuyo puesto empeoró con este aporte.
export async function notificarAdelantamientos(prisma, anterior, actual) {
  const antes = new Map(anterior.map((fila) => [fila.id, Number(fila.puesto)]));
  const fichasAfectadas = actual.filter((fila) => antes.has(fila.id) && Number(fila.puesto) > antes.get(fila.id));
  if (!fichasAfectadas.length) return;
  const usuarios = await prisma.usuario.findMany({ where: { fichaId: { in: fichasAfectadas.map((f) => f.id) }, tokenDispositivo: { not: null } }, select: { tokenDispositivo: true } });
  const tokens = usuarios.map((u) => u.tokenDispositivo).filter(Boolean);
  const servicio = mensajeria();
  if (!servicio || !tokens.length) return;
  await servicio.sendEachForMulticast({ tokens, notification: { title: 'Cambio en el reto', body: 'Otra ficha acaba de superar a tu ficha.' } });
}
