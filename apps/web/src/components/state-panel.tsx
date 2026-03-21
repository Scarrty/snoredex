// SPDX-License-Identifier: CC-BY-NC-4.0
import type { ReactNode } from 'react';

type StatePanelProps = {
  eyebrow?: string;
  className?: string;
  title: string;
  children: ReactNode;
};

export function StatePanel({ eyebrow, className, title, children }: StatePanelProps) {
  const classes = className ? `paper-panel state-panel ${className}` : 'paper-panel state-panel';

  return (
    <section className={classes}>
      {eyebrow ? <p className="eyebrow">{eyebrow}</p> : null}
      <h2>{title}</h2>
      <div className="state-panel__content">{children}</div>
    </section>
  );
}
