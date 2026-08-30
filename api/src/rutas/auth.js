import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { prisma } from '../prisma.js';
import { verificarContrasena } from '../servicios/contrasenas.js';
import { autenticar } from '../middlewares/autenticacion.js';

const router = Router();

router.post('/login', async (req, res, next) => {
  try {
    const { correo, contrasena } = req.body;
    if (!correo || !contrasena) return res.status(400).json({ error: 'Correo y contraseña son obligatorios' });
    const usuario = await prisma.usuario.findUnique({ where: { correo } });
    if (!usuario || !verificarContrasena(contrasena, usuario.contrasenaSha)) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }
    const payload = { sub: usuario.id, fichaId: usuario.fichaId, rol: usuario.rol };
    const accessToken = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRA_EN || '15m' });
    const refreshToken = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });
    res.json({ accessToken, refreshToken, usuario: { id: usuario.id, nombre: usuario.nombre, rol: usuario.rol, fichaId: usuario.fichaId } });
  } catch (error) { next(error); }
});

router.post('/token-dispositivo', autenticar, async (req, res, next) => {
  try {
    const { token } = req.body;
    if (!token || typeof token !== 'string') return res.status(400).json({ error: 'Token FCM inválido' });
    await prisma.usuario.update({ where: { id: req.usuario.sub }, data: { tokenDispositivo: token } });
    res.status(204).end();
  } catch (error) { next(error); }
});

export default router;
