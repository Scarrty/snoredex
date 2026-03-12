// SPDX-License-Identifier: CC-BY-NC-4.0
import Link from 'next/link';

const routes = [
  ['Login', '/login'],
  ['Dashboard', '/dashboard'],
  ['Catalog', '/catalog'],
  ['Inventory', '/inventory'],
  ['Acquisitions', '/acquisitions'],
  ['Sales', '/sales'],
  ['Listings', '/listings'],
];

export default function HomePage() {
  return (
    <main>
      <h1>Snoredex Web App</h1>
      <p>Initial vertical slice is now available for dashboard metrics and catalog browsing.</p>
      <ul>
        {routes.map(([label, href]) => (
          <li key={href}>
            <Link href={href}>{label}</Link>
          </li>
        ))}
      </ul>
    </main>
  );
}
