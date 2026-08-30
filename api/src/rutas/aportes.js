import { Router } from 'express';
import { crearAporte } from '../controladores/aportes.js';
import { autenticar } from '../middlewares/autenticacion.js';

const router = Router();

// RF-03 / RF-06: recibe el acumulado por horas y descarta incrementos imposibles.
router.post('/', autenticar, crearAporte);

export default router;
