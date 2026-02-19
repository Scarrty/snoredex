# Snorlax Spreadsheet Documentation

This file documents the source workbook `snorlax_incl jp.xlsx` used as the base input for Snoredex.

## Dataset summary

- Focus: Snorlax Pokémon TCG prints (including promos/variants)
- Size: 207 rows × 25 columns
- Granularity: one row per distinct print entry
- Includes: set metadata, print type, language availability, Cardmarket references

## Structural sections

### Identification & sorting

- `Sort Nr.`: internal ordering key
- `Pokemon`: Pokémon name
- `Nr.`: card number within set

### Set metadata

- `Set`
- `Set Code`
- `Era`
- `Type`

### Marketplace linkage

- Cardmarket availability indicator
- Cardmarket URL field

### Language matrix

Language columns encode print availability using:

- `1` → available
- empty value → unavailable/unknown

Tracked languages include:

`JP`, `T-CHN`, `S-CHN`, `IND`, `THAI`, `KOR`, `EN`, `DE`, `IT`, `FR`, `PT`, `ES`, `LATM`, `NL`, `RU`, `PL`

## How this maps to the relational schema

- Set metadata maps to `eras`, `sets`, and `card_prints`.
- Type/variant values map to `card_types`.
- Language matrix maps to `languages` and `card_print_languages`.
- Cardmarket references map to `marketplaces` and `external_listings`.
