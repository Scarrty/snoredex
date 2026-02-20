// SPDX-License-Identifier: CC-BY-NC-4.0
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

type CardPrintQuery = {
  page?: number;
  pageSize?: number;
  setCode?: string;
  language?: string;
  cardNumber?: string;
};

@Injectable()
export class CatalogService {
  constructor(private readonly prisma: PrismaService) {}

  async listCardPrints(query: CardPrintQuery) {
    const page = Math.max(1, Number(query.page ?? 1));
    const pageSize = Math.min(100, Math.max(1, Number(query.pageSize ?? 25)));

    const where = {
      ...(query.setCode
        ? {
            set: {
              setCode: { equals: query.setCode, mode: 'insensitive' as const },
            },
          }
        : {}),
      ...(query.language
        ? {
            cardPrintLanguages: {
              some: {
                language: {
                  code: { equals: query.language, mode: 'insensitive' as const },
                },
              },
            },
          }
        : {}),
      ...(query.cardNumber
        ? {
            cardNumber: {
              contains: query.cardNumber,
              mode: 'insensitive' as const,
            },
          }
        : {}),
    };

    const [data, total] = await this.prisma.$transaction([
      this.prisma.cardPrint.findMany({
        where,
        skip: (page - 1) * pageSize,
        take: pageSize,
        orderBy: { id: 'asc' },
        include: {
          pokemon: true,
          set: true,
          type: true,
          cardPrintLanguages: {
            include: {
              language: true,
            },
          },
        },
      }),
      this.prisma.cardPrint.count({ where }),
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

  getCardPrint(id: number) {
    return this.prisma.cardPrint.findUniqueOrThrow({
      where: { id },
      include: {
        pokemon: true,
        set: true,
        type: true,
        cardPrintLanguages: {
          include: {
            language: true,
          },
        },
      },
    });
  }
}
