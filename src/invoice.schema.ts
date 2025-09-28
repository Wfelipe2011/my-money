import { z } from "zod";

export const invoiceSchema = z.object({
  vencimento: z.string().nullish().describe("The due date of the invoice in 'YYYY-MM-DD' format."),
  transacoes: z.array(z.object({
    data: z.string().nullish().describe("The date of the transaction. Can be in 'MM-DD', 'YYYY-MM-DD'"),
    descricao: z.string().nullish().describe("Description of the transaction."),
    parcela: z.number().nullish().describe("Installment information, if applicable."),
    total_parcelas: z.number().nullish().describe("Total number of installments, if applicable."),
    valor: z.number().nullish().describe("The amount of the transaction."),
  })).nullish(),
  total_cartao: z.number().nullish().describe("The total amount for the card."),
});

export type Invoice = z.infer<typeof invoiceSchema>;