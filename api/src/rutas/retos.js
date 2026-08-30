import { Router } from 'express';
import { prisma } from '../prisma.js';
import { autenticar, requiereRol } from '../middlewares/autenticacion.js';
import { obtenerTabla } from '../tiempo-real/tabla.js';

const router = Router();

router.get('/', autenticar, async (_req, res, next) => {
  try { res.json(await prisma.reto.findMany({ orderBy: { iniciaEn: 'desc' } })); } catch (error) { next(error); }
});

router.post('/', autenticar, requiereRol('instructor'), async (req, res, next) => {
  try {
    const { nombre, iniciaEn, finalizaEn } = req.body;
    if (!nombre || !iniciaEn || !finalizaEn) return res.status(400).json({ error: 'nombre, iniciaEn y finalizaEn son obligatorios' });
    const inicio = new Date(iniciaEn); const fin = new Date(finalizaEn);
    if (Number.isNaN(+inicio) || Number.isNaN(+fin) || inicio >= fin) return res.status(422).json({ error: 'Las fechas del reto no son válidas' });
    const reto = await prisma.reto.create({ data: { nombre, iniciaEn: inicio, finalizaEn: fin } });
    res.status(201).json(reto);
  } catch (error) { next(error); }
});

router.get('/:id/tabla', autenticar, async (req, res, next) => {
  try {
    const reto = await prisma.reto.findUnique({ where: { id: req.params.id } });
    if (!reto) return res.status(404).json({ error: 'Reto no encontrado' });
    res.json(await obtenerTabla(prisma, reto.id));
  } catch (error) { next(error); }
});

export default router;
