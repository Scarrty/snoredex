// SPDX-License-Identifier: CC-BY-NC-4.0
import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { CreateListingDto } from './dto/create-listing.dto';
import { MarketplacesService } from './marketplaces.service';

@Controller('marketplaces')
export class MarketplacesController {
  constructor(private readonly marketplacesService: MarketplacesService) {}

  @Get('listings')
  listListings(
    @Query('page') page?: number,
    @Query('pageSize') pageSize?: number,
    @Query('marketplaceId') marketplaceId?: number,
    @Query('status') status?: 'draft' | 'active' | 'paused' | 'sold' | 'ended' | 'error',
  ) {
    return this.marketplacesService.listListings({
      page,
      pageSize,
      marketplaceId,
      status,
    });
  }

  @Post('listings')
  createListing(@Body() body: CreateListingDto) {
    return this.marketplacesService.createListing(body);
  }
}
