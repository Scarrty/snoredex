// SPDX-License-Identifier: CC-BY-NC-4.0
import { Controller, Get, Query } from '@nestjs/common';
import { Public } from '../auth/decorators/public.decorator';
import { ReportsService } from './reports.service';

@Public()
@Controller('reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Get('profitability/by-card')
  profitabilityByCard(
    @Query('page') page?: number,
    @Query('pageSize') pageSize?: number,
  ) {
    return this.reportsService.profitabilityByCard(page, pageSize);
  }

  @Get('profitability/by-set')
  profitabilityBySet() {
    return this.reportsService.profitabilityBySet();
  }
}
