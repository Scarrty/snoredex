// SPDX-License-Identifier: CC-BY-NC-4.0
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

test('web route files include dashboard and catalog vertical-slice text', () => {
  const homeRoute = readFileSync('src/app/page.tsx', 'utf8');
  const dashboardRoute = readFileSync('src/app/dashboard/page.tsx', 'utf8');
  const catalogRoute = readFileSync('src/app/catalog/page.tsx', 'utf8');

  assert.match(homeRoute, /Snoredex Web App/);
  assert.match(dashboardRoute, /Top sets by realized profit/);
  assert.match(catalogRoute, /Browse card prints/);
});
