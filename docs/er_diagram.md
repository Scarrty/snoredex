# Snoredex ER Diagram

```mermaid
erDiagram

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

    CARDMARKET_LISTINGS {
        int id PK
        int card_print_id FK
        text url
        boolean is_available
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
        int owner_id
        int location_id FK
        int condition_id FK
        varchar grade_provider
        decimal grade_value
        int quantity_on_hand
        int quantity_reserved
        int quantity_damaged
    }

    POKEMON ||--o{ CARD_PRINTS : has
    SETS ||--o{ CARD_PRINTS : contains
    ERAS ||--o{ SETS : categorizes
    CARD_TYPES ||--o{ CARD_PRINTS : classifies
    CARD_PRINTS ||--o{ CARD_PRINT_LANGUAGES : printed_in
    LANGUAGES ||--o{ CARD_PRINT_LANGUAGES : available_as
    CARD_PRINTS ||--o{ CARDMARKET_LISTINGS : listed_on
    CARD_PRINTS ||--o{ INVENTORY_ITEMS : stocked_as
    LOCATIONS ||--o{ INVENTORY_ITEMS : stores
    CARD_CONDITIONS ||--o{ INVENTORY_ITEMS : conditions
```
