// SPDX-License-Identifier: CC-BY-NC-4.0
import Link from 'next/link';

import { AppShell } from '../../components/app-shell';
import { StatePanel } from '../../components/state-panel';
import { getSetProfitability } from '../../lib/api';
import { sectionContent } from '../../lib/site-data';

export default async function DashboardPage() {
  const content = sectionContent.dashboard;
  const profitabilityResult = await getSetProfitability();

  return (
    <AppShell
      actionHref={content.actionHref}
      actionLabel={content.actionLabel}
      currentHref="/dashboard"
      description={content.description}
      eyebrow={content.eyebrow}
      metrics={content.metrics}
      title={content.title}
    >
      <section className="detail-grid">
        <StatePanel eyebrow="Live report" title="Top sets by realized profit">
          <p>Read-only profitability metrics for your current collection.</p>
          <Link className="secondary-link state-panel__action" href="/catalog">
            Browse catalog card prints
          </Link>

          {!profitabilityResult.ok ? (
            <p>{profitabilityResult.error}</p>
          ) : profitabilityResult.data.length === 0 ? (
            <p>Seed data and sales records are required before this report is populated.</p>
          ) : (
            <div className="table-wrap">
              <table className="data-table">
                <thead>
                  <tr>
                    <th align="left">Set</th>
                    <th align="right">Sold Qty</th>
                    <th align="right">Gross Revenue</th>
                    <th align="right">Realized Profit</th>
                  </tr>
                </thead>
                <tbody>
                  {profitabilityResult.data.slice(0, 10).map((row) => (
                    <tr key={row.set_id}>
                      <td>{row.set_name}</td>
                      <td align="right">{row.sold_quantity}</td>
                      <td align="right">{row.gross_revenue}</td>
                      <td align="right">{row.realized_profit}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </StatePanel>

        <article className="paper-panel feature-panel">
          <p className="eyebrow">{content.featureLabel}</p>
          <h2>{content.featureTitle}</h2>
          <p>{content.featureBody}</p>

          <div className="tag-row" aria-label="Dashboard highlights">
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
            <h2>Recent movement tape</h2>
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
