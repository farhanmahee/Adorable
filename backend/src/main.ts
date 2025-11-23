import Fastify from 'fastify';
import fastifyJwt from '@fastify/jwt';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const server = Fastify({ logger: true });

server.register(fastifyJwt, { secret: process.env.JWT_SECRET || 'replace_this' });

server.get('/', async () => ({ status: 'ok' }));

// Health
server.get('/health', async () => {
  return { ok: true, db: true };
});

// Minimal auth placeholder
server.post('/auth/login', async (request, reply) => {
  // implement lookup, verify password with bcrypt and sign JWT
  return { token: 'placeholder' };
});

// Example items route
server.get('/api/items', async (request, reply) => {
  const items = await prisma.item.findMany({ take: 50 });
  return items;
});

const start = async () => {
  try {
    await server.listen({ port: Number(process.env.PORT || 8000), host: '0.0.0.0' });
    console.log('Server running');
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
};

start();
