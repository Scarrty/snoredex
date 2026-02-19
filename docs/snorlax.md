# Snorlax Data Structure

This document describes the structure of `snorlax_incl jp.xlsx`.

## Overview

The file is a structured catalog of Snorlax Pokémon TCG cards.

- 207 rows
- 25 columns
- Each row = one unique card print
- Includes multilingual availability
- Includes Cardmarket references

## Core Fields

- Sort Nr.
- Pokemon
- Nr. (Card number)
- Set
- Set Code
- Era
- Type

## Language Columns

Each language column contains:

- `1` → card exists in this language
- empty → not printed in this language

Languages tracked:

JP, T-CHN, S-CHN, IND, THAI, KOR, EN, DE, IT, FR, PT, ES, LATM, NL, RU, PL

## Purpose

- Collection tracking
- Multilingual release verification
- Marketplace linking
- Structured Snorlax archive
