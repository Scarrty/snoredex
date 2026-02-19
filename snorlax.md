# snorlax.md

## Overview

This file documents the structure and organization of `snorlax_incl jp.xlsx`.

The spreadsheet is a structured catalog of **Snorlax Pokémon TCG cards**, including Japanese and international releases.  
Each row represents a single card print/version.  
The table contains **207 rows** and **25 columns**.

The file functions as a multilingual checklist and collection tracker.

---

## Row Structure

Each row represents:

- One specific Snorlax card print
- A specific set
- A specific version (Holo / Non-Holo / Promo)
- Language availability tracking

Duplicate Pokémon numbers may exist when:
- The same card appears in multiple sets
- There are different print variations
- There are language or rarity differences

---

## Column Structure

### 1. Cardmarket Reference

| Column | Description |
|--------|------------|
| `auf CM auffindbar?` | Indicates whether the card is available/found on Cardmarket (may be empty). |
| `Unnamed: 1` | Direct Cardmarket product URL for the card. |

This section links the spreadsheet entry to its marketplace listing.

---

### 2. Sorting & Identification

| Column | Description |
|--------|------------|
| `Sort Nr.` | Internal sorting number used to order the entries. |
| `Pokemon` | Pokémon name (mostly "Snorlax", occasionally variants like "Hungry Snorlax"). |
| `Nr.` | Card number within the set (e.g., `11/64`, `No. 028`). |

The `Sort Nr.` column controls display order rather than set chronology alone.

---

### 3. Set Information

| Column | Description |
|--------|------------|
| `Set` | Full name of the Pokémon TCG set. |
| `Set Code` | Abbreviation of the set (e.g., JU for Jungle). |
| `Era` | Historical era of the card (e.g., "Original"). |
| `Type` | Card type or rarity classification (e.g., Holo, Non-Holo, Promo). |

This section defines the origin and classification of the card.

---

### 4. Language Availability Columns

The spreadsheet tracks whether a card exists in specific languages.

| Column | Language |
|--------|----------|
| `JP` | Japanese |
| `T-CHN` | Traditional Chinese |
| `S-CHN` | Simplified Chinese |
| `IND` | Indonesian |
| `THAI` | Thai |
| `KOR` | Korean |
| `EN` | English |
| `DE` | German |
| `IT` | Italian |
| `FR` | French |
| `PT` | Portuguese |
| `ES` | Spanish |
| `LATM` | Latin American Spanish |
| `NL` | Dutch |
| `RU` | Russian |
| `PL` | Polish |

### Language Value Logic

- `1` → Card exists in this language.
- `NaN` (empty) → Card not released in this language.

This structure allows quick filtering for multilingual collecting.

---

## Organizational Logic

The file is structured in the following logical hierarchy:

1. Internal sorting (`Sort Nr.`)
2. Pokémon name
3. Set
4. Card number
5. Card type (Holo / Non-Holo / Promo)
6. Language availability

The spreadsheet acts as:

- A master checklist
- A multilingual release tracker
- A Cardmarket-linked reference database
- A structured archive of all Snorlax prints

---

## Data Characteristics

- Total Rows: 207
- Total Columns: 25
- Focus: Snorlax cards (including promos and variants)
- Includes Japanese-exclusive and international prints
- Includes early era ("Original") releases

---

## Summary

`snorlax_incl jp.xlsx` is a structured multilingual Snorlax card database designed for:

- Collection tracking
- Market referencing
- Language completeness verification
- Set-based categorization

It combines marketplace links, structured metadata, and language availability into a single organized tracking system.
