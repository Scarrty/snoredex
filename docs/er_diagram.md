<!-- SPDX-License-Identifier: CC-BY-NC-4.0 -->
<!-- Database schema artifact licensed under CC BY-NC 4.0:
     https://creativecommons.org/licenses/by-nc/4.0/ -->

# Snoredex ER Diagram

```mermaid
erDiagram
    USERS {
        int id PK
        varchar username
        varchar email
        varchar display_name
    }

    POKEMON {
        int id PK
        varchar name
        int national_dex_no
    }

    ERAS {
        int id PK
        varchar name
    }

    SETS {
        int id PK
        varchar name
        varchar set_code
        int era_id FK
    }

    CARD_TYPES {
        int id PK
        varchar name
    }

    CARD_PRINTS {
        int id PK
        int pokemon_id FK
        int set_id FK
        varchar card_number
        int type_id FK
        int sort_number
    }

    LANGUAGES {
        int id PK
        varchar code
        varchar name
    }

    CARD_PRINT_LANGUAGES {
        int card_print_id FK
        int language_id FK
    }

    LOCATIONS {
        int id PK
        varchar name
        varchar location_type
    }

    CARD_CONDITIONS {
        int id PK
        varchar code
        varchar name
        int sort_order
    }

    INVENTORY_ITEMS {
        int id PK
        int card_print_id FK
        int user_id FK
        int location_id FK
        int condition_id FK
        varchar grade_provider
        numeric grade_value
        int quantity_on_hand
        int quantity_reserved
        int quantity_damaged
    }

    INVENTORY_MOVEMENTS {
        int id PK
        int inventory_item_id FK
        enum movement_type
        int quantity_delta
        timestamptz occurred_at
        varchar reference_type
        varchar reference_id
        varchar created_by
    }

    MARKETPLACES {
        int id PK
        varchar name
        varchar slug
        text base_url
        boolean is_active
    }

    EXTERNAL_LISTINGS {
        int id PK
        int marketplace_id FK
        int inventory_item_id FK
        varchar external_listing_id
        enum listing_status
        numeric listed_price
        char currency
        int quantity_listed
        timestamptz synced_at
        text url
    }

    ACQUISITIONS {
        int id PK
        date acquired_at
        varchar supplier_reference
        varchar channel
        char currency
    }

    ACQUISITION_LINES {
        int id PK
        int acquisition_id FK
        int inventory_item_id FK
        int language_id FK
        int quantity
        numeric unit_cost
        numeric fees
        numeric shipping
    }

    SALES {
        int id PK
        date sold_at
        varchar buyer_reference
        varchar channel
        char currency
    }

    SALES_LINES {
        int id PK
        int sale_id FK
        int inventory_item_id FK
        int language_id FK
        int quantity
        numeric unit_sale_price
        numeric fees
        numeric shipping
    }

    ERAS ||--o{ SETS : categorizes
    POKEMON ||--o{ CARD_PRINTS : has
    SETS ||--o{ CARD_PRINTS : contains
    CARD_TYPES ||--o{ CARD_PRINTS : classifies

    CARD_PRINTS ||--o{ CARD_PRINT_LANGUAGES : printed_in
    LANGUAGES ||--o{ CARD_PRINT_LANGUAGES : available_as

    CARD_PRINTS ||--o{ INVENTORY_ITEMS : stocked_as
    USERS ||--o{ INVENTORY_ITEMS : owns
    LOCATIONS ||--o{ INVENTORY_ITEMS : stored_in
    CARD_CONDITIONS ||--o{ INVENTORY_ITEMS : conditioned_as
    INVENTORY_ITEMS ||--o{ INVENTORY_MOVEMENTS : moves_through

    MARKETPLACES ||--o{ EXTERNAL_LISTINGS : hosts
    INVENTORY_ITEMS ||--o{ EXTERNAL_LISTINGS : listed_as

    ACQUISITIONS ||--o{ ACQUISITION_LINES : has
    INVENTORY_ITEMS ||--o{ ACQUISITION_LINES : procured_as
    LANGUAGES ||--o{ ACQUISITION_LINES : acquired_language

    SALES ||--o{ SALES_LINES : has
    INVENTORY_ITEMS ||--o{ SALES_LINES : sold_from
    LANGUAGES ||--o{ SALES_LINES : sold_language
```

## Notes

- `cardmarket_listings`, `reporting_avg_acquisition_cost`, and `reporting_profitability_by_card_set_language` are SQL views derived from these entities.
- Inventory quantity synchronization is enforced by triggers and helper functions in `database/schema.sql`.
