// SPDX-License-Identifier: CC-BY-NC-4.0
import { SetMetadata } from '@nestjs/common';

export const ROLE_METADATA_KEY = 'requiredRole';
export const Roles = (...roles: string[]) => SetMetadata(ROLE_METADATA_KEY, roles);
