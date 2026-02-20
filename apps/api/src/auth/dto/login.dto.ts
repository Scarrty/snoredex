// SPDX-License-Identifier: CC-BY-NC-4.0
import { IsString, Length } from 'class-validator';

export class LoginDto {
  @IsString()
  @Length(1, 100)
  username!: string;
}
