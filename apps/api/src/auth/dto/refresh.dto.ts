// SPDX-License-Identifier: CC-BY-NC-4.0
import { IsString, Length } from 'class-validator';

export class RefreshDto {
  @IsString()
  @Length(10, 5000)
  refreshToken!: string;
}
