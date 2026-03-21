// SPDX-License-Identifier: CC-BY-NC-4.0
import Link from 'next/link';

import { AppShell } from './app-shell';
import type { SectionContent } from '../lib/site-data';

type SectionPageProps = {
  content: SectionContent;
  currentHref: string;
};

export function SectionPage({ content, currentHref }: SectionPageProps) {
  return (
    <AppShell
      actionHref={content.actionHref}
      actionLabel={content.actionLabel}
      currentHref={currentHref}
      description={content.description}
      eyebrow={content.eyebrow}
      metrics={content.metrics}
      title={content.title}
    >
      <section className="detail-grid">
        <article className="paper-panel feature-panel">
          <p className="eyebrow">{content.featureLabel}</p>
          <h2>{content.featureTitle}</h2>
          <p>{content.featureBody}</p>

          <div className="tag-row" aria-label="Section highlights">
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

        <article className="paper-panel note-panel">
          <p className="eyebrow">{content.noteTitle}</p>
          <p className="note-panel__body">{content.noteBody}</p>
        </article>

        <article className="paper-panel next-panel">
          <p className="eyebrow">Adjacent route</p>
          <h2>Keep the working set connected.</h2>
          <p>
            Each section should hand off naturally to the next operational decision
            instead of dropping the user into isolated dead ends.
          </p>

          <Link className="primary-link" href={content.nextHref}>
            {content.nextLabel}
          </Link>
        </article>
      </section>
    </AppShell>
  );
}
