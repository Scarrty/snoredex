// SPDX-License-Identifier: CC-BY-NC-4.0
import { Controller, Get, Param, ParseIntPipe, Query } from '@nestjs/common';
import { CatalogService } from './catalog.service';

@Controller('catalog')
export class CatalogController {
  constructor(private readonly catalogService: CatalogService) {}

  @Get('card-prints')
  listCardPrints(
    @Query('page') page?: number,
    @Query('pageSize') pageSize?: number,
    @Query('setCode') setCode?: string,
    @Query('language') language?: string,
    @Query('cardNumber') cardNumber?: string,
  ) {
    return this.catalogService.listCardPrints({
      page,
      pageSize,
      setCode,
      language,
      cardNumber,
    });
  }

  @Get('card-prints/:id')
  getCardPrint(@Param('id', ParseIntPipe) id: number) {
    return this.catalogService.getCardPrint(id);
  }
}
