// SPDX-License-Identifier: CC-BY-NC-4.0
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateListingDto } from './dto/create-listing.dto';

type ListingStatus = 'draft' | 'active' | 'paused' | 'sold' | 'ended' | 'error';

type ListingQuery = {
  page?: number;
  pageSize?: number;
  marketplaceId?: number;
  status?: ListingStatus;
};

@Injectable()
export class MarketplacesService {
  constructor(private readonly prisma: PrismaService) {}

  async listListings(query: ListingQuery) {
    const page = Math.max(1, Number(query.page ?? 1));
    const pageSize = Math.min(100, Math.max(1, Number(query.pageSize ?? 25)));

    const where = {
      ...(query.marketplaceId ? { marketplaceId: Number(query.marketplaceId) } : {}),
      ...(query.status ? { listingStatus: query.status } : {}),
    };

    const [data, total] = await this.prisma.$transaction([
      this.prisma.externalListing.findMany({
        where,
        skip: (page - 1) * pageSize,
        take: pageSize,
        orderBy: { id: 'desc' },
        include: {
          marketplace: true,
          inventoryItem: true,
        },
      }),
      this.prisma.externalListing.count({ where }),
    ]);

    return {
      data,
      pagination: {
        page,
        pageSize,
        total,
      },
    };
  }

  createListing(dto: CreateListingDto) {
    return this.prisma.externalListing.create({
      data: {
        marketplaceId: dto.marketplaceId,
        inventoryItemId: dto.inventoryItemId,
        externalListingId: dto.externalListingId,
        listingStatus: (dto.listingStatus ?? 'active') as never,
        listedPrice: dto.listedPrice,
        currency: dto.currency?.toUpperCase(),
        quantityListed: dto.quantityListed,
        url: dto.url,
      },
    });
  }
}
