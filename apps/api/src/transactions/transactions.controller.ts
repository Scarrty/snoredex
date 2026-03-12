// SPDX-License-Identifier: CC-BY-NC-4.0
import { Body, Controller, Post } from '@nestjs/common';
import { Roles } from '../auth/decorators/roles.decorator';
import { CreateAcquisitionDto } from './dto/create-acquisition.dto';
import { CreateSaleDto } from './dto/create-sale.dto';
import { TransactionsService } from './transactions.service';

@Controller('transactions')
export class TransactionsController {
  constructor(private readonly transactionsService: TransactionsService) {}

  @Roles('admin', 'operator')
  @Post('acquisitions')
  createAcquisition(@Body() body: CreateAcquisitionDto) {
    return this.transactionsService.createAcquisition(body);
  }

  @Roles('admin', 'operator')
  @Post('sales')
  createSale(@Body() body: CreateSaleDto) {
    return this.transactionsService.createSale(body);
  }
}
