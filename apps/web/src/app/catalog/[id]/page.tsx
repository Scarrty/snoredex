// SPDX-License-Identifier: CC-BY-NC-4.0
import Link from 'next/link';
import { StatePanel } from '../../../components/state-panel';
import { getCardPrint } from '../../../lib/api';

type CatalogDetailPageProps = {
  params: Promise<{
    id: string;
  }>;
};

export default async function CatalogDetailPage({ params }: CatalogDetailPageProps) {
  const resolvedParams = await params;
  const result = await getCardPrint(Number(resolvedParams.id));

  return (
    <main>
      <h1>Card print details</h1>
      <p>
        <Link href="/catalog">← Back to catalog</Link>
      </p>
      {!result.ok ? (
        <StatePanel title="Unable to load card print">{result.error}</StatePanel>
      ) : (
        <StatePanel title={`${result.data.pokemon.name} • ${result.data.set.name}`}>
          <p>Card number: {result.data.cardNumber}</p>
          <p>Set code: {result.data.set.setCode ?? 'N/A'}</p>
          <p>
            Languages:{' '}
            {result.data.cardPrintLanguages.map((entry) => entry.language.code).join(', ') || 'N/A'}
          </p>
        </StatePanel>
      )}
    </main>
  );
}
