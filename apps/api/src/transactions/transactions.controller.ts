// SPDX-License-Identifier: CC-BY-NC-4.0
import { Body, Controller, Post } from '@nestjs/common';
import { CreateAcquisitionDto } from './dto/create-acquisition.dto';
import { CreateSaleDto } from './dto/create-sale.dto';
import { TransactionsService } from './transactions.service';

@Controller('transactions')
export class TransactionsController {
  constructor(private readonly transactionsService: TransactionsService) {}

  @Post('acquisitions')
  createAcquisition(@Body() body: CreateAcquisitionDto) {
    return this.transactionsService.createAcquisition(body);
  }

  @Post('sales')
  createSale(@Body() body: CreateSaleDto) {
    return this.transactionsService.createSale(body);
  }
}
