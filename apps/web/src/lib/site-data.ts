// SPDX-License-Identifier: CC-BY-NC-4.0

export type RouteDefinition = {
  href: string;
  label: string;
  index: string;
  note: string;
};

export type Metric = {
  value: string;
  label: string;
  note: string;
};

export type TableRow = {
  label: string;
  value: string;
  note: string;
};

export type SectionContent = {
  eyebrow: string;
  title: string;
  description: string;
  actionLabel: string;
  actionHref: string;
  metrics: Metric[];
  featureLabel: string;
  featureTitle: string;
  featureBody: string;
  tags: string[];
  tableTitle: string;
  tableRows: TableRow[];
  noteTitle: string;
  noteBody: string;
  nextLabel: string;
  nextHref: string;
};

export const appRoutes: RouteDefinition[] = [
  {
    href: '/dashboard',
    label: 'Dashboard',
    index: '01',
    note: 'Daily signal, movement snapshots, and value posture.',
  },
  {
    href: '/catalog',
    label: 'Catalog',
    index: '02',
    note: 'Print taxonomy across sets, variants, and language lanes.',
  },
  {
    href: '/inventory',
    label: 'Inventory',
    index: '03',
    note: 'Unit-level holdings with condition, location, and ownership.',
  },
  {
    href: '/acquisitions',
    label: 'Acquisitions',
    index: '04',
    note: 'Purchase batches, intake friction, and cost-basis discipline.',
  },
  {
    href: '/sales',
    label: 'Sales',
    index: '05',
    note: 'Completed exits, realized margin, and channel cadence.',
  },
  {
    href: '/listings',
    label: 'Listings',
    index: '06',
    note: 'Live marketplace posture, spread, and repricing pressure.',
  },
];

export const overviewMetrics: Metric[] = [
  {
    value: '232',
    label: 'prints mapped',
    note: 'English, Japanese, and promo variants organized in one catalog.',
  },
  {
    value: '84',
    label: 'units on hand',
    note: 'Every copy treated as an individual inventory object, not a loose count.',
  },
  {
    value: '19',
    label: 'active listings',
    note: 'Cross-market tracking stays tied to the underlying inventory item.',
  },
  {
    value: '8.7%',
    label: 'realized margin',
    note: 'Profitability is shaped by acquisition cost, not a hopeful asking price.',
  },
];

export const homePanels = [
  {
    eyebrow: 'Archival catalog',
    title: 'A single-Pokemon collection deserves better than spreadsheet drift.',
    body:
      'Snoredex is built for obsessive print tracking: set, number, language, condition, provenance, and listing state all stay connected.',
  },
  {
    eyebrow: 'Unit precision',
    title: 'Inventory stays factual because movements are append-only.',
    body:
      'The schema already protects the ledger. The frontend should make that discipline obvious instead of hiding it behind generic CRUD chrome.',
  },
  {
    eyebrow: 'Market discipline',
    title: 'Every listing should read against cost basis and location reality.',
    body:
      'Acquisition, sale, and marketplace views belong in the same operational surface so collection strategy is visible at a glance.',
  },
];

export const sectionContent = {
  dashboard: {
    eyebrow: 'Daily command surface',
    title: 'Dashboard',
    description:
      'Start the day with inventory signal, movement pressure, and margin posture instead of jumping between disconnected views.',
    actionLabel: 'Inspect catalog structure',
    actionHref: '/catalog',
    metrics: [
      {
        value: '84',
        label: 'units on hand',
        note: 'Current tracked inventory across active storage zones.',
      },
      {
        value: '11',
        label: 'movements this week',
        note: 'Append-only ledger activity across intake, reserve, and sale events.',
      },
      {
        value: 'EUR 3,480',
        label: 'tracked basis',
        note: 'Weighted acquisition cost behind the present stack.',
      },
    ],
    featureLabel: 'Collection signal',
    featureTitle: 'Base Set 2 holo inventory is tightening before the next repricing cycle.',
    featureBody:
      'The dashboard should foreground the small set of facts that change decisions: low-stock high-interest cards, stale listings, and recent movement bursts.',
    tags: ['3 holo copies in reserve', '2 JP promos pending intake', '1 damaged unit still listed'],
    tableTitle: 'Recent movement tape',
    tableRows: [
      {
        label: 'JP promo intake',
        value: '+1 unit',
        note: 'Arrived in Berlin archive drawer after mail-day verification.',
      },
      {
        label: 'Fossil unlimited sale',
        value: '-1 unit',
        note: 'Completed through direct buyer channel at 12.4% margin.',
      },
      {
        label: 'Cardmarket repricing',
        value: '3 listings',
        note: 'Ask reset to maintain spread over cost basis and shipping.',
      },
    ],
    noteTitle: 'Why this matters',
    noteBody:
      'This route should become the calm operational overview: decisive numbers up top, then only the cards and events that need attention.',
    nextLabel: 'Move to inventory operations',
    nextHref: '/inventory',
  },
  catalog: {
    eyebrow: 'Print taxonomy',
    title: 'Catalog',
    description:
      'Treat the catalog as the master reference for every Snorlax print, language availability, and variant edge case in the collection.',
    actionLabel: 'Review inventory positions',
    actionHref: '/inventory',
    metrics: [
      {
        value: '232',
        label: 'prints indexed',
        note: 'Canonical record spanning sets, promos, and type variations.',
      },
      {
        value: '18',
        label: 'set families',
        note: 'A cross-era map from Wizards-era releases to modern promos.',
      },
      {
        value: '11',
        label: 'language lanes',
        note: 'Availability tracked separately from owned inventory.',
      },
    ],
    featureLabel: 'Catalog pulse',
    featureTitle: 'Metadata quality is what makes rare promo drift visible instead of anecdotal.',
    featureBody:
      'A strong catalog UI needs the feel of an auction reference book: browseable, sharp, and dense with the exact fields collectors actually compare.',
    tags: ['set codes normalized', 'type variants separated', 'language availability linked'],
    tableTitle: 'Reference cards',
    tableRows: [
      {
        label: 'Base Set 2 holo',
        value: 'EN / Unlimited',
        note: 'Anchor print for early collection benchmarking and pricing.',
      },
      {
        label: 'Team Rocket non-holo',
        value: 'EN / 1st Edition',
        note: 'Common comparison point when condition spread distorts value.',
      },
      {
        label: 'Fan Club promo',
        value: 'JP / Promo',
        note: 'High-attention print where provenance notes matter more than raw count.',
      },
    ],
    noteTitle: 'Why this matters',
    noteBody:
      'Catalog data is upstream of everything else. If the print model is vague, profitability, listings, and stock history all become suspect.',
    nextLabel: 'Check acquisition pipeline',
    nextHref: '/acquisitions',
  },
  inventory: {
    eyebrow: 'Unit inventory',
    title: 'Inventory',
    description:
      'Inventory should show exactly where each unit lives, what condition it sits in, and whether it is free, reserved, or compromised.',
    actionLabel: 'Open acquisition intake',
    actionHref: '/acquisitions',
    metrics: [
      {
        value: '84',
        label: 'units tracked',
        note: 'Every copy represented as a specific inventory item.',
      },
      {
        value: '7',
        label: 'reserved',
        note: 'Units already spoken for or staged for outbound work.',
      },
      {
        value: '2',
        label: 'damaged',
        note: 'Held separately so listings and valuation stay honest.',
      },
    ],
    featureLabel: 'Location balance',
    featureTitle: 'Storage and condition are part of the product truth, not secondary metadata.',
    featureBody:
      'Collectors do not just need counts. They need a crisp sense of where the best copies live, what is listable now, and which units need intervention.',
    tags: ['Berlin cabinet', 'mail-day staging', 'vault sleeve rotation'],
    tableTitle: 'Storage zones',
    tableRows: [
      {
        label: 'Berlin archive drawer',
        value: '29 units',
        note: 'Primary long-term holding zone for stable condition copies.',
      },
      {
        label: 'Photo desk binder',
        value: '8 units',
        note: 'Short-term staging area for scans, listings, and condition review.',
      },
      {
        label: 'Transit intake tray',
        value: '3 units',
        note: 'Pending arrival confirmation before they enter normal rotation.',
      },
    ],
    noteTitle: 'Why this matters',
    noteBody:
      'The strongest inventory view will feel tactile: condition, location, and reservation state should read immediately without opening a detail modal.',
    nextLabel: 'See live sales performance',
    nextHref: '/sales',
  },
  acquisitions: {
    eyebrow: 'Procurement flow',
    title: 'Acquisitions',
    description:
      'Capture new buys with enough structure to protect cost basis, seller history, and intake timing before a card ever reaches inventory.',
    actionLabel: 'Move to sales ledger',
    actionHref: '/sales',
    metrics: [
      {
        value: '47',
        label: 'logged buys',
        note: 'Historical purchase records currently in the operating set.',
      },
      {
        value: 'EUR 41',
        label: 'average ticket',
        note: 'Mid-size lots dominate while rarer promos skew high.',
      },
      {
        value: '3',
        label: 'open intake batches',
        note: 'Purchase groups still moving through arrival and verification.',
      },
    ],
    featureLabel: 'Procurement rhythm',
    featureTitle: 'Intake needs to preserve story: where the card came from, how it arrived, and what it really cost.',
    featureBody:
      'A collector-facing acquisitions screen should make seller trust, shipping friction, and bundle economics obvious at the same glance as the raw price.',
    tags: ['seller provenance', 'arrival checkpoints', 'bundle allocation'],
    tableTitle: 'Open batches',
    tableRows: [
      {
        label: 'Tokyo promo lot',
        value: '2 cards / EUR 96',
        note: 'Awaiting customs clearance before condition confirmation.',
      },
      {
        label: 'Berlin meetup trade',
        value: '1 card / EUR 18',
        note: 'Hand-off complete, card pending sleeve swap and scan.',
      },
      {
        label: 'Marketplace bundle',
        value: '4 cards / EUR 74',
        note: 'Bundle cost still needs final allocation across print lines.',
      },
    ],
    noteTitle: 'Why this matters',
    noteBody:
      'If acquisition detail is captured late, it becomes folklore. This route should lock those facts in at the moment of purchase.',
    nextLabel: 'Audit listing posture',
    nextHref: '/listings',
  },
  sales: {
    eyebrow: 'Exit performance',
    title: 'Sales',
    description:
      'Sales should connect each exit to its acquisition history so realized profitability is visible as an operational truth, not a rough estimate.',
    actionLabel: 'Inspect marketplace listings',
    actionHref: '/listings',
    metrics: [
      {
        value: '29',
        label: 'completed sales',
        note: 'Recorded exits across direct buyers and marketplace channels.',
      },
      {
        value: 'EUR 612',
        label: 'realized revenue',
        note: 'Current tracked revenue inside the active reporting horizon.',
      },
      {
        value: '8.7%',
        label: 'net margin',
        note: 'Post-cost performance with basis tied back to actual buys.',
      },
    ],
    featureLabel: 'Margin guardrails',
    featureTitle: 'A sale only feels good if it respected cost basis, shipping drag, and collection priorities.',
    featureBody:
      'This route should keep the operator honest about what left the collection, what it earned, and whether the card should have been sold at all.',
    tags: ['realized profitability', 'buyer channel mix', 'postage drag'],
    tableTitle: 'Recent exits',
    tableRows: [
      {
        label: 'Cardmarket order 1184',
        value: 'EUR 46',
        note: 'Base Set 2 holo sold above target spread after two reprices.',
      },
      {
        label: 'Direct collector sale',
        value: 'EUR 31',
        note: 'Neo promo moved quickly because provenance notes were already ready.',
      },
      {
        label: 'Local meetup hand-off',
        value: 'EUR 22',
        note: 'Lower gross, but zero shipping and immediate payment preserved margin.',
      },
    ],
    noteTitle: 'Why this matters',
    noteBody:
      'Sales data is the final proof that the rest of the stack is disciplined. If this screen is weak, the collection strategy stays fuzzy.',
    nextLabel: 'Return to dashboard',
    nextHref: '/dashboard',
  },
  listings: {
    eyebrow: 'Marketplace posture',
    title: 'Listings',
    description:
      'Listings should feel like a trading board: live, comparative, and tightly connected to the inventory item and cost basis beneath each offer.',
    actionLabel: 'Back to command overview',
    actionHref: '/dashboard',
    metrics: [
      {
        value: '19',
        label: 'active listings',
        note: 'Inventory currently exposed across external marketplaces.',
      },
      {
        value: '3',
        label: 'channels',
        note: 'Direct sales, Cardmarket, and experimental collector boards.',
      },
      {
        value: '6',
        label: 'reprices this week',
        note: 'Ask tuning triggered by spread compression and stale age.',
      },
    ],
    featureLabel: 'Listing posture',
    featureTitle: 'A listing is only healthy when the ask, condition, and storage reality agree with each other.',
    featureBody:
      'The listings view should expose stale offers, channel imbalance, and underpriced units before they leak margin or create fulfillment friction.',
    tags: ['spread vs basis', 'stale inventory watch', 'channel-specific tone'],
    tableTitle: 'Live market board',
    tableRows: [
      {
        label: 'Cardmarket holo pair',
        value: 'EUR 52 ask',
        note: 'Healthy spread but aging toward two-week stale threshold.',
      },
      {
        label: 'Promo single on direct board',
        value: 'EUR 64 ask',
        note: 'High-conviction listing backed by strong condition notes and scans.',
      },
      {
        label: 'Binder non-holo lot',
        value: 'EUR 18 ask',
        note: 'Cheap mover that should not crowd attention away from premium units.',
      },
    ],
    noteTitle: 'Why this matters',
    noteBody:
      'Listings are where catalog accuracy, inventory truth, and sales discipline collide. The interface should make that pressure visible immediately.',
    nextLabel: 'Visit the login scaffold',
    nextHref: '/login',
  },
} satisfies Record<string, SectionContent>;

export const loginHighlights = [
  'Collector-focused authentication surface, not a generic admin form.',
  'Fast hand-off into the dashboard once session work is wired in.',
  'Room for role-based access without losing the calm visual language.',
];
