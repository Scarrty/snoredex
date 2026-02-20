// SPDX-License-Identifier: CC-BY-NC-4.0
import {
  IsDateString,
  IsEnum,
  IsInt,
  IsNotIn,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';

const movementTypes = [
  'purchase',
  'sale',
  'transfer_in',
  'transfer_out',
  'adjustment',
] as const;

export class CreateInventoryMovementDto {
  @IsInt()
  @Min(1)
  inventoryItemId!: number;

  @IsEnum(movementTypes)
  movementType!: (typeof movementTypes)[number];

  @IsInt()
  @IsNotIn([0])
  quantityDelta!: number;

  @IsOptional()
  @IsDateString()
  occurredAt?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  referenceType?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  referenceId?: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  createdBy?: string;
}
