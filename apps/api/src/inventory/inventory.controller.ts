// SPDX-License-Identifier: CC-BY-NC-4.0
import {
  Body,
  Controller,
  Param,
  ParseIntPipe,
  Patch,
  Post,
} from '@nestjs/common';
import { CreateInventoryMovementDto } from './dto/create-inventory-movement.dto';
import { CreateInventoryItemDto } from './dto/create-inventory-item.dto';
import { UpdateInventoryItemDto } from './dto/update-inventory-item.dto';
import { InventoryService } from './inventory.service';

@Controller('inventory')
export class InventoryController {
  constructor(private readonly inventoryService: InventoryService) {}

  @Post('items')
  createItem(@Body() body: CreateInventoryItemDto) {
    return this.inventoryService.createItem(body);
  }

  @Patch('items/:id')
  updateItem(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: UpdateInventoryItemDto,
  ) {
    return this.inventoryService.updateItem(id, body);
  }

  @Post('movements')
  createMovement(@Body() body: CreateInventoryMovementDto) {
    return this.inventoryService.createMovement(body);
  }
}
