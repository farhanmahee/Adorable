import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import bcrypt from 'bcrypt';

export async function registerAuthRoutes(server: FastifyInstance) {
  // POST /auth/login
  server.post('/auth/login', async (request: FastifyRequest, reply: FastifyReply) => {
    const body = request.body as any;
    const { email, password } = body || {};

    // TODO: Replace with real user lookup + bcrypt.compare + JWT sign
    if (!email || !password) {
      return reply.status(400).send({ error: 'email and password required' });
    }

    // Placeholder: always return a fake token (replace in prod)
    const token = server.jwt?.sign ? server.jwt.sign({ sub: 'placeholder-user-id', email }) : 'token-placeholder';

    return reply.send({
      token,
      expiresIn: 3600
    });
  });

  // POST /auth/register (admin only)
  server.post('/auth/register', { preHandler: [] }, async (request: FastifyRequest, reply: FastifyReply) => {
    const body = request.body as any;
    // TODO: enforce RBAC; validate payload; hash password; create user
    return reply.status(201).send({
      id: 'new-user-id',
      email: body?.email,
      name: body?.name || null,
      roleId: body?.roleId || null,
      isActive: true
    });
  });
}
