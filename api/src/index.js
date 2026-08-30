import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import http from 'http';
import { Server } from 'socket.io';
import swaggerUi from 'swagger-ui-express';
import { montarTiempoReal } from './tiempo-real/tabla.js';
import retosRouter from './rutas/retos.js';
import aportesRouter from './rutas/aportes.js';
import authRouter from './rutas/auth.js';
import { manejadorErrores } from './middlewares/errores.js';
import { especificacionSwagger } from './swagger.js';

const app = express();
app.use(cors({ origin: process.env.CLIENTE_ORIGEN?.split(',') || '*'}));
app.use(express.json());
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(especificacionSwagger, { explorer: true }));
app.get('/api/openapi.json', (_req, res) => res.json(especificacionSwagger));

// TODO (equipo): montar aquí las rutas reales cuando estén listas.
app.use('/api/auth', authRouter);
app.use('/api/retos', retosRouter);
app.use('/api/aportes', aportesRouter);

app.get('/api/salud', (_req, res) => res.json({ estado: 'ok' }));

app.use(manejadorErrores);

const servidor = http.createServer(app);
const io = new Server(servidor, { cors: { origin: process.env.CLIENTE_ORIGEN?.split(',') || '*' } });

// Ya viene conectado: ver src/tiempo-real/tabla.js (código clave de la guía).
montarTiempoReal(io);
app.set('io', io);

const PUERTO = process.env.PORT || 3000;
servidor.listen(PUERTO, () => {
  console.log(`API P7 escuchando en http://localhost:${PUERTO}`);
});
