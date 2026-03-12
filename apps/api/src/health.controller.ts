// SPDX-License-Identifier: CC-BY-NC-4.0
import { Controller, Get } from '@nestjs/common';
import { Public } from './auth/decorators/public.decorator';

@Public()
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
