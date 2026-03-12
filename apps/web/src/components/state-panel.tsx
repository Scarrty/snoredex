// SPDX-License-Identifier: CC-BY-NC-4.0
import type { ReactNode } from 'react';

type StatePanelProps = {
  title: string;
  children: ReactNode;
};

export function StatePanel({ title, children }: StatePanelProps) {
  return (
    <section style={{ border: '1px solid #dbeafe', borderRadius: 8, padding: 16, marginBottom: 16 }}>
      <h2 style={{ marginTop: 0 }}>{title}</h2>
      {children}
    </section>
  );
}
