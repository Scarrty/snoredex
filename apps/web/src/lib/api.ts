// SPDX-License-Identifier: CC-BY-NC-4.0
const API_BASE_URL = process.env.API_BASE_URL ?? 'http://localhost:3001/api/v1';

type ApiResult<T> =
  | { ok: true; data: T }
  | { ok: false; error: string };

export type SetProfitability = {
  set_id: number;
  set_name: string;
  sold_quantity: number | string;
  gross_revenue: number | string;
  realized_profit: number | string;
};

export type CardPrint = {
  id: number;
  cardNumber: string;
  pokemon: { name: string };
  set: { name: string; setCode: string | null };
  cardPrintLanguages: Array<{ language: { code: string } }>;
};

export type CardPrintListResponse = {
  data: CardPrint[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
  };
};

async function fetchJson<T>(path: string): Promise<ApiResult<T>> {
  try {
    const response = await fetch(`${API_BASE_URL}${path}`, { cache: 'no-store' });

    if (!response.ok) {
      return { ok: false, error: `Request failed (${response.status})` };
    }

    return { ok: true, data: (await response.json()) as T };
  } catch {
    return { ok: false, error: 'Unable to connect to API service.' };
  }
}

export function getSetProfitability() {
  return fetchJson<SetProfitability[]>('/reports/profitability/by-set');
}

export function listCardPrints(filters: {
  setCode?: string;
  language?: string;
  cardNumber?: string;
}) {
  const params = new URLSearchParams();

  for (const [key, value] of Object.entries(filters)) {
    if (value) {
      params.set(key, value);
    }
  }

  const query = params.toString();
  return fetchJson<CardPrintListResponse>(`/catalog/card-prints${query ? `?${query}` : ''}`);
}

export function getCardPrint(id: number) {
  return fetchJson<CardPrint>(`/catalog/card-prints/${id}`);
}
