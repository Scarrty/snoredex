// SPDX-License-Identifier: CC-BY-NC-4.0
import Link from 'next/link';
import type { ReactNode } from 'react';

import { appRoutes, type Metric } from '../lib/site-data';

type AppShellProps = {
  actionHref: string;
  actionLabel: string;
  children: ReactNode;
  currentHref: string;
  description: string;
  eyebrow: string;
  metrics: Metric[];
  title: string;
};

export function AppShell({
  actionHref,
  actionLabel,
  children,
  currentHref,
  description,
  eyebrow,
  metrics,
  title,
}: AppShellProps) {
  return (
    <main className="page-shell">
      <aside className="paper-panel nav-rail">
        <Link className="brand-mark" href="/">
          <span className="brand-mark__eyebrow">Snorlax ledger</span>
          <strong>Snoredex</strong>
        </Link>

        <p className="nav-copy">
          A collector-grade operating surface for card taxonomy, inventory truth,
          and listing discipline.
        </p>

        <nav className="nav-stack" aria-label="Primary">
          {appRoutes.map((route) => {
            const active = route.href === currentHref;

            return (
              <Link
                key={route.href}
                className={active ? 'nav-link nav-link--active' : 'nav-link'}
                href={route.href}
              >
                <span className="nav-link__index">{route.index}</span>
                <span>
                  <strong>{route.label}</strong>
                  <small>{route.note}</small>
                </span>
              </Link>
            );
          })}
        </nav>

        <div className="rail-footer">
          <p className="eyebrow">Current mode</p>
          <p>Schema-backed MVP scaffolding with a deliberate visual system.</p>
        </div>
      </aside>

      <div className="page-content">
        <section className="paper-panel page-hero">
          <div className="page-hero__copy">
            <p className="eyebrow">{eyebrow}</p>
            <h1>{title}</h1>
            <p className="lead">{description}</p>
          </div>

          <div className="page-hero__aside">
            <div className="metric-grid">
              {metrics.map((metric) => (
                <article className="metric-card" key={`${metric.label}-${metric.value}`}>
                  <span className="metric-card__value">{metric.value}</span>
                  <strong>{metric.label}</strong>
                  <p>{metric.note}</p>
                </article>
              ))}
            </div>

            <Link className="secondary-link page-hero__action" href={actionHref}>
              {actionLabel}
            </Link>
          </div>
        </section>

        {children}
      </div>
    </main>
  );
}
