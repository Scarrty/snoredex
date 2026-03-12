// SPDX-License-Identifier: CC-BY-NC-4.0
import Link from 'next/link';
import { StatePanel } from '../../components/state-panel';
import { listCardPrints } from '../../lib/api';

type CatalogPageProps = {
  searchParams?: Promise<{
    setCode?: string;
    language?: string;
    cardNumber?: string;
  }>;
};

export default async function CatalogPage({ searchParams }: CatalogPageProps) {
  const resolvedSearchParams = (await searchParams) ?? {};
  const result = await listCardPrints(resolvedSearchParams);

  return (
    <main>
      <h1>Catalog</h1>
      <p>Browse card prints from the API with lightweight filters.</p>
      <form style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 16 }}>
        <input name="setCode" placeholder="Set code" defaultValue={resolvedSearchParams.setCode} />
        <input name="language" placeholder="Language" defaultValue={resolvedSearchParams.language} />
        <input name="cardNumber" placeholder="Card number" defaultValue={resolvedSearchParams.cardNumber} />
        <button type="submit">Apply filters</button>
      </form>

      {!result.ok ? (
        <StatePanel title="Unable to load catalog">{result.error}</StatePanel>
      ) : result.data.data.length === 0 ? (
        <StatePanel title="No matching card prints">
          Try adjusting filters or seed additional catalog records.
        </StatePanel>
      ) : (
        <StatePanel title={`Showing ${result.data.data.length} card prints`}>
          <ul>
            {result.data.data.map((cardPrint) => (
              <li key={cardPrint.id}>
                <Link href={`/catalog/${cardPrint.id}`}>
                  {cardPrint.pokemon.name} • {cardPrint.set.name} • #{cardPrint.cardNumber}
                </Link>
              </li>
            ))}
          </ul>
        </StatePanel>
      )}
    </main>
  );
}
