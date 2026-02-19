Overview

This schema converts the flat Excel structure into a normalized relational database model.

Goals:

Remove repetition (especially languages and sets)

Support future Pokémon additions

Support multiple print variations

Maintain marketplace references

Enable multilingual release tracking

Entity Relationship Overview
Pokemon ──< CardPrint >── Set
                   │
                   ├──< CardMarketListing
                   │
                   └──< CardPrintLanguage >── Language

Tables
1. pokemon

Stores Pokémon species.

CREATE TABLE pokemon (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    national_dex_no INTEGER NULL
);

Notes

Currently mostly "Snorlax"

Allows expansion to other Pokémon later

national_dex_no optional

2. eras

Represents historical TCG eras.

CREATE TABLE eras (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) NOT NULL
);


Examples:

Original

Neo

EX

Diamond & Pearl

etc.

3. sets

Stores Pokémon TCG sets.

CREATE TABLE sets (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    set_code    VARCHAR(20),
    era_id      INTEGER REFERENCES eras(id)
);

Notes

set_code examples: JU, BS, etc.

Linked to eras

4. card_types

Represents rarity / print classification.

CREATE TABLE card_types (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) NOT NULL
);


Examples:

Holo

Non-Holo

Promo

Reverse Holo

5. card_prints

Core table: one row per unique printed card.

CREATE TABLE card_prints (
    id              SERIAL PRIMARY KEY,
    pokemon_id      INTEGER NOT NULL REFERENCES pokemon(id),
    set_id          INTEGER NOT NULL REFERENCES sets(id),
    card_number     VARCHAR(50) NOT NULL,
    type_id         INTEGER REFERENCES card_types(id),
    sort_number     INTEGER
);

Represents:

One specific card print

One set

One card number

One rarity type

This replaces:

Pokemon

Nr.

Set

Type

Sort Nr.

6. languages

Stores supported card languages.

CREATE TABLE languages (
    id      SERIAL PRIMARY KEY,
    code    VARCHAR(20) UNIQUE NOT NULL,
    name    VARCHAR(100) NOT NULL
);

Example entries
code	name
JP	Japanese
EN	English
DE	German
FR	French
IT	Italian
ES	Spanish
LATM	Latin American Spanish
NL	Dutch
RU	Russian
PL	Polish
KOR	Korean
THAI	Thai
IND	Indonesian
S-CHN	Simplified Chinese
T-CHN	Traditional Chinese
PT	Portuguese
7. card_print_languages

Join table to track language availability.

CREATE TABLE card_print_languages (
    card_print_id  INTEGER REFERENCES card_prints(id) ON DELETE CASCADE,
    language_id    INTEGER REFERENCES languages(id) ON DELETE CASCADE,
    PRIMARY KEY (card_print_id, language_id)
);

Logic

If a record exists → card was printed in that language.
If no record → not released in that language.

This replaces the 16 language columns.

8. cardmarket_listings

Stores marketplace references.

CREATE TABLE cardmarket_listings (
    id              SERIAL PRIMARY KEY,
    card_print_id   INTEGER REFERENCES card_prints(id) ON DELETE CASCADE,
    url             TEXT,
    is_available    BOOLEAN
);


Replaces:

auf CM auffindbar?

Unnamed: 1 (URL column)