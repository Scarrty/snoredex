// SPDX-License-Identifier: CC-BY-NC-4.0
import Link from 'next/link';

import { AppShell } from '../../components/app-shell';
import { StatePanel } from '../../components/state-panel';
import { listCardPrints } from '../../lib/api';
import { sectionContent } from '../../lib/site-data';

type CatalogPageProps = {
  searchParams?: Promise<{
    setCode?: string;
    language?: string;
    cardNumber?: string;
  }>;
};

export default async function CatalogPage({ searchParams }: CatalogPageProps) {
  const content = sectionContent.catalog;
  const resolvedSearchParams = (await searchParams) ?? {};
  const result = await listCardPrints(resolvedSearchParams);

  return (
    <AppShell
      actionHref={content.actionHref}
      actionLabel={content.actionLabel}
      currentHref="/catalog"
      description={content.description}
      eyebrow={content.eyebrow}
      metrics={content.metrics}
      title={content.title}
    >
      <section className="detail-grid">
        <StatePanel eyebrow="Live catalog" title="Browse card prints">
          <p>Browse card prints from the API with lightweight filters.</p>

          <form className="filter-form">
            <label className="field">
              <span>Set code</span>
              <input
                className="text-input"
                name="setCode"
                placeholder="Base2"
                defaultValue={resolvedSearchParams.setCode}
              />
            </label>
            <label className="field">
              <span>Language</span>
              <input
                className="text-input"
                name="language"
                placeholder="en"
                defaultValue={resolvedSearchParams.language}
              />
            </label>
            <label className="field">
              <span>Card number</span>
              <input
                className="text-input"
                name="cardNumber"
                placeholder="143"
                defaultValue={resolvedSearchParams.cardNumber}
              />
            </label>
            <button className="primary-button filter-form__submit" type="submit">
              Apply filters
            </button>
          </form>

          {!result.ok ? (
            <p>{result.error}</p>
          ) : result.data.data.length === 0 ? (
            <p>Try adjusting filters or seed additional catalog records.</p>
          ) : (
            <>
              <p className="meta-copy">
                Showing {result.data.data.length} of {result.data.pagination.total} tracked card
                prints.
              </p>
              <div className="data-list" role="list">
                {result.data.data.map((cardPrint) => (
                  <article className="data-list__item" key={cardPrint.id} role="listitem">
                    <div>
                      <Link className="text-link" href={`/catalog/${cardPrint.id}`}>
                        {cardPrint.pokemon.name} • {cardPrint.set.name} • #{cardPrint.cardNumber}
                      </Link>
                      <p>
                        Set code: {cardPrint.set.setCode ?? 'N/A'} · Languages:{' '}
                        {cardPrint.cardPrintLanguages
                          .map((entry) => entry.language.code)
                          .join(', ') || 'N/A'}
                      </p>
                    </div>
                  </article>
                ))}
              </div>
            </>
          )}
        </StatePanel>

        <article className="paper-panel feature-panel">
          <p className="eyebrow">{content.featureLabel}</p>
          <h2>{content.featureTitle}</h2>
          <p>{content.featureBody}</p>

          <div className="tag-row" aria-label="Catalog highlights">
            {content.tags.map((tag) => (
              <span className="tag-pill" key={tag}>
                {tag}
              </span>
            ))}
          </div>
        </article>

        <article className="paper-panel table-panel">
          <div className="panel-heading">
            <p className="eyebrow">{content.tableTitle}</p>
            <h2>Reference board</h2>
          </div>

          <div className="table-rows" role="list">
            {content.tableRows.map((row) => (
              <article className="table-row" key={`${row.label}-${row.value}`} role="listitem">
                <div>
                  <strong>{row.label}</strong>
                  <p>{row.note}</p>
                </div>
                <span className="table-row__value">{row.value}</span>
              </article>
            ))}
          </div>
        </article>

        <article className="paper-panel next-panel">
          <p className="eyebrow">{content.noteTitle}</p>
          <p>{content.noteBody}</p>
          <Link className="primary-link" href={content.nextHref}>
            {content.nextLabel}
          </Link>
        </article>
      </section>
    </AppShell>
  );
}
