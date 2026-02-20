// SPDX-License-Identifier: CC-BY-NC-4.0
import {
  ArrayMinSize,
  IsArray,
  IsDateString,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

class SaleLineInputDto {
  @IsInt()
  @Min(1)
  inventoryItemId!: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  languageId?: number;

  @IsInt()
  @Min(1)
  quantity!: number;

  @IsNumber()
  @Min(0)
  unitSalePrice!: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  fees?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  shipping?: number;
}

export class CreateSaleDto {
  @IsDateString()
  soldAt!: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  buyerReference?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  channel?: string;

  @IsString()
  @MaxLength(3)
  currency!: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => SaleLineInputDto)
  lines!: SaleLineInputDto[];
}
