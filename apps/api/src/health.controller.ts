// SPDX-License-Identifier: CC-BY-NC-4.0
import { Controller, Get } from '@nestjs/common';

@Controller('health')
export class HealthController {
  @Get()
  getHealth() {
    return {
      status: 'ok',
      service: 'snoredex-api',
    };
  }
}
