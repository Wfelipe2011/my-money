import { BadRequestException, Controller, Get, NotFoundException, Post, UploadedFile, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { HttpService } from '@nestjs/axios';
import { readFileSync, writeFileSync } from 'fs'


@Controller()
export class AppController {
  constructor(private readonly httpService: HttpService) { }

  @Post('fatura/upload')
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
  async uploadPdf(@UploadedFile() file: Express.Multer.File) {
    const data = await this.httpService.axiosRef.post<{ output: string }>('https://auto.wfelipe.com.br/webhook/fatura', file.buffer, {
      headers: {
        'Content-Type': 'application/pdf',
        'api-key': 'fatura-1',
      },
    })
    writeFileSync('output.json', JSON.stringify(data.data, null, 2))
    return data.data;
  }
}

