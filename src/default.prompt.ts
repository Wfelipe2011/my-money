import { ChatPromptTemplate } from "@langchain/core/prompts";

export const defaultPromptTemplate = ChatPromptTemplate.fromMessages([
  [
    "system",
    `Você é um algoritmo de extração especialista.
Extraia apenas informações relevantes do texto.
Se você não souber o valor de um atributo solicitado para extrair,
retorne null para o valor do atributo.`,
  ],
  ["human", "{text}"],
]);

