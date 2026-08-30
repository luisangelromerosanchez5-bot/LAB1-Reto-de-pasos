import swaggerJSDoc from 'swagger-jsdoc';

const opciones = {
  definition: {
    openapi: '3.0.3',
    info: {
      title: 'API P7 - Reto de pasos entre fichas',
      version: '1.0.0',
      description: 'API para autenticar aprendices, crear retos y registrar pasos.',
    },
    servers: [{ url: '/', description: 'Servidor actual' }],
    components: {
      securitySchemes: { bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' } },
      schemas: {
        Error: { type: 'object', properties: { error: { type: 'string' } } },
        Login: { type: 'object', required: ['correo', 'contrasena'], properties: { correo: { type: 'string', format: 'email', example: 'aprendiz@ejemplo.com' }, contrasena: { type: 'string', format: 'password', example: 'ClaveSegura123!' } } },
        Aporte: { type: 'object', required: ['retoId', 'pasos', 'minutos'], properties: { retoId: { type: 'string', format: 'uuid' }, pasos: { type: 'integer', minimum: 0, example: 250 }, minutos: { type: 'integer', minimum: 1, example: 60 } } },
        Reto: { type: 'object', required: ['nombre', 'iniciaEn', 'finalizaEn'], properties: { nombre: { type: 'string', example: 'Reto septiembre' }, iniciaEn: { type: 'string', format: 'date-time' }, finalizaEn: { type: 'string', format: 'date-time' } } },
      },
    },
    paths: {
      '/api/salud': { get: { summary: 'Comprueba que la API está disponible', responses: { 200: { description: 'API disponible' } } } },
      '/api/auth/login': { post: { summary: 'Inicia sesión y devuelve tokens JWT', requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/Login' } } } }, responses: { 200: { description: 'Sesión iniciada' }, 401: { description: 'Credenciales inválidas', content: { 'application/json': { schema: { $ref: '#/components/schemas/Error' } } } } } } },
      '/api/auth/token-dispositivo': { post: { summary: 'Registra el token Firebase del dispositivo', security: [{ bearerAuth: [] }], requestBody: { required: true, content: { 'application/json': { schema: { type: 'object', required: ['token'], properties: { token: { type: 'string' } } } } } }, responses: { 204: { description: 'Token registrado' }, 401: { description: 'No autorizado' } } } },
      '/api/retos': { get: { summary: 'Lista los retos', security: [{ bearerAuth: [] }], responses: { 200: { description: 'Lista de retos' }, 401: { description: 'No autorizado' } } }, post: { summary: 'Crea un reto (solo instructor)', security: [{ bearerAuth: [] }], requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/Reto' } } } }, responses: { 201: { description: 'Reto creado' }, 403: { description: 'No autorizado por rol' } } } },
      '/api/retos/{id}/tabla': { get: { summary: 'Obtiene la tabla de posiciones', security: [{ bearerAuth: [] }], parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }], responses: { 200: { description: 'Tabla de fichas' }, 404: { description: 'Reto no encontrado' } } } },
      '/api/aportes': { post: { summary: 'Registra un delta de pasos', description: 'El servidor rechaza valores mayores a 250 pasos por minuto.', security: [{ bearerAuth: [] }], requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/Aporte' } } } }, responses: { 201: { description: 'Aporte registrado' }, 422: { description: 'Incremento no plausible' } } } },
    },
  },
  apis: [],
};

export const especificacionSwagger = swaggerJSDoc(opciones);
