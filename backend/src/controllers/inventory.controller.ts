import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function registerInventoryRoutes(server: FastifyInstance) {
  // GET /inventory
  server.get('/inventory', async (request: FastifyRequest, reply: FastifyReply) => {
    const q = request.query as any;
    const warehouseId = q?.warehouseId as string | undefined;
    const where: any = {};
    if (warehouseId) where.warehouseId = warehouseId;
    const items = await prisma.inventory.findMany({ where, include: { item: true } });
    return reply.send(items);
  });

  // PATCH /inventory/{inventoryId}
  server.patch('/inventory/:inventoryId', async (request: FastifyRequest, reply: FastifyReply) => {
    const { inventoryId } = request.params as any;
    const body = request.body as any;

    // TODO: Validate adjustment type, perform Prisma transaction and inventory locks
    const inv = await prisma.inventory.findUnique({ where: { id: inventoryId } });
    if (!inv) return reply.status(404).send({ error: 'Inventory record not found' });

    let newQty = Number(inv.quantity);
    const amt = Number(body.amount || 0);

    switch (body.adjustmentType) {
      case 'INCREASE':
      case 'TRANSFER_IN':
        newQty += amt;
        break;
      case 'DECREASE':
      case 'TRANSFER_OUT':
        newQty -= amt;
        break;
      case 'RESERVE':
        // basic reserve implementation
        newQty = newQty - amt;
        break;
      case 'UNRESERVE':
        newQty = newQty + amt;
        break;
      default:
        return reply.status(400).send({ error: 'Invalid adjustmentType' });
    }

    const updated = await prisma.inventory.update({ where: { id: inventoryId }, data: { quantity: newQty } });
    return reply.send(updated);
  });
}
