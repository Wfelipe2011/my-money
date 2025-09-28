import { z } from 'zod';
import { ChatPromptTemplate } from '@langchain/core/prompts';

export interface IInvoiceSchema<T extends z.ZodTypeAny> {
  name: string;
  schema: T;
}

export interface IPromptTemplate {
  name: string;
  template: ChatPromptTemplate;
}

export interface IExtractionService {
  extract(text: string, schemaName: string, promptName: string): Promise<any>;
}

