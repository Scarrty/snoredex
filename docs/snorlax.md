# Snorlax Source Spreadsheet Structure

This document describes the source dataset `snorlax_incl jp.xlsx` that informed the initial Snoredex schema modeling.

## Overview

- 207 rows
- 25 columns
- Each row represents one unique Snorlax card print/version
- Includes multilingual print availability
- Includes Cardmarket reference fields

## Core columns

- `Sort Nr.`
- `Pokemon`
- `Nr.` (card number)
- `Set`
- `Set Code`
- `Era`
- `Type`

## Language availability columns

Value semantics:

- `1` = card exists in that language
- empty cell = no known print in that language

Languages tracked:

`JP`, `T-CHN`, `S-CHN`, `IND`, `THAI`, `KOR`, `EN`, `DE`, `IT`, `FR`, `PT`, `ES`, `LATM`, `NL`, `RU`, `PL`

## Marketplace columns

- Presence/availability marker for Cardmarket
- Cardmarket product URL

## Role in Snoredex

The spreadsheet acted as the migration input for:

- Normalized card print metadata
- Language availability mapping
- Initial marketplace reference normalization
