// SPDX-License-Identifier: CC-BY-NC-4.0
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { CatalogModule } from './catalog/catalog.module';
import { PrismaModule } from './prisma/prisma.module';
import { HealthController } from './health.controller';
import { InventoryModule } from './inventory/inventory.module';
import { TransactionsModule } from './transactions/transactions.module';
import { MarketplacesModule } from './marketplaces/marketplaces.module';
import { ReportsModule } from './reports/reports.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    PrismaModule,
    AuthModule,
    CatalogModule,
    InventoryModule,
    TransactionsModule,
    MarketplacesModule,
    ReportsModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
