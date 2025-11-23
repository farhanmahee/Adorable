const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log('Seeding...');

  // Roles
  const adminRole = await prisma.role.upsert({
    where: { name: 'superadmin' },
    update: {},
    create: { name: 'superadmin', permissions: ['*'] },
  });

  // Super admin user
  const pwHash = 'hashed-placeholder'; // replace with real hash or use script to hash
  await prisma.user.upsert({
    where: { email: 'superadmin@example.com' },
    update: {},
    create: {
      email: 'superadmin@example.com',
      name: 'Super Admin',
      passwordHash: Admin123,
      roleId: adminRole.id,
    },
  });

  // One branch + warehouse
  const branch = await prisma.branch.upsert({
    where: { code: 'BRANCH-001' },
    update: {},
    create: { code: 'BRANCH-001', name: 'Main Branch', address: 'Head Office' },
  });

  const wh = await prisma.warehouse.upsert({
    where: { code: 'WH-001' },
    update: {},
    create: { code: 'WH-001', name: 'Main Warehouse', branchId: branch.id },
  });

  // Item types
  const emptyType = await prisma.itemType.upsert({
    where: { code: 'EMPTY' },
    update: {},
    create: { code: 'EMPTY', name: 'Empty Cylinder' },
  });

  const refillType = await prisma.itemType.upsert({
    where: { code: 'REFILL' },
    update: {},
    create: { code: 'REFILL', name: 'Refill' },
  });

  // Items
  const item1 = await prisma.item.upsert({
    where: { sku: 'CYLINDER-12-EMPTY' },
    update: {},
    create: {
      sku: 'CYLINDER-12-EMPTY',
      name: 'Empty Cylinder 12kg',
      itemTypeId: emptyType.id,
      unitPrice: 0,
      unitCost: 0,
      barcode: '000000001',
    },
  });

  // Inventory
  await prisma.inventory.upsert({
    where: { warehouseId_itemId: { warehouseId: wh.id, itemId: item1.id } },
    update: { quantity: 100 },
    create: { warehouseId: wh.id, itemId: item1.id, quantity: 100 },
  });

  console.log('Seeding finished.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
