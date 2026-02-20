// SPDX-License-Identifier: CC-BY-NC-4.0
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateAcquisitionDto } from './dto/create-acquisition.dto';
import { CreateSaleDto } from './dto/create-sale.dto';

@Injectable()
export class TransactionsService {
  constructor(private readonly prisma: PrismaService) {}

  async createAcquisition(dto: CreateAcquisitionDto) {
    return this.prisma.$transaction(async (tx: any) => {
      const acquisition = await tx.acquisition.create({
        data: {
          acquiredAt: new Date(dto.acquiredAt),
          supplierReference: dto.supplierReference,
          channel: dto.channel,
          currency: dto.currency.toUpperCase(),
          notes: dto.notes,
        },
      });

      const lines = await Promise.all(
        dto.lines.map((line) =>
          tx.acquisitionLine.create({
            data: {
              acquisitionId: acquisition.id,
              inventoryItemId: line.inventoryItemId,
              languageId: line.languageId,
              quantity: line.quantity,
              unitCost: line.unitCost,
              fees: line.fees ?? 0,
              shipping: line.shipping ?? 0,
            },
          }),
        ),
      );

      await Promise.all(
        dto.lines.map((line) =>
          tx.inventoryMovement.create({
            data: {
              inventoryItemId: line.inventoryItemId,
              movementType: 'purchase',
              quantityDelta: line.quantity,
              referenceType: 'acquisition',
              referenceId: String(acquisition.id),
            },
          }),
        ),
      );

      return { ...acquisition, lines };
    });
  }

  async createSale(dto: CreateSaleDto) {
    return this.prisma.$transaction(async (tx: any) => {
      const sale = await tx.sale.create({
        data: {
          soldAt: new Date(dto.soldAt),
          buyerReference: dto.buyerReference,
          channel: dto.channel,
          currency: dto.currency.toUpperCase(),
          notes: dto.notes,
        },
      });

      const lines = await Promise.all(
        dto.lines.map((line) =>
          tx.salesLine.create({
            data: {
              saleId: sale.id,
              inventoryItemId: line.inventoryItemId,
              languageId: line.languageId,
              quantity: line.quantity,
              unitSalePrice: line.unitSalePrice,
              fees: line.fees ?? 0,
              shipping: line.shipping ?? 0,
            },
          }),
        ),
      );

      await Promise.all(
        dto.lines.map((line) =>
          tx.inventoryMovement.create({
            data: {
              inventoryItemId: line.inventoryItemId,
              movementType: 'sale',
              quantityDelta: -line.quantity,
              referenceType: 'sale',
              referenceId: String(sale.id),
            },
          }),
        ),
      );

      return { ...sale, lines };
    });
  }
}
