// SPDX-License-Identifier: CC-BY-NC-4.0
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { HealthController } from '../../src/health.controller';

test('health controller returns ok payload', () => {
  const controller = new HealthController();
  assert.deepEqual(controller.getHealth(), { status: 'ok', service: 'snoredex-api' });
});
