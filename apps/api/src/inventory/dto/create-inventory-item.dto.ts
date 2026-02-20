// SPDX-License-Identifier: CC-BY-NC-4.0
import {
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

export class CreateInventoryItemDto {
  @IsInt()
  @Min(1)
  cardPrintId!: number;

  @IsInt()
  @Min(1)
  userId!: number;

  @IsInt()
  @Min(1)
  locationId!: number;

  @IsInt()
  @Min(1)
  conditionId!: number;

  @IsOptional()
  @IsString()
  gradeProvider?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(10)
  gradeValue?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(1)
  quantityOnHand?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(1)
  quantityReserved?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(1)
  quantityDamaged?: number;
}
