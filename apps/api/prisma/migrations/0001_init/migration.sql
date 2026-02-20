-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "username" VARCHAR(100) NOT NULL,
    "email" VARCHAR(255),
    "display_name" VARCHAR(255),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pokemon" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "national_dex_no" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "pokemon_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "eras" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "eras_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sets" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "set_code" VARCHAR(20),
    "era_id" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "card_types" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "card_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "card_prints" (
    "id" SERIAL NOT NULL,
    "pokemon_id" INTEGER NOT NULL,
    "set_id" INTEGER NOT NULL,
    "card_number" VARCHAR(50) NOT NULL,
    "type_id" INTEGER,
    "sort_number" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "card_prints_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "languages" (
    "id" SERIAL NOT NULL,
    "code" VARCHAR(20) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "languages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "card_print_languages" (
    "card_print_id" INTEGER NOT NULL,
    "language_id" INTEGER NOT NULL,

    CONSTRAINT "card_print_languages_pkey" PRIMARY KEY ("card_print_id","language_id")
);

-- CreateTable
CREATE TABLE "locations" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "location_type" VARCHAR(100) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "locations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "card_conditions" (
    "id" SERIAL NOT NULL,
    "code" VARCHAR(20) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "sort_order" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "card_conditions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "inventory_items" (
    "id" SERIAL NOT NULL,
    "card_print_id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,
    "location_id" INTEGER NOT NULL,
    "condition_id" INTEGER NOT NULL,
    "grade_provider" VARCHAR(100),
    "grade_value" DECIMAL(3,1),
    "quantity_on_hand" INTEGER NOT NULL DEFAULT 1,
    "quantity_reserved" INTEGER NOT NULL DEFAULT 0,
    "quantity_damaged" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "inventory_items_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "pokemon_name_key" ON "pokemon"("name");

-- CreateIndex
CREATE UNIQUE INDEX "pokemon_national_dex_no_key" ON "pokemon"("national_dex_no");

-- CreateIndex
CREATE UNIQUE INDEX "eras_name_key" ON "eras"("name");

-- CreateIndex
CREATE UNIQUE INDEX "sets_name_set_code_key" ON "sets"("name", "set_code");

-- CreateIndex
CREATE UNIQUE INDEX "card_types_name_key" ON "card_types"("name");

-- CreateIndex
CREATE UNIQUE INDEX "languages_code_key" ON "languages"("code");

-- CreateIndex
CREATE UNIQUE INDEX "card_conditions_code_key" ON "card_conditions"("code");

-- CreateIndex
CREATE UNIQUE INDEX "card_conditions_sort_order_key" ON "card_conditions"("sort_order");

-- AddForeignKey
ALTER TABLE "sets" ADD CONSTRAINT "sets_era_id_fkey" FOREIGN KEY ("era_id") REFERENCES "eras"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "card_prints" ADD CONSTRAINT "card_prints_pokemon_id_fkey" FOREIGN KEY ("pokemon_id") REFERENCES "pokemon"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "card_prints" ADD CONSTRAINT "card_prints_set_id_fkey" FOREIGN KEY ("set_id") REFERENCES "sets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "card_prints" ADD CONSTRAINT "card_prints_type_id_fkey" FOREIGN KEY ("type_id") REFERENCES "card_types"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "card_print_languages" ADD CONSTRAINT "card_print_languages_card_print_id_fkey" FOREIGN KEY ("card_print_id") REFERENCES "card_prints"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "card_print_languages" ADD CONSTRAINT "card_print_languages_language_id_fkey" FOREIGN KEY ("language_id") REFERENCES "languages"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_items" ADD CONSTRAINT "inventory_items_card_print_id_fkey" FOREIGN KEY ("card_print_id") REFERENCES "card_prints"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_items" ADD CONSTRAINT "inventory_items_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_items" ADD CONSTRAINT "inventory_items_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "locations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_items" ADD CONSTRAINT "inventory_items_condition_id_fkey" FOREIGN KEY ("condition_id") REFERENCES "card_conditions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

