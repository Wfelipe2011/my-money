/*
  Warnings:

  - You are about to drop the column `hashTransacao` on the `lancamentos_cartao` table. All the data in the column will be lost.
  - You are about to drop the column `isPago` on the `lancamentos_cartao` table. All the data in the column will be lost.
  - You are about to drop the column `hashTransacao` on the `lancamentos_conta` table. All the data in the column will be lost.
  - You are about to drop the column `isConciliado` on the `lancamentos_conta` table. All the data in the column will be lost.
  - You are about to drop the column `mesAno` on the `predicoes` table. All the data in the column will be lost.
  - Added the required column `diaSemana` to the `lancamentos_cartao` table without a default value. This is not possible if the table is not empty.
  - Made the column `categoriaId` on table `lancamentos_cartao` required. This step will fail if there are existing NULL values in that column.
  - Added the required column `diaSemana` to the `lancamentos_conta` table without a default value. This is not possible if the table is not empty.
  - Made the column `categoriaId` on table `lancamentos_conta` required. This step will fail if there are existing NULL values in that column.
  - Added the required column `data` to the `predicoes` table without a default value. This is not possible if the table is not empty.
  - Added the required column `origem` to the `predicoes` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "public"."Origem" AS ENUM ('MANUAL', 'AUTOMATICA');

-- DropForeignKey
ALTER TABLE "public"."lancamentos_cartao" DROP CONSTRAINT "lancamentos_cartao_categoriaId_fkey";

-- DropForeignKey
ALTER TABLE "public"."lancamentos_conta" DROP CONSTRAINT "lancamentos_conta_categoriaId_fkey";

-- DropIndex
DROP INDEX "public"."lancamentos_cartao_hashTransacao_key";

-- DropIndex
DROP INDEX "public"."lancamentos_conta_hashTransacao_key";

-- AlterTable
ALTER TABLE "public"."lancamentos_cartao" DROP COLUMN "hashTransacao",
DROP COLUMN "isPago",
ADD COLUMN     "diaSemana" "public"."DiaSemana" NOT NULL,
ALTER COLUMN "categoriaId" SET NOT NULL,
ALTER COLUMN "categoriaId" SET DEFAULT 10;

-- AlterTable
ALTER TABLE "public"."lancamentos_conta" DROP COLUMN "hashTransacao",
DROP COLUMN "isConciliado",
ADD COLUMN     "diaSemana" "public"."DiaSemana" NOT NULL,
ALTER COLUMN "categoriaId" SET NOT NULL,
ALTER COLUMN "categoriaId" SET DEFAULT 15;

-- AlterTable
ALTER TABLE "public"."predicoes" DROP COLUMN "mesAno",
ADD COLUMN     "data" TIMESTAMP(3) NOT NULL,
ADD COLUMN     "origem" "public"."Origem" NOT NULL;

-- AddForeignKey
ALTER TABLE "public"."lancamentos_cartao" ADD CONSTRAINT "lancamentos_cartao_categoriaId_fkey" FOREIGN KEY ("categoriaId") REFERENCES "public"."categorias"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."lancamentos_conta" ADD CONSTRAINT "lancamentos_conta_categoriaId_fkey" FOREIGN KEY ("categoriaId") REFERENCES "public"."categorias"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
