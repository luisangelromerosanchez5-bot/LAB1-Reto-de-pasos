import crypto from 'node:crypto';

const COSTO = 16384;

export function hashContrasena(contrasena) {
  const sal = crypto.randomBytes(16).toString('hex');
  const hash = crypto.scryptSync(contrasena, sal, 64, { N: COSTO }).toString('hex');
  return `scrypt$${sal}$${hash}`;
}

export function verificarContrasena(contrasena, almacenada) {
  const [algoritmo, sal, hash] = String(almacenada).split('$');
  if (algoritmo !== 'scrypt' || !sal || !hash) return false;
  const calculada = crypto.scryptSync(contrasena, sal, 64, { N: COSTO });
  const esperada = Buffer.from(hash, 'hex');
  return esperada.length === calculada.length && crypto.timingSafeEqual(esperada, calculada);
}
