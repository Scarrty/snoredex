// SPDX-License-Identifier: CC-BY-NC-4.0
import Link from 'next/link';
import { StatePanel } from '../../components/state-panel';
import { getSetProfitability } from '../../lib/api';

export default async function DashboardPage() {
  const profitabilityResult = await getSetProfitability();

  return (
    <main>
      <h1>Dashboard</h1>
      <p>Read-only profitability metrics for your current collection.</p>
      <p>
        <Link href="/catalog">Browse catalog card prints</Link>
      </p>

      {!profitabilityResult.ok ? (
        <StatePanel title="Unable to load dashboard data">
          <p>{profitabilityResult.error}</p>
        </StatePanel>
      ) : profitabilityResult.data.length === 0 ? (
        <StatePanel title="No profitability rows found">
          <p>Seed data and sales records are required before this report is populated.</p>
        </StatePanel>
      ) : (
        <StatePanel title="Top sets by realized profit">
          <table>
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
        </StatePanel>
      )}
    </main>
  );
}
