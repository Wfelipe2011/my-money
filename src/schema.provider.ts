import { Injectable } from '@nestjs/common';
import { IInvoiceSchema } from './interfaces';
import { Invoice, invoiceSchema } from './invoice.schema';
import { transactionCategorySchema } from './category.schema';

@Injectable()
export class SchemaProvider {
  private schemas: Map<string, IInvoiceSchema<any>> = new Map();

  constructor() {
    this.registerSchema({
      name: 'invoice',
      schema: invoiceSchema,
    });
    this.registerSchema({
      name: 'transactionCategory',
      schema: transactionCategorySchema,
    });
  }

  registerSchema(invoiceSchema: IInvoiceSchema<any>): void {
    this.schemas.set(invoiceSchema.name, invoiceSchema);
  }

  getSchema(name: string): IInvoiceSchema<any> | undefined {
    return this.schemas.get(name);
  }
}

