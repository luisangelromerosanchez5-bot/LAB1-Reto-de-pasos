import test from 'node:test';
import assert from 'node:assert/strict';
import { validarAporte } from '../src/controladores/aportes.js';
import { normalizarTabla } from '../src/tiempo-real/tabla.js';

test('acepta un incremento plausible', () => assert.equal(validarAporte({ pasos: 250, minutos: 1 }), null));
test('rechaza incrementos imposibles en el servidor', () => assert.match(validarAporte({ pasos: 251, minutos: 1 }), /no plausible/));
test('rechaza valores no enteros o minutos inválidos', () => assert.match(validarAporte({ pasos: 1.5, minutos: 0 }), /enteros positivos/));

test('convierte BigInt de PostgreSQL a números serializables', () => {
  const tabla = normalizarTabla([{ id: 1n, nombre: 'ADSO 228118', total: 500n, puesto: 1n }]);
  assert.deepEqual(tabla, [{ id: 1, nombre: 'ADSO 228118', total: 500, puesto: 1 }]);
  assert.doesNotThrow(() => JSON.stringify(tabla));
});
