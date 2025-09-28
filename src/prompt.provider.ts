import { Injectable } from '@nestjs/common';
import { IPromptTemplate } from './interfaces';
import { defaultPromptTemplate } from './default.prompt';

@Injectable()
export class PromptProvider {
  private prompts: Map<string, IPromptTemplate> = new Map();

  constructor() {
    this.registerPrompt({
      name: 'default',
      template: defaultPromptTemplate,
    });
  }

  registerPrompt(promptTemplate: IPromptTemplate): void {
    this.prompts.set(promptTemplate.name, promptTemplate);
  }

  getPrompt(name: string): IPromptTemplate | undefined {
    return this.prompts.get(name);
  }
}

