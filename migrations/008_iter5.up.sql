START TRANSACTION;

CREATE TABLE IF NOT EXISTS `aids` (
    `id`                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `principle_id`      INT UNSIGNED  NOT NULL,
    `name`              VARCHAR(255)  NOT NULL,
    `value`             VARCHAR(255)  NOT NULL,
    `tlv`               TEXT          NOT NULL,
    `is_active`         BOOLEAN       NOT NULL DEFAULT TRUE,
    `created_at`        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`        TIMESTAMP     NULL     DEFAULT NULL,
    `tlv_hash_active`   BINARY(32)    GENERATED ALWAYS AS (
                            IF(`deleted_at` IS NULL, UNHEX(SHA2(`tlv`, 256)), NULL)
                        ) STORED,
    INDEX `idx_principle_id` (`principle_id`),
    CONSTRAINT `fk_aids_principle_id_principles`
        FOREIGN KEY (`principle_id`) REFERENCES `principles`(`id`)
        ON DELETE RESTRICT,
    UNIQUE KEY `uq_aids_principle_tlv_hash_active` (`principle_id`, `tlv_hash_active`)
);

CREATE TABLE IF NOT EXISTS `aid_configs` (
    `id`                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `aid_id`            INT UNSIGNED  NOT NULL,
    `name`              VARCHAR(255)  NOT NULL,
    `tag`               VARCHAR(255)  NOT NULL,
    `value`             VARCHAR(255)  NOT NULL,
    `created_at`        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`        TIMESTAMP     NULL     DEFAULT NULL,
    `tag_active`        VARCHAR(255)  GENERATED ALWAYS AS (
                            IF(`deleted_at` IS NULL, `tag`, NULL)
                        ) STORED,
    `value_active`      VARCHAR(255)  GENERATED ALWAYS AS (
                            IF(`deleted_at` IS NULL, `value`, NULL)
                        ) STORED,
    INDEX `idx_aid_id` (`aid_id`),
    CONSTRAINT `fk_aid_configs_aid_id_aids`
        FOREIGN KEY (`aid_id`) REFERENCES `aids`(`id`)
        ON DELETE RESTRICT,
    UNIQUE KEY `uq_aid_configs_aid_tag_active_value_active`
        (`aid_id`, `tag_active`, `value_active`)
);

CREATE TABLE IF NOT EXISTS `capks` (
    `id`                    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `principle_id`          INT UNSIGNED  NOT NULL,
    `index`                 VARCHAR(50)   NOT NULL COMMENT '9F22',
    `modulus`               MEDIUMTEXT    NOT NULL COMMENT 'DF02',
    `exponent`              VARCHAR(50)   NOT NULL COMMENT 'DF04',
    `expiration_date`       VARCHAR(50)   NULL     DEFAULT NULL COMMENT 'DF05',
    `checksum`              VARCHAR(255)  NOT NULL COMMENT 'DF03',
    `algorithm_indicator`   VARCHAR(50)   NOT NULL COMMENT 'DF07',
    `tlv`                   TEXT          NOT NULL,
    `created_at`            TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`            TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`            TIMESTAMP     NULL     DEFAULT NULL,
    `tlv_hash_active`       BINARY(32)    GENERATED ALWAYS AS (
                                IF(`deleted_at` IS NULL, UNHEX(SHA2(`tlv`, 256)), NULL)
                            ) STORED,
    INDEX `idx_principle_id` (`principle_id`),
    CONSTRAINT `fk_capks_principle_id_principles`
        FOREIGN KEY (`principle_id`) REFERENCES `principles`(`id`)
        ON DELETE RESTRICT,
    UNIQUE KEY `uq_capks_principle_tlv_hash_active`
        (`principle_id`, `tlv_hash_active`)
);

COMMIT;
