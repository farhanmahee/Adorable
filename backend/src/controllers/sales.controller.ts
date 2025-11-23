import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function registerSalesRoutes(server: FastifyInstance) {
  // POST /sales/orders
  server.post('/sales/orders', async (request: FastifyRequest, reply: FastifyReply) => {
    const body = request.body as any;
    // TODO: validate customer, check inventory reservations, create items
    const so = await prisma.salesOrder.create({
      data: {
        orderNo: body.orderNo,
        customerId: body.customerId,
        status: 'DRAFT',
        items: {
          create: (body.items || []).map((it: any) => ({
            itemId: it.itemId,
            quantity: it.quantity,
            unitPrice: it.unitPrice
          }))
        },
        totalAmount: body.totalAmount ?? 0
      },
      include: { items: true }
    });
    return reply.status(201).send(so);
  });

  // GET /sales/orders
  server.get('/sales/orders', async (request: FastifyRequest, reply: FastifyReply) => {
    const list = await prisma.salesOrder.findMany({ include: { items: true } });
    return reply.send(list);
  });

  // POST /sales/orders/{orderId}/status
  server.post('/sales/orders/:orderId/status', async (request: FastifyRequest, reply: FastifyReply) => {
    const { orderId } = request.params as any;
    const body = request.body as any;
    const allowed = ['DRAFT', 'CONFIRMED', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED'];
    if (!allowed.includes(body.status)) return reply.status(400).send({ error: 'Invalid status' });

    // TODO: implement reservation release/debit on delivered, transactional updates
    const updated = await prisma.salesOrder.update({ where: { id: orderId }, data: { status: body.status } });
    return reply.send(updated);
  });
}
