import "dotenv/config";
import { BadRequestException, Body, Controller, Get, NotFoundException, Param, ParseIntPipe, Post, Query, Res, UploadedFile, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { HttpService } from '@nestjs/axios';
import { AppService } from './app.service';
import type { Response } from 'express';
import fs from 'fs';


@Controller()
export class AppController {
  constructor(private readonly httpService: HttpService, private readonly appService: AppService) { }

  @Post()
  async test(@Body() body: { text: string }) {
    const lancamentos = await this.appService.saveStatements(body.text, 2);
    return lancamentos;
  }

  @Post('fatura/:cardId/upload')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
      fileFilter: (req, file, callback) => {
        if (!file.originalname.match(/\.(pdf)$/)) {
          return callback(new BadRequestException('Only .pdf files are allowed'), false);
        }
        if (!file) throw new NotFoundException('Arquivo PDF não enviado.');
        callback(null, true);
      },
    }),
  )
  async uploadPdf(
    @UploadedFile() file: Express.Multer.File,
    @Param('cardId', ParseIntPipe) cardId: number,
    @Res() res: Response
  ) {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    const totalSteps = 5; // Simulação de progresso
    const send = (progress) => {
      const percentage = Math.round((progress / totalSteps) * 100);
      res.write(`data: ${JSON.stringify({ progress: percentage })}\n\n`);
    }
    send(0);
    const data = await this.httpService.axiosRef.post<{ output: string }>('https://auto.wfelipe.com.br/webhook/fatura', file.buffer, {
      headers: {
        'Content-Type': 'application/pdf',
        'api-key': 'fatura-1',
      },
    })
    fs.writeFileSync(`.output-${Date.now()}.txt`, data.data.output);
    send(2);
    await this.appService.saveStatements(data.data.output, cardId, send);
    res.end();
  }
}

