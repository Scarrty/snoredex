# 💤 Snoredex

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Relational_DB-336791?logo=postgresql&logoColor=white)
![Normalized](https://img.shields.io/badge/Schema-3NF-blue)
![Status](https://img.shields.io/badge/Status-Active-success)
![License](https://img.shields.io/badge/License-MIT-green)
![Snorlax](https://img.shields.io/badge/Pokémon-Snorlax-3b4cca)
## 📘 Project Overview

Snoredex is a normalized database model for tracking all Snorlax Pokémon TCG prints across:

- Sets
- Eras
- Print Types
- Languages
- Marketplace Listings

The schema follows **3rd Normal Form (3NF)** and is designed for:

- Collection tracking
- Analytics
- Marketplace syncing
- API development
- Multilingual release tracking

---

## 🗺 Database ER Diagram

```mermaid
erDiagram
    POKEMON ||--o{ CARD_PRINTS : has
    SETS ||--o{ CARD_PRINTS : contains
    ERAS ||--o{ SETS : categorizes
    CARD_TYPES ||--o{ CARD_PRINTS : classifies
    CARD_PRINTS ||--o{ CARD_PRINT_LANGUAGES : printed_in
    LANGUAGES ||--o{ CARD_PRINT_LANGUAGES : available_as
    CARD_PRINTS ||--o{ CARDMARKET_LISTINGS : listed_on
