// SPDX-License-Identifier: CC-BY-NC-4.0
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}

  profitabilityByCard(page = 1, pageSize = 25) {
    const safePage = Math.max(1, Number(page));
    const safePageSize = Math.min(100, Math.max(1, Number(pageSize)));
    const offset = (safePage - 1) * safePageSize;

    return this.prisma.$queryRaw`
      SELECT
        card_print_id,
        set_id,
        set_name,
        language_id,
        language_code,
        language_name,
        sold_quantity,
        gross_revenue,
        cogs,
        gross_margin,
        realized_profit
      FROM reporting_profitability_by_card_set_language
      ORDER BY realized_profit DESC
      LIMIT ${safePageSize}
      OFFSET ${offset}
    `;
  }

  profitabilityBySet() {
    return this.prisma.$queryRaw`
      SELECT
        set_id,
        set_name,
        SUM(sold_quantity) AS sold_quantity,
        SUM(gross_revenue) AS gross_revenue,
        SUM(cogs) AS cogs,
        SUM(gross_margin) AS gross_margin,
        SUM(realized_profit) AS realized_profit
      FROM reporting_profitability_by_card_set_language
      GROUP BY set_id, set_name
      ORDER BY realized_profit DESC
    `;
  }
}
