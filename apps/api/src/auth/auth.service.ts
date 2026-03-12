// SPDX-License-Identifier: CC-BY-NC-4.0
import {
  Injectable,
  UnauthorizedException,
  InternalServerErrorException,
} from '@nestjs/common';
import { createHmac, timingSafeEqual } from 'node:crypto';
import { PrismaService } from '../prisma/prisma.service';

type TokenType = 'access' | 'refresh';

type TokenPayload = {
  sub: number;
  username: string;
  role: string;
  type: TokenType;
  exp: number;
};

@Injectable()
export class AuthService {
  constructor(private readonly prisma: PrismaService) {}

  async login(username: string, password: string) {
    const user = await this.prisma.user.findUnique({
      where: { username },
      select: { id: true, username: true },
    });

    if (!user || !this.verifyCredential(password)) {
      throw new UnauthorizedException('Invalid credentials.');
    }

    return this.issueTokens(user.id, user.username);
  }

  async refresh(refreshToken: string) {
    const payload = this.verifyToken(refreshToken, 'refresh');

    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      select: { id: true, username: true },
    });

    if (!user || user.username !== payload.username) {
      throw new UnauthorizedException('Invalid refresh token.');
    }

    return this.issueTokens(user.id, user.username);
  }

  logout() {
    return { success: true };
  }

  verifyAccessToken(accessToken: string) {
    return this.verifyToken(accessToken, 'access');
  }

  private verifyCredential(password: string) {
    const expectedPassword = process.env.AUTH_PASSWORD ?? 'snoredex-dev-password';
    return this.safeEqual(password, expectedPassword);
  }

  private issueTokens(userId: number, username: string) {
    const role = process.env.DEFAULT_AUTH_ROLE ?? 'admin';
    const accessToken = this.signToken({
      sub: userId,
      username,
      role,
      type: 'access',
      exp: this.expiryFromNow(60 * 15),
    });

    const refreshToken = this.signToken({
      sub: userId,
      username,
      role,
      type: 'refresh',
      exp: this.expiryFromNow(60 * 60 * 24 * 7),
    });

    return {
      accessToken,
      refreshToken,
      tokenType: 'Bearer',
      expiresIn: 60 * 15,
    };
  }

  private expiryFromNow(seconds: number) {
    return Math.floor(Date.now() / 1000) + seconds;
  }

  private signToken(payload: TokenPayload) {
    const payloadEncoded = Buffer.from(JSON.stringify(payload)).toString('base64url');
    const signature = createHmac('sha256', this.jwtSecret())
      .update(payloadEncoded)
      .digest('base64url');

    return `${payloadEncoded}.${signature}`;
  }

  private verifyToken(token: string, expectedType: TokenType): TokenPayload {
    const [payloadEncoded, signature] = token.split('.');

    if (!payloadEncoded || !signature) {
      throw new UnauthorizedException('Invalid token format.');
    }

    const expectedSignature = createHmac('sha256', this.jwtSecret())
      .update(payloadEncoded)
      .digest('base64url');

    const validSignature = this.safeEqual(signature, expectedSignature);

    if (!validSignature) {
      throw new UnauthorizedException('Invalid token signature.');
    }

    const payload = JSON.parse(
      Buffer.from(payloadEncoded, 'base64url').toString('utf8'),
    ) as TokenPayload;

    if (payload.type !== expectedType) {
      throw new UnauthorizedException('Invalid token type.');
    }

    if (payload.exp <= Math.floor(Date.now() / 1000)) {
      throw new UnauthorizedException('Token expired.');
    }

    return payload;
  }

  private safeEqual(a: string, b: string) {
    return a.length === b.length && timingSafeEqual(Buffer.from(a), Buffer.from(b));
  }

  private jwtSecret() {
    const secret = process.env.JWT_SECRET;

    if (!secret) {
      throw new InternalServerErrorException('JWT_SECRET is required.');
    }

    return secret;
  }
}
