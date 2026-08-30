import jwt from 'jsonwebtoken';

export function autenticar(req, res, next) {
  const cabecera = req.get('authorization');
  const token = cabecera?.startsWith('Bearer ') ? cabecera.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'Token de acceso requerido' });
  try {
    req.usuario = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Token inválido o vencido' });
  }
}

export function requiereRol(...roles) {
  return (req, res, next) => roles.includes(req.usuario?.rol)
    ? next()
    : res.status(403).json({ error: 'No tiene permiso para esta acción' });
}
