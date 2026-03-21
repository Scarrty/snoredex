// SPDX-License-Identifier: CC-BY-NC-4.0
import Link from 'next/link';

import { AppShell } from '../../../components/app-shell';
import { StatePanel } from '../../../components/state-panel';
import { getCardPrint } from '../../../lib/api';
import { sectionContent } from '../../../lib/site-data';

type CatalogDetailPageProps = {
  params: Promise<{
    id: string;
  }>;
};

export default async function CatalogDetailPage({ params }: CatalogDetailPageProps) {
  const content = sectionContent.catalog;
  const resolvedParams = await params;
  const result = await getCardPrint(Number(resolvedParams.id));

  return (
    <AppShell
      actionHref={content.actionHref}
      actionLabel={content.actionLabel}
      currentHref="/catalog"
      description={content.description}
      eyebrow={content.eyebrow}
      metrics={content.metrics}
      title="Catalog Detail"
    >
      <section className="detail-grid">
        {!result.ok ? (
          <StatePanel eyebrow="Catalog detail" title="Unable to load card print">
            <p>{result.error}</p>
            <Link className="secondary-link state-panel__action" href="/catalog">
              Back to catalog
            </Link>
          </StatePanel>
        ) : (
          <StatePanel
            eyebrow="Catalog detail"
            title={`${result.data.pokemon.name} • ${result.data.set.name}`}
          >
            <p>Card number: {result.data.cardNumber}</p>
            <p>Set code: {result.data.set.setCode ?? 'N/A'}</p>
            <p>
              Languages:{' '}
              {result.data.cardPrintLanguages.map((entry) => entry.language.code).join(', ') ||
                'N/A'}
            </p>
            <Link className="secondary-link state-panel__action" href="/catalog">
              Back to catalog
            </Link>
          </StatePanel>
        )}

        <article className="paper-panel feature-panel">
          <p className="eyebrow">{content.featureLabel}</p>
          <h2>{content.featureTitle}</h2>
          <p>{content.featureBody}</p>
        </article>
      </section>
    </AppShell>
  );
}
