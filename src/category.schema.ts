import { z } from "zod";

export const transactionCategorySchema = z.array(z.object({
  id: z.number(),
  description: z.string(),
  categoryId: z.number(),
  categoryName: z.string(),
}));

export type TransactionCategory = z.infer<typeof transactionCategorySchema>;
