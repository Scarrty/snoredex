// SPDX-License-Identifier: CC-BY-NC-4.0
import {
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';

const listingStatuses = ['draft', 'active', 'paused', 'sold', 'ended', 'error'] as const;

export class CreateListingDto {
  @IsInt()
  @Min(1)
  marketplaceId!: number;

  @IsInt()
  @Min(1)
  inventoryItemId!: number;

  @IsString()
  @MaxLength(255)
  externalListingId!: string;

  @IsOptional()
  @IsEnum(listingStatuses)
  listingStatus?: (typeof listingStatuses)[number];

  @IsOptional()
  @IsNumber()
  @Min(0)
  listedPrice?: number;

  @IsOptional()
  @IsString()
  @MaxLength(3)
  currency?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  quantityListed?: number;

  @IsOptional()
  @IsString()
  url?: string;
}
