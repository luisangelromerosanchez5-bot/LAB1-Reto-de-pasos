CREATE TABLE "ficha" (
  "id" SERIAL NOT NULL,
  "nombre" TEXT NOT NULL,
  CONSTRAINT "ficha_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "usuario" (
  "id" SERIAL NOT NULL,
  "nombre" TEXT NOT NULL,
  "correo" TEXT NOT NULL,
  "contrasena_sha" TEXT NOT NULL,
  "rol" TEXT NOT NULL DEFAULT 'aprendiz',
  "ficha_id" INTEGER NOT NULL,
  "token_dispositivo" TEXT,
  "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "usuario_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "usuario_correo_key" ON "usuario"("correo");

CREATE TABLE "reto" (
  "id" TEXT NOT NULL,
  "nombre" TEXT NOT NULL,
  "inicia_en" TIMESTAMP(3) NOT NULL,
  "finaliza_en" TIMESTAMP(3) NOT NULL,
  "activo" BOOLEAN NOT NULL DEFAULT true,
  CONSTRAINT "reto_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "aporte" (
  "id" TEXT NOT NULL,
  "usuario_id" INTEGER NOT NULL,
  "ficha_id" INTEGER NOT NULL,
  "reto_id" TEXT NOT NULL,
  "pasos" INTEGER NOT NULL,
  "registrado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "aporte_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "aporte_reto_id_idx" ON "aporte"("reto_id");
CREATE INDEX "aporte_usuario_id_reto_id_registrado_en_idx" ON "aporte"("usuario_id", "reto_id", "registrado_en");
ALTER TABLE "usuario" ADD CONSTRAINT "usuario_ficha_id_fkey" FOREIGN KEY ("ficha_id") REFERENCES "ficha"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "aporte" ADD CONSTRAINT "aporte_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "aporte" ADD CONSTRAINT "aporte_ficha_id_fkey" FOREIGN KEY ("ficha_id") REFERENCES "ficha"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "aporte" ADD CONSTRAINT "aporte_reto_id_fkey" FOREIGN KEY ("reto_id") REFERENCES "reto"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
