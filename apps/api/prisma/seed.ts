import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  await prisma.language.createMany({
    data: [
      { code: 'EN', name: 'English' },
      { code: 'JP', name: 'Japanese' },
    ],
    skipDuplicates: true,
  });

  await prisma.cardCondition.createMany({
    data: [
      { code: 'NM', name: 'Near Mint', sortOrder: 1 },
      { code: 'LP', name: 'Lightly Played', sortOrder: 2 },
      { code: 'MP', name: 'Moderately Played', sortOrder: 3 },
    ],
    skipDuplicates: true,
  });
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
