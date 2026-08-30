import { prisma } from '../prisma.js';
import { registrarAporte } from '../tiempo-real/tabla.js';

const TOPE_PASOS_POR_MINUTO = 250;

export function validarAporte({ pasos, minutos }) {
  if (!Number.isInteger(pasos) || !Number.isInteger(minutos) || minutos <= 0) return 'pasos y minutos deben ser enteros positivos';
  const tope = TOPE_PASOS_POR_MINUTO * minutos;
  if (pasos < 0 || pasos > tope) return `Incremento de pasos no plausible: ${pasos} en ${minutos} min`;
  return null;
}

export async function crearAporte(req, res, next) {
  try {
    const { retoId, pasos, minutos } = req.body;

    if (!retoId || pasos == null || minutos == null) {
      return res.status(400).json({ error: 'Faltan campos obligatorios' });
    }
    const errorValidacion = validarAporte({ pasos, minutos });
    if (errorValidacion) return res.status(422).json({ error: errorValidacion });
    const reto = await prisma.reto.findFirst({ where: { id: retoId, activo: true, iniciaEn: { lte: new Date() }, finalizaEn: { gte: new Date() } } });
    if (!reto) return res.status(404).json({ error: 'Reto activo no encontrado' });
    const aporte = await registrarAporte(prisma, req.app.get('io'), req.usuario.sub, retoId, pasos);
    res.status(201).json({ ok: true, aporte });
  } catch (e) {
    next(e);
  }
}
