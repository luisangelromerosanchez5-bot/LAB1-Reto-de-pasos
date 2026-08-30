# Decisiones técnicas · P7 Reto de pasos entre fichas

> Este es el archivo que más pesa en la nota (ver guía, sección 1.3).
> Cada umbral y cada constante debe quedar sustentada con una prueba real,
> no con un valor inventado. Complételo a medida que avanza, no al final.

## Tope de pasos por minuto (RF-06)

- Valor usado: `250 pasos/minuto`.
- ¿De dónde sale este número? Completar con la prueba hecha en equipo real
  (ej.: "se corrió en el patio del CEET a ritmo máximo y se midió X pasos/min").
- ¿Qué pasa si el equipo real del aprendiz supera ese ritmo caminando?
  Documentar el caso límite observado.

## Corrección por reinicio del contador de pasos

- Estrategia usada: conservar el acumulado y reiniciar la base a 0
  (ver `contador_pasos.dart`).
- Prueba realizada: describir cómo se verificó en dispositivo físico
  (reiniciar el equipo a mitad del conteo y comprobar que no se duplican
  ni se pierden pasos).

## Frecuencia de envío del acumulado (RF-03)

- Valor usado: cada _____ minutos / horas.
- Justificación: equilibrio entre batería, consumo de datos y qué tan "en
  vivo" se ve la tabla de posiciones.

## Limitaciones declaradas

- El sensor de pasos por hardware no está disponible en todos los equipos
  de gama baja (ver matriz de cobertura de la guía). Documentar aquí qué
  hace la app en ese caso (¿modo respaldo con acelerómetro? ¿mensaje claro
  al usuario?).
- Las notificaciones push dependen de que el equipo tenga Google Play
  Services; documentar el comportamiento cuando no está disponible.

## Pruebas en equipos físicos

| Equipo | Versión de Android | Resultado |
|---|---|---|
| | | |
| | | |
