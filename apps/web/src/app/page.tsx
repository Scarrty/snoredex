// SPDX-License-Identifier: CC-BY-NC-4.0
import Link from 'next/link';

import { appRoutes, homePanels, overviewMetrics } from '../lib/site-data';

export default function HomePage() {
  return (
    <main className="landing-page">
      <section className="paper-panel hero-panel">
        <div className="hero-copy">
          <p className="eyebrow">Collector-grade operating system</p>
          <h1>Track every Snorlax print like it belongs in an archive, not a bland dashboard.</h1>
          <p className="lead">
            Snoredex ties catalog structure, unit inventory, acquisitions, sales,
            and marketplace listings into one calm ledger shaped for a serious
            single-Pokemon collection.
          </p>

          <div className="hero-actions">
            <Link className="primary-link" href="/dashboard">
              Open dashboard
            </Link>
            <Link className="secondary-link" href="/login">
              View login flow
            </Link>
          </div>
        </div>

        <article className="paper-panel specimen-card">
          <p className="eyebrow">Archive focus</p>
          <h2>Snorlax No. 143</h2>
          <p className="specimen-card__body">
            Inventory discipline matters more when the subject is narrow, deep,
            and full of subtle print differences.
          </p>

          <div className="specimen-facts">
            <div>
              <span>Core stack</span>
              <strong>Wizards-era holo and promo pressure</strong>
            </div>
            <div>
              <span>Operator need</span>
              <strong>Know what is owned, listable, and underpriced</strong>
            </div>
            <div>
              <span>System promise</span>
              <strong>One factual ledger from print metadata to realized sale</strong>
            </div>
          </div>
        </article>
      </section>

      <section className="metric-strip" aria-label="Collection overview">
        {overviewMetrics.map((metric) => (
          <article className="paper-panel metric-card" key={`${metric.label}-${metric.value}`}>
            <span className="metric-card__value">{metric.value}</span>
            <strong>{metric.label}</strong>
            <p>{metric.note}</p>
          </article>
        ))}
      </section>

      <section className="route-grid" aria-label="Primary routes">
        <Link className="route-card route-card--login" href="/login">
          <span className="route-card__index">00</span>
          <strong>Login</strong>
          <p>Authentication scaffold with the same archival visual language as the app shell.</p>
        </Link>

        {appRoutes.map((route) => (
          <Link className="route-card" href={route.href} key={route.href}>
            <span className="route-card__index">{route.index}</span>
            <strong>{route.label}</strong>
            <p>{route.note}</p>
          </Link>
        ))}
      </section>

      <section className="panel-grid" aria-label="Design intent">
        {homePanels.map((panel) => (
          <article className="paper-panel insight-panel" key={panel.title}>
            <p className="eyebrow">{panel.eyebrow}</p>
            <h2>{panel.title}</h2>
            <p>{panel.body}</p>
          </article>
        ))}
      </section>
    </main>
  );
}
