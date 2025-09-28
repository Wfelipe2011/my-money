-- CreateEnum
CREATE TYPE "public"."TipoAcesso" AS ENUM ('PROPRIETARIO', 'ADMIN', 'MEMBRO');

-- CreateEnum
CREATE TYPE "public"."TipoConta" AS ENUM ('CORRENTE', 'POUPANCA', 'INVESTIMENTO');

-- CreateEnum
CREATE TYPE "public"."TipoLancamento" AS ENUM ('CREDITO', 'DEBITO');

-- CreateEnum
CREATE TYPE "public"."TipoPredicao" AS ENUM ('GASTO_RECORRENTE', 'PARCELAS', 'VARIAVEL', 'RENDA');

-- CreateEnum
CREATE TYPE "public"."FrequenciaRecorrencia" AS ENUM ('MENSAL', 'BIMESTRAL', 'TRIMESTRAL', 'SEMESTRAL', 'ANUAL');

-- CreateEnum
CREATE TYPE "public"."DiaSemana" AS ENUM ('SEGUNDA', 'TERCA', 'QUARTA', 'QUINTA', 'SEXTA', 'SABADO', 'DOMINGO');

-- CreateEnum
CREATE TYPE "public"."TipoMensagem" AS ENUM ('ALERTA', 'PREVISAO', 'HUMOR', 'DICA', 'MOTIVACIONAL', 'INSIGHT');

-- CreateTable
CREATE TABLE "public"."empresas" (
    "id" SERIAL NOT NULL,
    "nome" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "empresas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."usuarios" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "senha" TEXT NOT NULL,
    "nome" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."usuarios_empresas" (
    "id" SERIAL NOT NULL,
    "usuarioId" INTEGER NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "tipo" "public"."TipoAcesso" NOT NULL,

    CONSTRAINT "usuarios_empresas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."cartoes_credito" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "descricao" TEXT NOT NULL,
    "ultimosDigitos" TEXT NOT NULL,
    "bandeira" TEXT NOT NULL,
    "apelido" TEXT,
    "limite" DOUBLE PRECISION,
    "diaFechamento" INTEGER NOT NULL,
    "diaVencimento" INTEGER NOT NULL,
    "ativo" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cartoes_credito_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."contas_bancarias" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "banco" TEXT NOT NULL,
    "tipoConta" "public"."TipoConta" NOT NULL,
    "numeroConta" TEXT NOT NULL,
    "apelido" TEXT,
    "saldoInicial" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "ativo" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "contas_bancarias_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."lancamentos_cartao" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "cartaoId" INTEGER NOT NULL,
    "data" TIMESTAMP(3) NOT NULL,
    "descricao" TEXT NOT NULL,
    "valor" DOUBLE PRECISION NOT NULL,
    "numeroParcela" INTEGER,
    "totalParcelas" INTEGER,
    "categoriaId" INTEGER,
    "isPago" BOOLEAN NOT NULL DEFAULT false,
    "hashTransacao" TEXT NOT NULL,

    CONSTRAINT "lancamentos_cartao_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."lancamentos_conta" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "contaId" INTEGER NOT NULL,
    "data" TIMESTAMP(3) NOT NULL,
    "descricao" TEXT NOT NULL,
    "valor" DOUBLE PRECISION NOT NULL,
    "tipo" "public"."TipoLancamento" NOT NULL,
    "categoriaId" INTEGER,
    "isConciliado" BOOLEAN NOT NULL DEFAULT false,
    "hashTransacao" TEXT NOT NULL,

    CONSTRAINT "lancamentos_conta_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."categorias" (
    "id" SERIAL NOT NULL,
    "nome" TEXT NOT NULL,
    "cor" TEXT NOT NULL,
    "icone" TEXT,
    "paiId" INTEGER,
    "sistema" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "categorias_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."palavras_chave_categorias" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "categoriaId" INTEGER NOT NULL,
    "palavra" TEXT NOT NULL,

    CONSTRAINT "palavras_chave_categorias_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."predicoes" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "categoriaId" INTEGER NOT NULL,
    "mesAno" TEXT NOT NULL,
    "valorPrevisto" DOUBLE PRECISION NOT NULL,
    "valorRealizado" DOUBLE PRECISION,
    "confianca" DOUBLE PRECISION,
    "tipo" "public"."TipoPredicao" NOT NULL,
    "dataPredicao" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isAtivo" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "predicoes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."contas_recorrentes" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "categoriaId" INTEGER NOT NULL,
    "descricao" TEXT NOT NULL,
    "valor" DOUBLE PRECISION NOT NULL,
    "tipo" "public"."TipoLancamento" NOT NULL,
    "diaVencimento" INTEGER,
    "frequencia" "public"."FrequenciaRecorrencia" NOT NULL,
    "ativa" BOOLEAN NOT NULL DEFAULT true,
    "dataInicio" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "dataFim" TIMESTAMP(3),
    "confianca" DOUBLE PRECISION NOT NULL DEFAULT 1.0,

    CONSTRAINT "contas_recorrentes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."textos_diarios" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "data" TIMESTAMP(3) NOT NULL,
    "textoCurto" TEXT NOT NULL,
    "textoLongo" TEXT,
    "tipoMensagem" "public"."TipoMensagem" NOT NULL,
    "insights" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "textos_diarios_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "empresas_nome_key" ON "public"."empresas"("nome");

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_email_key" ON "public"."usuarios"("email");

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_empresas_usuarioId_empresaId_key" ON "public"."usuarios_empresas"("usuarioId", "empresaId");

-- CreateIndex
CREATE UNIQUE INDEX "lancamentos_cartao_hashTransacao_key" ON "public"."lancamentos_cartao"("hashTransacao");

-- CreateIndex
CREATE INDEX "lancamentos_cartao_cartaoId_data_idx" ON "public"."lancamentos_cartao"("cartaoId", "data");

-- CreateIndex
CREATE UNIQUE INDEX "lancamentos_conta_hashTransacao_key" ON "public"."lancamentos_conta"("hashTransacao");

-- CreateIndex
CREATE INDEX "lancamentos_conta_contaId_data_idx" ON "public"."lancamentos_conta"("contaId", "data");

-- CreateIndex
CREATE UNIQUE INDEX "textos_diarios_empresaId_data_key" ON "public"."textos_diarios"("empresaId", "data");

-- AddForeignKey
ALTER TABLE "public"."usuarios_empresas" ADD CONSTRAINT "usuarios_empresas_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "public"."usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."usuarios_empresas" ADD CONSTRAINT "usuarios_empresas_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "public"."empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."cartoes_credito" ADD CONSTRAINT "cartoes_credito_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "public"."empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."contas_bancarias" ADD CONSTRAINT "contas_bancarias_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "public"."empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."lancamentos_cartao" ADD CONSTRAINT "lancamentos_cartao_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "public"."empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."lancamentos_cartao" ADD CONSTRAINT "lancamentos_cartao_cartaoId_fkey" FOREIGN KEY ("cartaoId") REFERENCES "public"."cartoes_credito"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."lancamentos_cartao" ADD CONSTRAINT "lancamentos_cartao_categoriaId_fkey" FOREIGN KEY ("categoriaId") REFERENCES "public"."categorias"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."lancamentos_conta" ADD CONSTRAINT "lancamentos_conta_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "public"."empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."lancamentos_conta" ADD CONSTRAINT "lancamentos_conta_contaId_fkey" FOREIGN KEY ("contaId") REFERENCES "public"."contas_bancarias"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."lancamentos_conta" ADD CONSTRAINT "lancamentos_conta_categoriaId_fkey" FOREIGN KEY ("categoriaId") REFERENCES "public"."categorias"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."categorias" ADD CONSTRAINT "categorias_paiId_fkey" FOREIGN KEY ("paiId") REFERENCES "public"."categorias"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."palavras_chave_categorias" ADD CONSTRAINT "palavras_chave_categorias_categoriaId_fkey" FOREIGN KEY ("categoriaId") REFERENCES "public"."categorias"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."palavras_chave_categorias" ADD CONSTRAINT "palavras_chave_categorias_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "public"."empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."predicoes" ADD CONSTRAINT "predicoes_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "public"."empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."predicoes" ADD CONSTRAINT "predicoes_categoriaId_fkey" FOREIGN KEY ("categoriaId") REFERENCES "public"."categorias"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."contas_recorrentes" ADD CONSTRAINT "contas_recorrentes_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "public"."empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."contas_recorrentes" ADD CONSTRAINT "contas_recorrentes_categoriaId_fkey" FOREIGN KEY ("categoriaId") REFERENCES "public"."categorias"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."textos_diarios" ADD CONSTRAINT "textos_diarios_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "public"."empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
