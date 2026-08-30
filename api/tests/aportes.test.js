import test from 'node:test';
import assert from 'node:assert/strict';
import { validarAporte } from '../src/controladores/aportes.js';

test('acepta un incremento plausible', () => assert.equal(validarAporte({ pasos: 250, minutos: 1 }), null));
test('rechaza incrementos imposibles en el servidor', () => assert.match(validarAporte({ pasos: 251, minutos: 1 }), /no plausible/));
test('rechaza valores no enteros o minutos inválidos', () => assert.match(validarAporte({ pasos: 1.5, minutos: 0 }), /enteros positivos/));
