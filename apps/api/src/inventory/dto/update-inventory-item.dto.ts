// SPDX-License-Identifier: CC-BY-NC-4.0
import {
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

export class UpdateInventoryItemDto {
  @IsOptional()
  @IsInt()
  @Min(1)
  locationId?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  conditionId?: number;

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
