// SPDX-License-Identifier: CC-BY-NC-4.0
import Link from 'next/link';

import { loginHighlights } from '../../../lib/site-data';

export default function LoginPage() {
  return (
    <main className="auth-page">
      <section className="paper-panel auth-hero">
        <div>
          <p className="eyebrow">Authentication scaffold</p>
          <h1>Enter the ledger.</h1>
          <p className="lead">
            This is still a placeholder route, but it now behaves like the rest of
            the product instead of a bare heading with no point of view.
          </p>

          <div className="auth-highlights" role="list">
            {loginHighlights.map((item) => (
              <p className="auth-highlight" key={item} role="listitem">
                {item}
              </p>
            ))}
          </div>

          <div className="hero-actions">
            <Link className="secondary-link" href="/">
              Back to landing page
            </Link>
            <Link className="primary-link" href="/dashboard">
              Skip to dashboard
            </Link>
          </div>
        </div>

        <form action="/dashboard" className="paper-panel auth-card">
          <p className="eyebrow">Collector access</p>
          <label className="field">
            <span>Email</span>
            <input name="email" placeholder="collector@snoredex.local" type="email" />
          </label>
          <label className="field">
            <span>Password</span>
            <input name="password" placeholder="Enter your password" type="password" />
          </label>
          <label className="field field--inline">
            <input defaultChecked name="remember" type="checkbox" />
            <span>Keep this session ready for quick market checks.</span>
          </label>
          <button className="primary-button" type="submit">
            Continue to dashboard
          </button>
        </form>
      </section>
    </main>
  );
}
