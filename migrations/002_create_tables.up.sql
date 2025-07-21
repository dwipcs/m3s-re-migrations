START TRANSACTION;

CREATE TABLE IF NOT EXISTS `emv_tags` (
    `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `code`        VARCHAR(255) NOT NULL UNIQUE,
    `name`        VARCHAR(255) NOT NULL,
    `description` TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS `provinces` (
    `id`         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name`       VARCHAR(255) NOT NULL UNIQUE,
    INDEX `idx_name` (`name`)
);

CREATE TABLE IF NOT EXISTS `cities` (
    `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `province_id` INT UNSIGNED NOT NULL,
    `name`        VARCHAR(255) NOT NULL UNIQUE,
    INDEX `idx_province_id` (`province_id`),
    INDEX `idx_name` (`name`),
    CONSTRAINT `fk_cities_province_id_provinces` FOREIGN KEY (`province_id`) REFERENCES `provinces`(`id`) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS `districts` (
    `id`         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `city_id`    INT UNSIGNED NOT NULL,
    `name`       VARCHAR(255) NOT NULL,
    INDEX `idx_city_id` (`city_id`),
    INDEX `idx_name` (`name`),
    CONSTRAINT `fk_districts_city_id_cities` FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS `companies` (
    `id`                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `admin_id`          INT UNSIGNED NOT NULL,
    `name`              VARCHAR(255) NOT NULL,
    `icon`              VARCHAR(255) DEFAULT NULL,
    `icon_updated_at`   TIMESTAMP    NULL DEFAULT NULL,
    `created_at`        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`        TIMESTAMP    NULL DEFAULT NULL,
    `name_active`       VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    INDEX `idx_name` (`name`),
    INDEX `idx_admin_id` (`admin_id`),
    UNIQUE KEY `uq_companies_name_active` (`name_active`)
);

CREATE TABLE IF NOT EXISTS `users` (
    `id`              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `company_id`      INT UNSIGNED NOT NULL,
    `username`        VARCHAR(255) NOT NULL,
    `email`           VARCHAR(255) NOT NULL,
    `password`        VARCHAR(255) NOT NULL,
    `fullname`        VARCHAR(255) NOT NULL,
    `created_at`      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`      TIMESTAMP    NULL     DEFAULT NULL,
    `username_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `username`, NULL)) STORED,
    `email_active`    VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `email`, NULL)) STORED,
    INDEX `idx_company_id` (`company_id`),
    INDEX `idx_username` (`username`),
    INDEX `idx_email` (`email`),
    INDEX `idx_fullname` (`fullname`),
    CONSTRAINT `fk_users_company_id_companies` FOREIGN KEY (`company_id`) REFERENCES `companies`(`id`) ON DELETE RESTRICT,
    UNIQUE KEY `uq_users_company_username_active` (`company_id`, `username_active`),
    UNIQUE KEY `uq_users_company_email_active` (`company_id`, `email_active`)
);

CREATE TABLE IF NOT EXISTS `profiles` (
    `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `company_id`  INT UNSIGNED NOT NULL,
    `code`        VARCHAR(255) NOT NULL,
    `name`        VARCHAR(255) NOT NULL,
    `is_active`   BOOLEAN      NOT NULL DEFAULT TRUE,
    `created_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`  TIMESTAMP    NULL     DEFAULT NULL,
    `code_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `code`, NULL)) STORED,
    `name_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    INDEX `idx_company_id` (`company_id`),
    INDEX `idx_code` (`code`),
    INDEX `idx_name` (`name`),
    CONSTRAINT `fk_profiles_company_id_companies` FOREIGN KEY (`company_id`) REFERENCES `companies`(`id`) ON DELETE RESTRICT,
    UNIQUE KEY `uq_profiles_company_code_active` (`company_id`, `code_active`),
    UNIQUE KEY `uq_profiles_company_name_active` (`company_id`, `name_active`)
);

CREATE TABLE IF NOT EXISTS `clients` (
    `id`                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `company_id`        INT UNSIGNED NOT NULL,
    `profile_id`        INT UNSIGNED NOT NULL,
    `district_id`       INT UNSIGNED NOT NULL,
    `code`              VARCHAR(255) NOT NULL,
    `name`              VARCHAR(255) NOT NULL,
    `phone`             VARCHAR(15)  NOT NULL,
    `fax`               VARCHAR(50)  DEFAULT NULL,
    `icon`              VARCHAR(255) DEFAULT NULL,
    `icon_updated_at`   TIMESTAMP    NULL DEFAULT NULL,
    `pic_name`          VARCHAR(255) NOT NULL,
    `pic_phone`         VARCHAR(15)  NOT NULL,
    `village`           VARCHAR(100) NOT NULL,
    `postal_code`       VARCHAR(20)  NOT NULL,
    `address`           TEXT         NOT NULL,
    `created_at`        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`        TIMESTAMP    NULL DEFAULT NULL,
    `name_active`       VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    `code_active`       VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `code`, NULL)) STORED,
    INDEX `idx_company_id` (`company_id`),
    INDEX `idx_profile_id` (`profile_id`),
    INDEX `idx_district_id` (`district_id`),
    INDEX `idx_code` (`code`),
    INDEX `idx_name` (`name`),
    INDEX `idx_pic_name` (`pic_name`),
    CONSTRAINT `fk_clients_company_id_companies` FOREIGN KEY (`company_id`) REFERENCES `companies`(`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_clients_profile_id_profiles` FOREIGN KEY (`profile_id`) REFERENCES `profiles`(`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_clients_district_id_districts` FOREIGN KEY (`district_id`) REFERENCES `districts`(`id`) ON DELETE RESTRICT,
    UNIQUE KEY `uq_clients_company_name_active` (`company_id`, `name_active`),
    UNIQUE KEY `uq_clients_company_code_active` (`company_id`, `code_active`)
);

CREATE TABLE IF NOT EXISTS `roles` (
    `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `client_id`   INT UNSIGNED NOT NULL,
    `code`        VARCHAR(255) NOT NULL,
    `name`        VARCHAR(255) NOT NULL,
    `super_admin` BOOLEAN      NOT NULL DEFAULT FALSE,
    `description` TEXT         DEFAULT NULL,
    `created_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`  TIMESTAMP    NULL     DEFAULT NULL,
    `code_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `code`, NULL)) STORED,
    `name_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    INDEX `idx_code` (`code`),
    INDEX `idx_name` (`name`),
    INDEX `idx_client_id` (`client_id`),
    CONSTRAINT `fk_roles_client_id_clients` FOREIGN KEY (`client_id`) REFERENCES `clients`(`id`) ON DELETE RESTRICT,
    UNIQUE KEY `uq_roles_client_code_active` (`client_id`, `code_active`),
    UNIQUE KEY `uq_roles_client_name_active` (`client_id`, `name_active`)
);

CREATE TABLE IF NOT EXISTS `permissions` (
    `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `code`        VARCHAR(255) NOT NULL,
    `name`        VARCHAR(255) NOT NULL,
    `description` TEXT         DEFAULT NULL,
    `created_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`  TIMESTAMP    NULL     DEFAULT NULL,
    `code_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `code`, NULL)) STORED,
    `name_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    INDEX `idx_code` (`code`),
    INDEX `idx_name` (`name`),
    UNIQUE KEY `uq_permissions_code_active` (`code_active`),
    UNIQUE KEY `uq_permissions_name_active` (`name_active`)
);

CREATE TABLE IF NOT EXISTS `groups` (
    `id`                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `client_id`         INT UNSIGNED NOT NULL,
    `name`              VARCHAR(255) NOT NULL,
    `icon`              VARCHAR(255) DEFAULT NULL,
    `icon_updated_at`   TIMESTAMP    NULL DEFAULT NULL,
    `address`           VARCHAR(255) NOT NULL,
    `created_at`        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`        TIMESTAMP    NULL DEFAULT NULL,
    `name_active`       VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    INDEX `idx_client_id` (`client_id`),
    INDEX `idx_name` (`name`),
    CONSTRAINT `fk_groups_client_id_clients` FOREIGN KEY (`client_id`) REFERENCES `clients`(`id`) ON DELETE RESTRICT,
    UNIQUE KEY `uq_groups_client_name_active` (`client_id`, `name_active`)
);

CREATE TABLE IF NOT EXISTS `merchants` (
    `id`                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `group_id`          INT UNSIGNED NOT NULL,
    `name`              VARCHAR(255) NOT NULL,
    `icon`              VARCHAR(255) DEFAULT NULL,
    `icon_updated_at`   TIMESTAMP    NULL DEFAULT NULL,
    `address`           VARCHAR(255) NOT NULL,
    `created_at`        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`        TIMESTAMP    NULL DEFAULT NULL,
    `name_active`       VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    INDEX `idx_group_id` (`group_id`),
    INDEX `idx_name` (`name`),
    CONSTRAINT `fk_merchants_group_id_groups` FOREIGN KEY (`group_id`) REFERENCES `groups`(`id`) ON DELETE RESTRICT,
    UNIQUE KEY `uq_merchants_group_name_active` (`group_id`, `name_active`)
);

CREATE TABLE IF NOT EXISTS `products` (
    `id`         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name`       VARCHAR(255) NOT NULL,
    `brand`      VARCHAR(255) DEFAULT NULL,
    `created_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` TIMESTAMP    NULL     DEFAULT NULL,
    `name_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    `brand_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `brand`, NULL)) STORED,
    INDEX `idx_name` (`name`),
    INDEX `idx_brand` (`brand`),
    UNIQUE KEY `uq_products_name_brand_active` (`name_active`, `brand_active`)
);

CREATE TABLE IF NOT EXISTS `stocks` (
    `id`                   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `product_id`           INT UNSIGNED NOT NULL,
    `serial_number`        VARCHAR(255) NOT NULL,
    `imei`                 VARCHAR(20)  DEFAULT NULL,
    `created_at`           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`           TIMESTAMP    NULL     DEFAULT NULL,
    `serial_number_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `serial_number`, NULL)) STORED,
    `imei_active`          VARCHAR(20)  GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `imei`,          NULL)) STORED,
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_serial_number` (`serial_number`),
    INDEX `idx_imei` (`imei`),
    CONSTRAINT `fk_stocks_product_id_products` FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE RESTRICT,
    UNIQUE KEY `uq_stocks_serial_number_active` (`serial_number_active`),
    UNIQUE KEY `uq_stocks_imei_active` (`imei_active`)
);

CREATE TABLE IF NOT EXISTS `user_roles` (
    `user_id` INT UNSIGNED NOT NULL,
    `role_id` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`user_id`, `role_id`),
    CONSTRAINT `fk_user_roles_user_id_users` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_user_roles_role_id_roles` FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS `role_permissions` (
    `role_id`       INT UNSIGNED NOT NULL,
    `permission_id` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`role_id`, `permission_id`),
    CONSTRAINT `fk_role_permissions_role_id_roles` FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_role_permissions_permission_id_permissions` FOREIGN KEY (`permission_id`) REFERENCES `permissions`(`id`) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS `endpoints` (
    `id`         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name`       VARCHAR(255) NOT NULL,
    `url`        VARCHAR(255) NOT NULL,
    `port`       INT          NOT NULL,
    `created_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` TIMESTAMP    NULL     DEFAULT NULL,
    `name_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    `url_active`  VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `url`,  NULL)) STORED,
    `port_active` INT          GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `port`, NULL)) STORED,
    INDEX `idx_name` (`name`),
    UNIQUE KEY `uq_endpoints_name_active` (`name_active`),
    UNIQUE KEY `uq_endpoints_url_port_active` (`url_active`, `port_active`)
);

CREATE TABLE IF NOT EXISTS `issuers` (
    `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `endpoint_id` INT UNSIGNED NOT NULL,
    `code`        VARCHAR(255) NOT NULL,
    `name`        VARCHAR(255) NOT NULL,
    `created_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`  TIMESTAMP    NULL     DEFAULT NULL,
    `code_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `code`, NULL)) STORED,
    `name_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    INDEX `idx_endpoint_id` (`endpoint_id`),
    INDEX `idx_code` (`code`),
    INDEX `idx_name` (`name`),
    CONSTRAINT `fk_issuers_endpoint_id_endpoints` FOREIGN KEY (`endpoint_id`) REFERENCES `endpoints`(`id`) ON DELETE RESTRICT,
    UNIQUE KEY `uq_issuers_code_active` (`code_active`),
    UNIQUE KEY `uq_issuers_name_active` (`name_active`)
);

CREATE TABLE IF NOT EXISTS `principles` (
    `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `rid`         VARCHAR(255) NOT NULL,
    `name`        VARCHAR(255) NOT NULL,
    `created_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`  TIMESTAMP    NULL     DEFAULT NULL,
    `rid_active`  VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `rid`,  NULL)) STORED,
    `name_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    INDEX `idx_rid` (`rid`),
    INDEX `idx_name` (`name`),
    UNIQUE KEY `uq_principles_rid_active` (`rid_active`),
    UNIQUE KEY `uq_principles_name_active` (`name_active`)
);

CREATE TABLE IF NOT EXISTS `bins` (
    `id`           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `principle_id` INT UNSIGNED NOT NULL,
    `bank_name`    VARCHAR(255) NOT NULL,
    `card_type`    VARCHAR(50)  NOT NULL CHECK (`card_type` IN ('credit', 'debit', 'prepaid')),
    `bin_min`      BIGINT UNSIGNED DEFAULT NULL,
    `bin_max`      BIGINT UNSIGNED DEFAULT NULL,
    `created_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`   TIMESTAMP    NULL     DEFAULT NULL,
    `bin_min_active` BIGINT UNSIGNED GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `bin_min`, NULL)) STORED,
    `bin_max_active` BIGINT UNSIGNED GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `bin_max`, NULL)) STORED,
    INDEX `idx_principle_id` (`principle_id`),
    INDEX `idx_bank_name` (`bank_name`),
    CONSTRAINT `fk_bins_principle_id_principles` FOREIGN KEY (`principle_id`) REFERENCES `principles`(`id`) ON DELETE RESTRICT,
    UNIQUE KEY `uq_bins_principle_range_active` (`principle_id`, `bin_min_active`, `bin_max_active`)
);

CREATE TABLE IF NOT EXISTS `issuer_principles` (
    `issuer_id`         INT UNSIGNED NOT NULL,
    `principle_id`      INT UNSIGNED NOT NULL,
    `emv_tag`           VARCHAR(255) NOT NULL,
    `detail`            TEXT         NULL DEFAULT NULL,
    `payment_method`    VARCHAR(255) NOT NULL CHECK (`payment_method` IN ('credit_on_us', 'credit_off_us', 'debit_on_us', 'debit_off_us', 'contactless_on_us', 'contactless_off_us')),
    PRIMARY KEY (`issuer_id`, `principle_id`, `emv_tag`, `payment_method`),
    CONSTRAINT `fk_issuer_principles_issuer_id_issuers` FOREIGN KEY (`issuer_id`) REFERENCES `issuers`(`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_issuer_principles_principle_id_principles` FOREIGN KEY (`principle_id`) REFERENCES `principles`(`id`) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS `acquirers` (
    `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `issuer_id`   INT UNSIGNED NOT NULL,
    `code`        VARCHAR(255) NOT NULL,
    `name`        VARCHAR(255) NOT NULL,
    `key`         VARCHAR(255) NOT NULL,
    `created_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`  TIMESTAMP    NULL     DEFAULT NULL,
    `code_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `code`, NULL)) STORED,
    `name_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    `key_active`  VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `key`,  NULL)) STORED,
    INDEX `idx_issuer_id` (`issuer_id`),
    INDEX `idx_code` (`code`),
    INDEX `idx_name` (`name`),
    INDEX `idx_key` (`key`),
    CONSTRAINT `fk_acquirers_issuer_id_issuers` FOREIGN KEY (`issuer_id`) REFERENCES `issuers`(`id`) ON DELETE RESTRICT,
    UNIQUE KEY `uq_acquirers_code_active` (`code_active`),
    UNIQUE KEY `uq_acquirers_issuer_name_active` (`issuer_id`, `name_active`),
    UNIQUE KEY `uq_acquirers_key_active` (`key_active`)
);

CREATE TABLE IF NOT EXISTS `main_features` (
    `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `acquirer_id` INT UNSIGNED NOT NULL,
    `code`        VARCHAR(255) NOT NULL,
    `name`        VARCHAR(255) NOT NULL,
    `key`         VARCHAR(255) NOT NULL,
    `is_active`   BOOLEAN      NOT NULL DEFAULT TRUE,
    `created_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`  TIMESTAMP    NULL     DEFAULT NULL,
    `code_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `code`, NULL)) STORED,
    `name_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    `key_active`  VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `key`,  NULL)) STORED,
    INDEX `idx_code` (`code`),
    INDEX `idx_name` (`name`),
    INDEX `idx_key` (`key`),
    UNIQUE KEY `uq_main_features_code_active` (`code_active`),
    UNIQUE KEY `uq_main_features_acquirer_name_active` (`acquirer_id`, `name_active`),
    UNIQUE KEY `uq_main_features_acquirer_key_active` (`acquirer_id`, `key_active`),
    CONSTRAINT `fk_main_features_acquirer_id_acquirers` FOREIGN KEY (`acquirer_id`) REFERENCES `acquirers`(`id`) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS `tags` (
    `id`         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name`       VARCHAR(255) NOT NULL,
    `created_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` TIMESTAMP    NULL     DEFAULT NULL,
    `name_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    INDEX `idx_name` (`name`),
    UNIQUE KEY `uq_tags_name_active` (`name_active`)
);

CREATE TABLE IF NOT EXISTS `client_main_features` (
    `client_id`       INT UNSIGNED NOT NULL,
    `main_feature_id` INT UNSIGNED NOT NULL,
    `tag_id`          INT UNSIGNED NULL,
    `order`           INT          NOT NULL,
    PRIMARY KEY (`client_id`, `main_feature_id`),
    INDEX `idx_tag_id` (`tag_id`),
    CONSTRAINT `fk_climf_client_id_clients` FOREIGN KEY (`client_id`) REFERENCES `clients`(`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_climf_main_feature_id_main_features` FOREIGN KEY (`main_feature_id`) REFERENCES `main_features`(`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_climf_tag_id_tags` FOREIGN KEY (`tag_id`) REFERENCES `tags`(`id`) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS `support_features` (
    `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `code`        VARCHAR(255) NOT NULL,
    `name`        VARCHAR(255) NOT NULL,
    `key`         VARCHAR(255) NOT NULL,
    `is_active`   BOOLEAN      NOT NULL DEFAULT TRUE,
    `created_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`  TIMESTAMP    NULL     DEFAULT NULL,
    `code_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `code`, NULL)) STORED,
    `name_active` VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `name`, NULL)) STORED,
    `key_active`  VARCHAR(255) GENERATED ALWAYS AS (IF(`deleted_at` IS NULL, `key`,  NULL)) STORED,
    INDEX `idx_code` (`code`),
    INDEX `idx_name` (`name`),
    INDEX `idx_key` (`key`),
    UNIQUE KEY `uq_support_features_code_active` (`code_active`),
    UNIQUE KEY `uq_support_features_name_active` (`name_active`),
    UNIQUE KEY `uq_support_features_key_active` (`key_active`)
);

CREATE TABLE IF NOT EXISTS `client_support_features` (
    `client_id`          INT UNSIGNED NOT NULL,
    `support_feature_id` INT UNSIGNED NOT NULL,
    `order`              INT          NOT NULL,
    PRIMARY KEY (`client_id`, `support_feature_id`),
    CONSTRAINT `fk_clisupf_client_id_clients` FOREIGN KEY (`client_id`) REFERENCES `clients`(`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_clisupf_support_feature_id_support_features` FOREIGN KEY (`support_feature_id`) REFERENCES `support_features`(`id`) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS `profile_acquirers` (
    `profile_id`  INT UNSIGNED NOT NULL,
    `acquirer_id` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`profile_id`, `acquirer_id`),
    CONSTRAINT `fk_profacqu_profile_id_profiles` FOREIGN KEY (`profile_id`) REFERENCES `profiles`(`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_profacqu_acquirer_id_acquirers` FOREIGN KEY (`acquirer_id`) REFERENCES `acquirers`(`id`) ON DELETE RESTRICT
);

COMMIT;