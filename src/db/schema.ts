import {
  pgTable,
  text,
  timestamp,
  uuid,
  json,
  pgEnum,
  integer,
  decimal,
  boolean,
  serial,
  uniqueIndex,
  index,
  foreignKey,
  primaryKey,
} from "drizzle-orm/pg-core";
import { drizzle } from "drizzle-orm/node-postgres";

export const db = drizzle(process.env.DATABASE_URL!);

// ============================================
// ENUMS
// ============================================

export const userRoleEnum = pgEnum("user_role", [
  "admin",
  "manager",
  "accountant",
  "sales_executive",
  "purchase_executive",
  "warehouse_staff",
  "viewer",
]);

export const cylinderStatusEnum = pgEnum("cylinder_status", [
  "empty",
  "refilled",
  "in_transit",
  "damaged",
  "retired",
  "in_stock",
]);

export const transactionTypeEnum = pgEnum("transaction_type", [
  "purchase",
  "sales",
  "transfer",
  "adjustment",
  "damage",
  "remaking",
]);

export const voucherStatusEnum = pgEnum("voucher_status", [
  "draft",
  "pending",
  "approved",
  "rejected",
  "posted",
]);

export const documentTypeEnum = pgEnum("document_type", [
  "grn", // Goods Receipt Note
  "wo", // Work Order
  "invoice",
  "quotation",
  "proforma",
]);

export const paymentStatusEnum = pgEnum("payment_status", [
  "unpaid",
  "partial",
  "paid",
  "overdue",
]);

// ============================================
// MASTER DATA
// ============================================

export const organizationTable = pgTable("organizations", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: text("name").notNull(),
  shortCode: text("short_code").notNull().unique(),
  registrationNumber: text("registration_number"),
  binNumber: text("bin_number"),
  address: text("address"),
  phone: text("phone"),
  email: text("email"),
  country: text("country").default("Bangladesh"),
  fiscalYearStart: integer("fiscal_year_start").default(1), // Month
  isMultiBranch: boolean("is_multi_branch").default(false),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const branchTable = pgTable("branches", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id, { onDelete: "cascade" }),
  name: text("name").notNull(),
  code: text("code").notNull(),
  address: text("address"),
  phone: text("phone"),
  warehouseId: uuid("warehouse_id"),
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const warehouseTable = pgTable("warehouses", {
  id: uuid("id").primaryKey().defaultRandom(),
  branchId: uuid("branch_id")
    .notNull()
    .references(() => branchTable.id, { onDelete: "cascade" }),
  name: text("name").notNull(),
  code: text("code").notNull(),
  location: text("location"),
  capacity: integer("capacity"),
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const usersTable = pgTable("users", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id, { onDelete: "cascade" }),
  email: text("email").notNull().unique(),
  name: text("name").notNull(),
  phone: text("phone"),
  role: userRoleEnum("role").notNull().default("viewer"),
  branchIds: text("branch_ids"), // JSON array of branch IDs
  isActive: boolean("is_active").default(true),
  passwordHash: text("password_hash"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const customersTable = pgTable("customers", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id, { onDelete: "cascade" }),
  name: text("name").notNull(),
  phone: text("phone"),
  email: text("email"),
  address: text("address"),
  city: text("city"),
  country: text("country").default("Bangladesh"),
  binNumber: text("bin_number"),
  tradeLicense: text("trade_license"),
  creditLimit: decimal("credit_limit", { precision: 15, scale: 2 }).default("0"),
  paymentTerms: text("payment_terms"), // e.g., "Net 30"
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const suppliersTable = pgTable("suppliers", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id, { onDelete: "cascade" }),
  name: text("name").notNull(),
  phone: text("phone"),
  email: text("email"),
  address: text("address"),
  city: text("city"),
  country: text("country").default("Bangladesh"),
  binNumber: text("bin_number"),
  paymentTerms: text("payment_terms"),
  leadTime: integer("lead_time"), // days
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const productsTable = pgTable("products", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id, { onDelete: "cascade" }),
  name: text("name").notNull(),
  code: text("code").notNull(),
  description: text("description"),
  type: text("type").notNull(), // e.g., "cylinder", "service", "package"
  unit: text("unit").default("unit"), // kg, liter, piece, service, etc.
  weight: decimal("weight", { precision: 10, scale: 2 }),
  standardCost: decimal("standard_cost", { precision: 15, scale: 2 }),
  sellingPrice: decimal("selling_price", { precision: 15, scale: 2 }),
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

// ============================================
// INVENTORY MANAGEMENT
// ============================================

export const cylinderInventoryTable = pgTable("cylinder_inventory", {
  id: uuid("id").primaryKey().defaultRandom(),
  warehouseId: uuid("warehouse_id")
    .notNull()
    .references(() => warehouseTable.id),
  productId: uuid("product_id")
    .notNull()
    .references(() => productsTable.id),
  cylinderId: text("cylinder_id").notNull(), // Unique physical ID
  status: cylinderStatusEnum("status").default("empty"),
  currentLocation: text("current_location"),
  lastRefillDate: timestamp("last_refill_date"),
  lastServiceDate: timestamp("last_service_date"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const stockMovementTable = pgTable("stock_movements", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  warehouseId: uuid("warehouse_id")
    .notNull()
    .references(() => warehouseTable.id),
  productId: uuid("product_id")
    .notNull()
    .references(() => productsTable.id),
  movementType: transactionTypeEnum("movement_type"),
  quantity: decimal("quantity", { precision: 15, scale: 2 }).notNull(),
  referenceDocumentId: text("reference_document_id"),
  notes: text("notes"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

export const stockBalanceTable = pgTable("stock_balance", {
  id: uuid("id").primaryKey().defaultRandom(),
  warehouseId: uuid("warehouse_id")
    .notNull()
    .references(() => warehouseTable.id),
  productId: uuid("product_id")
    .notNull()
    .references(() => productsTable.id),
  quantity: decimal("quantity", { precision: 15, scale: 2 }).notNull().default("0"),
  costValue: decimal("cost_value", { precision: 15, scale: 2 }).default("0"),
  averageCost: decimal("average_cost", { precision: 15, scale: 2 }).default("0"),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

// ============================================
// PURCHASE MANAGEMENT
// ============================================

export const purchaseOrderTable = pgTable("purchase_orders", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  poNumber: text("po_number").notNull().unique(),
  supplierId: uuid("supplier_id")
    .notNull()
    .references(() => suppliersTable.id),
  orderDate: timestamp("order_date").notNull().defaultNow(),
  expectedDeliveryDate: timestamp("expected_delivery_date"),
  status: text("status").default("draft"), // draft, confirmed, partial_received, completed, cancelled
  totalAmount: decimal("total_amount", { precision: 15, scale: 2 }).default("0"),
  notes: text("notes"),
  createdBy: uuid("created_by").references(() => usersTable.id),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const purchaseOrderItemsTable = pgTable("purchase_order_items", {
  id: uuid("id").primaryKey().defaultRandom(),
  poId: uuid("po_id")
    .notNull()
    .references(() => purchaseOrderTable.id, { onDelete: "cascade" }),
  productId: uuid("product_id")
    .notNull()
    .references(() => productsTable.id),
  quantity: decimal("quantity", { precision: 15, scale: 2 }).notNull(),
  unitPrice: decimal("unit_price", { precision: 15, scale: 2 }).notNull(),
  lineTotal: decimal("line_total", { precision: 15, scale: 2 }).notNull(),
  receivedQuantity: decimal("received_quantity", { precision: 15, scale: 2 }).default("0"),
});

export const goodsReceiptNoteTable = pgTable("goods_receipt_notes", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  grnNumber: text("grn_number").notNull().unique(),
  poId: uuid("po_id")
    .notNull()
    .references(() => purchaseOrderTable.id),
  warehouseId: uuid("warehouse_id")
    .notNull()
    .references(() => warehouseTable.id),
  receiptDate: timestamp("receipt_date").notNull().defaultNow(),
  status: voucherStatusEnum("status").default("draft"),
  totalAmount: decimal("total_amount", { precision: 15, scale: 2 }).default("0"),
  approvedBy: uuid("approved_by").references(() => usersTable.id),
  approvalDate: timestamp("approval_date"),
  createdBy: uuid("created_by").references(() => usersTable.id),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const grnItemsTable = pgTable("grn_items", {
  id: uuid("id").primaryKey().defaultRandom(),
  grnId: uuid("grn_id")
    .notNull()
    .references(() => goodsReceiptNoteTable.id, { onDelete: "cascade" }),
  productId: uuid("product_id")
    .notNull()
    .references(() => productsTable.id),
  quantity: decimal("quantity", { precision: 15, scale: 2 }).notNull(),
  unitPrice: decimal("unit_price", { precision: 15, scale: 2 }).notNull(),
  lineTotal: decimal("line_total", { precision: 15, scale: 2 }).notNull(),
});

export const purchaseReturnTable = pgTable("purchase_returns", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  returnNumber: text("return_number").notNull().unique(),
  poId: uuid("po_id")
    .notNull()
    .references(() => purchaseOrderTable.id),
  returnDate: timestamp("return_date").notNull().defaultNow(),
  totalAmount: decimal("total_amount", { precision: 15, scale: 2 }).default("0"),
  reason: text("reason"),
  status: text("status").default("draft"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

// ============================================
// SALES MANAGEMENT
// ============================================

export const salesOrderTable = pgTable("sales_orders", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  soNumber: text("so_number").notNull().unique(),
  customerId: uuid("customer_id")
    .notNull()
    .references(() => customersTable.id),
  branchId: uuid("branch_id")
    .notNull()
    .references(() => branchTable.id),
  orderDate: timestamp("order_date").notNull().defaultNow(),
  deliveryDate: timestamp("delivery_date"),
  status: text("status").default("draft"), // draft, confirmed, partial_shipped, completed, cancelled
  totalAmount: decimal("total_amount", { precision: 15, scale: 2 }).default("0"),
  notes: text("notes"),
  createdBy: uuid("created_by").references(() => usersTable.id),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const salesOrderItemsTable = pgTable("sales_order_items", {
  id: uuid("id").primaryKey().defaultRandom(),
  soId: uuid("so_id")
    .notNull()
    .references(() => salesOrderTable.id, { onDelete: "cascade" }),
  productId: uuid("product_id")
    .notNull()
    .references(() => productsTable.id),
  quantity: decimal("quantity", { precision: 15, scale: 2 }).notNull(),
  unitPrice: decimal("unit_price", { precision: 15, scale: 2 }).notNull(),
  lineTotal: decimal("line_total", { precision: 15, scale: 2 }).notNull(),
  shippedQuantity: decimal("shipped_quantity", { precision: 15, scale: 2 }).default("0"),
});

export const deliveryNoteTable = pgTable("delivery_notes", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  dnNumber: text("dn_number").notNull().unique(),
  soId: uuid("so_id")
    .notNull()
    .references(() => salesOrderTable.id),
  warehouseId: uuid("warehouse_id")
    .notNull()
    .references(() => warehouseTable.id),
  deliveryDate: timestamp("delivery_date").notNull().defaultNow(),
  status: text("status").default("draft"),
  totalAmount: decimal("total_amount", { precision: 15, scale: 2 }).default("0"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

export const invoiceTable = pgTable("invoices", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  invoiceNumber: text("invoice_number").notNull().unique(),
  customerId: uuid("customer_id")
    .notNull()
    .references(() => customersTable.id),
  soId: uuid("so_id")
    .notNull()
    .references(() => salesOrderTable.id),
  invoiceDate: timestamp("invoice_date").notNull().defaultNow(),
  dueDate: timestamp("due_date"),
  subTotal: decimal("sub_total", { precision: 15, scale: 2 }).default("0"),
  taxAmount: decimal("tax_amount", { precision: 15, scale: 2 }).default("0"),
  totalAmount: decimal("total_amount", { precision: 15, scale: 2 }).default("0"),
  paymentStatus: paymentStatusEnum("payment_status").default("unpaid"),
  notes: text("notes"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const invoiceItemsTable = pgTable("invoice_items", {
  id: uuid("id").primaryKey().defaultRandom(),
  invoiceId: uuid("invoice_id")
    .notNull()
    .references(() => invoiceTable.id, { onDelete: "cascade" }),
  productId: uuid("product_id")
    .notNull()
    .references(() => productsTable.id),
  description: text("description"),
  quantity: decimal("quantity", { precision: 15, scale: 2 }).notNull(),
  unitPrice: decimal("unit_price", { precision: 15, scale: 2 }).notNull(),
  lineTotal: decimal("line_total", { precision: 15, scale: 2 }).notNull(),
});

export const paymentReceiptTable = pgTable("payment_receipts", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  receiptNumber: text("receipt_number").notNull().unique(),
  invoiceId: uuid("invoice_id")
    .notNull()
    .references(() => invoiceTable.id),
  customerId: uuid("customer_id")
    .notNull()
    .references(() => customersTable.id),
  paymentDate: timestamp("payment_date").notNull().defaultNow(),
  amount: decimal("amount", { precision: 15, scale: 2 }).notNull(),
  paymentMethod: text("payment_method"), // cash, check, bank_transfer, online
  referenceNumber: text("reference_number"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

export const salesReturnTable = pgTable("sales_returns", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  returnNumber: text("return_number").notNull().unique(),
  invoiceId: uuid("invoice_id")
    .notNull()
    .references(() => invoiceTable.id),
  customerId: uuid("customer_id")
    .notNull()
    .references(() => customersTable.id),
  returnDate: timestamp("return_date").notNull().defaultNow(),
  totalAmount: decimal("total_amount", { precision: 15, scale: 2 }).default("0"),
  reason: text("reason"),
  status: text("status").default("draft"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

// ============================================
// TRANSIT & CYLINDER MANAGEMENT
// ============================================

export const transitTable = pgTable("transits", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  transitNumber: text("transit_number").notNull().unique(),
  fromWarehouseId: uuid("from_warehouse_id")
    .notNull()
    .references(() => warehouseTable.id),
  toWarehouseId: uuid("to_warehouse_id")
    .notNull()
    .references(() => warehouseTable.id),
  transshipmentDate: timestamp("transshipment_date").notNull().defaultNow(),
  expectedArrivalDate: timestamp("expected_arrival_date"),
  status: text("status").default("in_transit"), // in_transit, received, cancelled
  totalQuantity: decimal("total_quantity", { precision: 15, scale: 2 }).default("0"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const transitItemsTable = pgTable("transit_items", {
  id: uuid("id").primaryKey().defaultRandom(),
  transitId: uuid("transit_id")
    .notNull()
    .references(() => transitTable.id, { onDelete: "cascade" }),
  productId: uuid("product_id")
    .notNull()
    .references(() => productsTable.id),
  quantity: decimal("quantity", { precision: 15, scale: 2 }).notNull(),
  costPerUnit: decimal("cost_per_unit", { precision: 15, scale: 2 }),
});

export const cylinderExchangeTable = pgTable("cylinder_exchanges", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  exchangeNumber: text("exchange_number").notNull().unique(),
  customerId: uuid("customer_id")
    .notNull()
    .references(() => customersTable.id),
  exchangeDate: timestamp("exchange_date").notNull().defaultNow(),
  emptyReturnedCount: integer("empty_returned_count").default(0),
  refillIssuedCount: integer("refill_issued_count").default(0),
  status: text("status").default("completed"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

// ============================================
// ACCOUNTING & LEDGER
// ============================================

export const chartOfAccountsTable = pgTable("chart_of_accounts", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  accountCode: text("account_code").notNull(),
  accountName: text("account_name").notNull(),
  accountType: text("account_type").notNull(), // Asset, Liability, Equity, Revenue, Expense
  accountGroup: text("account_group").notNull(), // Current Asset, Fixed Asset, etc.
  subGroup: text("sub_group"),
  balance: decimal("balance", { precision: 15, scale: 2 }).default("0"),
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const journalVoucherTable = pgTable("journal_vouchers", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  voucherNumber: text("voucher_number").notNull().unique(),
  voucherDate: timestamp("voucher_date").notNull().defaultNow(),
  referenceDocumentId: text("reference_document_id"),
  description: text("description"),
  totalDebit: decimal("total_debit", { precision: 15, scale: 2 }).default("0"),
  totalCredit: decimal("total_credit", { precision: 15, scale: 2 }).default("0"),
  status: voucherStatusEnum("status").default("draft"),
  approvedBy: uuid("approved_by").references(() => usersTable.id),
  approvalDate: timestamp("approval_date"),
  createdBy: uuid("created_by").references(() => usersTable.id),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const journalEntryTable = pgTable("journal_entries", {
  id: uuid("id").primaryKey().defaultRandom(),
  voucherId: uuid("voucher_id")
    .notNull()
    .references(() => journalVoucherTable.id, { onDelete: "cascade" }),
  accountId: uuid("account_id")
    .notNull()
    .references(() => chartOfAccountsTable.id),
  debit: decimal("debit", { precision: 15, scale: 2 }).default("0"),
  credit: decimal("credit", { precision: 15, scale: 2 }).default("0"),
  description: text("description"),
  lineNo: integer("line_no"),
});

export const ledgerTable = pgTable("ledger", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  accountId: uuid("account_id")
    .notNull()
    .references(() => chartOfAccountsTable.id),
  voucherId: uuid("voucher_id")
    .notNull()
    .references(() => journalVoucherTable.id),
  debit: decimal("debit", { precision: 15, scale: 2 }).default("0"),
  credit: decimal("credit", { precision: 15, scale: 2 }).default("0"),
  balance: decimal("balance", { precision: 15, scale: 2 }).default("0"),
  entryDate: timestamp("entry_date").notNull().defaultNow(),
  description: text("description"),
});

// ============================================
// REPORTING & ANALYTICS
// ============================================

export const reportScheduleTable = pgTable("report_schedules", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  reportType: text("report_type").notNull(), // sales, purchase, stock, accounting, etc.
  frequency: text("frequency").notNull(), // daily, weekly, monthly
  recipients: text("recipients"), // email addresses
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

export const systemSettingsTable = pgTable("system_settings", {
  id: uuid("id").primaryKey().defaultRandom(),
  organizationId: uuid("organization_id")
    .notNull()
    .references(() => organizationTable.id),
  language: text("language").default("en"), // en, bn
  dateFormat: text("date_format").default("DD/MM/YYYY"),
  currency: text("currency").default("BDT"),
  taxRate: decimal("tax_rate", { precision: 5, scale: 2 }).default("15"),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});
