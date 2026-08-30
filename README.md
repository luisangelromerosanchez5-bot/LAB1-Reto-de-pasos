# P7 · Reto de pasos entre fichas

Base inicial (scaffold) del miniproyecto P7 del banco "Sensores en Flutter" (SENA · CEET · ADSO).
Este repositorio **no está terminado**: trae la estructura obligatoria, las dependencias
configuradas y el código clave que ya traía la guía, para que el equipo complete el resto
siguiendo el documento "Actividad No. 5 · Paso a paso P7.docx".

## Estructura

```
proyecto-p7/
├── app/     # Flutter (interfaz, sensor de pasos, sockets)
├── api/     # Node.js + Express + Prisma + Socket.IO (backend)
├── docs/    # contrato-api.md, decisiones.md, modelo-datos
└── README.md
```

## Despliegue previsto

La API está preparada para Render mediante `render.yaml`; la base PostgreSQL
remota se configura con Supabase. Nunca suba el archivo `api/.env`.

1. En Supabase, cree un proyecto y copie la conexión **pooler** a
   `DATABASE_URL` y la conexión directa a `DIRECT_URL` en Render.
2. En Render, conecte este repositorio, cree el servicio desde `render.yaml` y
   complete las variables secretas. Render ejecutará las migraciones al compilar.
3. Copie la URL HTTPS final de Render y compile Flutter con
   `--dart-define=API_URL=https://su-api.onrender.com`.
4. Para RF-05, cree el proyecto Firebase, añada `google-services.json` en
   `app/android/app/` y configure una cuenta de servicio en
   `FIREBASE_SERVICE_ACCOUNT_JSON` en Render. Ese archivo y esa variable son
   secretos y no se versionan.

## Cómo arrancar el backend (api/)

```bash
cd api
cp .env.example .env      # completar URLs de Supabase y JWT_SECRET
npm install
npx prisma migrate deploy
npm run dev                # http://localhost:3000
```

## Cómo arrancar la app (app/)

```bash
cd app
flutter pub get
flutter run --dart-define=API_URL=https://su-api.onrender.com
```

## Qué ya trae este scaffold

- Cliente Flutter con ingreso, permiso de actividad física, contador persistente y tabla en vivo.
- `pubspec.yaml` con las dependencias que exige el proyecto: `pedometer`, `shared_preferences`,
  `socket_io_client`, `firebase_messaging`, `dio`, `flutter_riverpod`.
- `api/prisma/schema.prisma` con el modelo de datos de fichas, usuarios, retos y aportes.
- `api/src/index.js` con Express, Socket.IO y el middleware de autenticación de sockets ya
  conectados entre sí.
- El contador de pasos (`contador_pasos.dart`) y la tabla en tiempo real
  (`tiempo-real/tabla.js`) tal como aparecen en la guía, listos para integrarse con el resto
  de la app.
- `docs/contrato-api.md` y `docs/decisiones.md` con las plantillas que el equipo debe llenar.

## Qué le falta al equipo (ver el Word paso a paso)

- Completar la configuración nativa de Firebase Cloud Messaging y probar las notificaciones en teléfonos físicos.
- Registrar en `docs/decisiones.md` las mediciones reales de al menos dos equipos.
