import { Injectable } from '@nestjs/common';
import { ChatGoogleGenerativeAI } from "@langchain/google-genai";
import { StructuredOutputParser } from '@langchain/core/output_parsers';
import { SchemaProvider } from '../schema.provider';
import { PromptProvider } from '../prompt.provider';

const llm = new ChatGoogleGenerativeAI({
  model: "gemini-2.5-flash",
  temperature: 0
});

@Injectable()
export class ExtractService {
  constructor(
    private readonly schemaProvider: SchemaProvider,
    private readonly promptProvider: PromptProvider,
  ) { }

  async execute<T>(text: string, schemaName: string, promptName: string): Promise<T> {
    const invoiceSchema = this.schemaProvider.getSchema(schemaName);
    if (!invoiceSchema) {
      throw new Error(`Schema with name ${schemaName} not found.`);
    }

    const promptTemplate = this.promptProvider.getPrompt(promptName);
    if (!promptTemplate) {
      throw new Error(`Prompt template with name ${promptName} not found.`);
    }

    const parser = StructuredOutputParser.fromZodSchema(invoiceSchema.schema);

    const formattedPrompt = await promptTemplate.template.format({
      text: text,
    });

    const response = await llm.invoke(formattedPrompt + `\n\n${parser.getFormatInstructions()}`);

    return parser.parse(response.content as string) as T;
  }
}