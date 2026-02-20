// SPDX-License-Identifier: CC-BY-NC-4.0
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateInventoryItemDto } from './dto/create-inventory-item.dto';
import { UpdateInventoryItemDto } from './dto/update-inventory-item.dto';
import { CreateInventoryMovementDto } from './dto/create-inventory-movement.dto';

@Injectable()
export class InventoryService {
  constructor(private readonly prisma: PrismaService) {}

  createItem(dto: CreateInventoryItemDto) {
    return this.prisma.inventoryItem.create({
      data: {
        cardPrintId: dto.cardPrintId,
        userId: dto.userId,
        locationId: dto.locationId,
        conditionId: dto.conditionId,
        gradeProvider: dto.gradeProvider,
        gradeValue: dto.gradeValue,
        quantityOnHand: dto.quantityOnHand,
        quantityReserved: dto.quantityReserved,
        quantityDamaged: dto.quantityDamaged,
      },
    });
  }

  updateItem(id: number, dto: UpdateInventoryItemDto) {
    return this.prisma.inventoryItem.update({
      where: { id },
      data: {
        locationId: dto.locationId,
        conditionId: dto.conditionId,
        gradeProvider: dto.gradeProvider,
        gradeValue: dto.gradeValue,
        quantityOnHand: dto.quantityOnHand,
        quantityReserved: dto.quantityReserved,
        quantityDamaged: dto.quantityDamaged,
      },
    });
  }

  createMovement(dto: CreateInventoryMovementDto) {
    return this.prisma.inventoryMovement.create({
      data: {
        inventoryItemId: dto.inventoryItemId,
        movementType: dto.movementType as never,
        quantityDelta: dto.quantityDelta,
        occurredAt: dto.occurredAt ? new Date(dto.occurredAt) : undefined,
        referenceType: dto.referenceType,
        referenceId: dto.referenceId,
        notes: dto.notes,
        createdBy: dto.createdBy,
      },
    });
  }
}
