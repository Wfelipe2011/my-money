import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { HttpModule } from '@nestjs/axios';
import { SchemaProvider } from './schema.provider';
import { PromptProvider } from './prompt.provider';
import { ExtractService } from './domain/extract.service';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [HttpModule, PrismaModule],
  controllers: [AppController],
  providers: [AppService, SchemaProvider, PromptProvider, ExtractService],
})
export class AppModule { }
