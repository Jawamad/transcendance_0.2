import Fastify from 'fastify';

// Créer une instance Fastify
const fastify = Fastify({ logger: true });

// Route test
fastify.get('/', async () => {
  return { status: 'ok', message: 'Backend is running!' };
});

// Lancer le serveur
const start = async () => {
  try {
    await fastify.listen({ port: 3000, host: '0.0.0.0' });
    console.log('Server started on http://0.0.0.0:3000');
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};

start();
