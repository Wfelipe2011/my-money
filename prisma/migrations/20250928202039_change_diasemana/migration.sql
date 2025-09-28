/*
  Warnings:

  - Changed the type of `diaSemana` on the `lancamentos_cartao` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `diaSemana` on the `lancamentos_conta` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.

*/
-- CreateEnum
CREATE TYPE "public"."DiaSemana" AS ENUM ('DOMINGO', 'SEGUNDA', 'TERCA', 'QUARTA', 'QUINTA', 'SEXTA', 'SABADO');

-- AlterTable
ALTER TABLE "public"."lancamentos_cartao" DROP COLUMN "diaSemana",
ADD COLUMN     "diaSemana" "public"."DiaSemana" NOT NULL;

-- AlterTable
ALTER TABLE "public"."lancamentos_conta" DROP COLUMN "diaSemana",
ADD COLUMN     "diaSemana" "public"."DiaSemana" NOT NULL;

-- DropEnum
DROP TYPE "public"."DiaSemanaNew";
