import { Injectable } from '@nestjs/common';
import { ExtractService } from './domain/extract.service';
import { Invoice } from './invoice.schema';
import dayjs from 'dayjs';
import { PrismaService } from './prisma/prisma.service';
import { DiaSemana } from '@prisma/client';
import { parseDate } from './utils/parseDate';
import { HttpService } from '@nestjs/axios';
import { TransactionCategory } from './category.schema';

const DiaSemanaMap: DiaSemana[] = [
  DiaSemana.DOMINGO,
  DiaSemana.SEGUNDA,
  DiaSemana.TERCA,
  DiaSemana.QUARTA,
  DiaSemana.QUINTA,
  DiaSemana.SEXTA,
  DiaSemana.SABADO,
];

@Injectable()
export class AppService {
  constructor(
    readonly extractService: ExtractService,
    readonly prismaService: PrismaService,
    readonly httpService: HttpService,
  ) { }

  async saveStatements(text: string, cartaoId: number, cb: (progress: number) => void = () => { }) {
    console.log(`[AppService#saveStatements] Iniciando salvamento de extratos para o cartão ID: ${cartaoId}`);
    try {
      await this.prismaService.$transaction(async (prisma) => {
        console.log('[AppService#saveStatements] Extraindo informações do texto...');
        const statements = await this.extractService.execute<Invoice>(text, 'invoice', 'default');
        cb(3);
        console.log('[AppService#saveStatements] Informações extraídas com sucesso:', statements);

        console.log('[AppService#saveStatements] Transformando os dados extraídos...');
        const invoices = this.transformToIInvoice(statements);
        console.log('[AppService#saveStatements] Dados transformados com sucesso:', invoices);

        if (invoices.length === 0) {
          console.log('[AppService#saveStatements] Nenhum lançamento para processar. Finalizando.');
          return;
        }

        console.log('[AppService#saveStatements] Calculando o intervalo de datas (mínimo e máximo)...');
        const minDate = dayjs(Math.min(...invoices.map(i => i.data.getTime())));
        const maxDate = dayjs(Math.max(...invoices.map(i => i.data.getTime())));
        console.log(`[AppService#saveStatements] Intervalo de datas calculado: de ${minDate.toISOString()} até ${maxDate.toISOString()}`);

        console.log('[AppService#saveStatements] Deletando lançamentos existentes no intervalo de datas...');
        const deleteResult = await prisma.lancamentoCartao.deleteMany({
          where: {
            cartaoId,
            empresaId: 2,
            data: {
              gte: minDate.toDate(),
              lte: maxDate.toDate(),
            }
          }
        });

        console.log(`[AppService#saveStatements] ${deleteResult.count} lançamentos deletados com sucesso.`);

        const dataToCreate = invoices.map((i) => ({
          cartaoId,
          diaSemana: DiaSemanaMap[dayjs(i.data).day()],
          empresaId: 2,
          data: i.data,
          descricao: i.descricao,
          numeroParcela: i.parcela || null,
          totalParcelas: i.total_parcelas || null,
          valor: i.valor || 0,
        }));
        console.log('[AppService#saveStatements] Dados mapeados para criação:', dataToCreate);

        console.log('[AppService#saveStatements] Salvando novos lançamentos no banco de dados...');
        const createResult = await prisma.lancamentoCartao.createMany({
          data: dataToCreate,
        });
        console.log(`[AppService#saveStatements] ${createResult.count} novos lançamentos salvos com sucesso.`);
        const statementsCreated = await prisma.lancamentoCartao.findMany({
          where: {
            cartaoId,
            empresaId: 2,
            data: {
              gte: minDate.toDate(),
              lte: maxDate.toDate(),
            }
          },
        });
        const data = await this.extractService.execute<TransactionCategory>(JSON.stringify(statementsCreated), 'transactionCategory', 'transactionCategory');

        cb(4);
        await Promise.all(data.map(d => prisma.lancamentoCartao.update({
          where: { id: d.id },
          data: {
            categoriaId: d.categoryId,
          }
        })));
        console.log('[AppService#saveStatements] Lançamentos atualizados com as categorias com sucesso.');
        cb(5);
      }, { timeout: 300000 }); // 5 minutos

    } catch (error) {
      console.error('[AppService#saveStatements] Ocorreu um erro ao salvar os extratos:', error);
      throw error;
    }
  }

  transformToIInvoice(invoice: Invoice) {
    console.log('[AppService#transformToIInvoice] Iniciando transformação da fatura:', invoice);
    if (!invoice.transacoes) {
      console.error('[AppService#transformToIInvoice] Erro: Vencimento e transações são obrigatórios.');
      throw new Error('Transacoes are required');
    }

    console.log('[AppService#transformToIInvoice] Mapeando transações...');
    const result = invoice.transacoes
      .filter(t => Boolean(t.data))
      .map((t, index) => {
        console.log(`[AppService#transformToIInvoice] Processando transação #${index + 1}:`, t);

        const transformedTransaction = {
          data: parseDate(t.data!, invoice?.vencimento || undefined),
          descricao: t.descricao || '',
          parcela: t.parcela,
          total_parcelas: t.total_parcelas,
          valor: t.valor
        };
        console.log(`[AppService#transformToIInvoice] Transação #${index + 1} transformada:`, transformedTransaction);
        return transformedTransaction;
      });

    console.log('[AppService#transformToIInvoice] Transformação concluída. Resultado final:', result);
    return result;
  }
}