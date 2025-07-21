
START TRANSACTION;

DROP PROCEDURE IF EXISTS `CheckDeletable`;

CREATE PROCEDURE `CheckDeletable`(
    IN `p_parent_table_schema` VARCHAR(64),
    IN `p_parent_table_name` VARCHAR(64),
    IN `p_parent_record_id_value` INT UNSIGNED,
    IN `p_soft_delete_column_name` VARCHAR(64),
    IN `p_ignore_tables` TEXT,
    OUT `p_blocking_dependencies_count` INT
)
SQL SECURITY INVOKER
procedure_main_block: BEGIN
    DECLARE `v_parent_pk_column_name` VARCHAR(64);
    DECLARE `v_dynamic_sql` TEXT;
    DECLARE `v_union_query_part` TEXT;
    
    SET `p_blocking_dependencies_count` = 0;

    IF `p_parent_table_schema` IS NULL
        OR `p_parent_table_name` IS NULL
        OR `p_parent_record_id_value` IS NULL
        OR `p_soft_delete_column_name` IS NULL
    THEN
        SET `p_blocking_dependencies_count` = -1; 
        LEAVE procedure_main_block;
    END IF;

    SELECT
        kcu.COLUMN_NAME INTO `v_parent_pk_column_name`
    FROM
        INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc
    JOIN
        INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu
        ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
        AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA
        AND tc.TABLE_NAME = kcu.TABLE_NAME
    WHERE
        tc.TABLE_SCHEMA = `p_parent_table_schema`
        AND tc.TABLE_NAME = `p_parent_table_name`
        AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
    LIMIT 1;

    IF `v_parent_pk_column_name` IS NULL THEN
        SET `p_blocking_dependencies_count` = -2; 
        LEAVE procedure_main_block;
    END IF;

    SELECT
        GROUP_CONCAT(
            CONCAT(
                'SELECT COUNT(*) AS count_val FROM `',
                child_schema,
                '`.`',
                child_table,
                '` WHERE `',
                child_fk_column,
                '` = ',
                `p_parent_record_id_value`,
                CASE
                    WHEN has_soft_delete_column THEN CONCAT(
                        ' AND `',
                        `p_soft_delete_column_name`,
                        '` IS NULL'
                    )
                    ELSE ''
                END
            ) SEPARATOR ' UNION ALL '
        )
    INTO
        `v_union_query_part`
    FROM (
        SELECT DISTINCT
            kcu.TABLE_SCHEMA AS child_schema,
            kcu.TABLE_NAME AS child_table,
            kcu.COLUMN_NAME AS child_fk_column,
            (
                SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS c
                WHERE
                    c.TABLE_SCHEMA = kcu.TABLE_SCHEMA
                    AND c.TABLE_NAME = kcu.TABLE_NAME
                    AND c.COLUMN_NAME = `p_soft_delete_column_name`
                LIMIT 1
            ) AS has_soft_delete_column
        FROM
            INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
        WHERE
            kcu.REFERENCED_TABLE_SCHEMA = `p_parent_table_schema`
            AND kcu.REFERENCED_TABLE_NAME = `p_parent_table_name`
            AND kcu.REFERENCED_COLUMN_NAME = `v_parent_pk_column_name`
            AND (
                `p_ignore_tables` IS NULL 
                OR `p_ignore_tables` = '' 
                OR FIND_IN_SET(kcu.TABLE_NAME, `p_ignore_tables`) = 0
            )
    ) AS subquery;

    IF `v_union_query_part` IS NOT NULL THEN
        SET `v_dynamic_sql` = CONCAT(
            'SELECT SUM(count_val) INTO @total_count FROM (',
            `v_union_query_part`,
            ') AS final_counts'
        );

        SET @sql = `v_dynamic_sql`;

        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET `p_blocking_dependencies_count` = @total_count;
    END IF;

    IF `p_blocking_dependencies_count` IS NULL THEN
        SET `p_blocking_dependencies_count` = 0;
    END IF;

END;

ALTER TABLE `client_main_features`
  DROP PRIMARY KEY,
  ADD COLUMN `acquirer_id` INT UNSIGNED NOT NULL AFTER `client_id`,
  ADD PRIMARY KEY (`client_id`, `acquirer_id`, `main_feature_id`),
  ADD CONSTRAINT `fk_climf_acquirer_id_acquirers` 
    FOREIGN KEY (`acquirer_id`) REFERENCES `acquirers` (`id`) ON DELETE RESTRICT;

ALTER TABLE `main_features`
  DROP FOREIGN KEY `fk_main_features_acquirer_id_acquirers`,
  DROP INDEX `uq_main_features_acquirer_name_active`,
  DROP INDEX `uq_main_features_acquirer_key_active`,
  DROP COLUMN `acquirer_id`,
  ADD UNIQUE KEY `uq_main_features_name_active` (`name_active`),
  ADD UNIQUE KEY `uq_main_features_key_active` (`key_active`);

DROP TABLE IF EXISTS `issuer_principles`;

CREATE TABLE IF NOT EXISTS `issuer_principles` (
    `issuer_id`         INT UNSIGNED NOT NULL,
    `principle_id`      INT UNSIGNED NOT NULL,
    `debit_onus`        TEXT NULL DEFAULT NULL,
    `debit_offus`       TEXT NULL DEFAULT NULL,
    `credit_onus`       TEXT NULL DEFAULT NULL,
    `credit_offus`      TEXT NULL DEFAULT NULL,
    `contactless_onus`  TEXT NULL DEFAULT NULL,
    `contactless_offus` TEXT NULL DEFAULT NULL,
    PRIMARY KEY (`issuer_id`, `principle_id`),
    CONSTRAINT `fk_issuer_principles_issuer_id_issuers` FOREIGN KEY (`issuer_id`) REFERENCES `issuers`(`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_issuer_principles_principle_id_principles` FOREIGN KEY (`principle_id`) REFERENCES `principles`(`id`) ON DELETE RESTRICT
);

ALTER TABLE `acquirers`
  DROP INDEX `uq_acquirers_key_active`,
  ADD UNIQUE KEY `uq_acquirers_issuer_key_active` (`issuer_id`, `key_active`);

ALTER TABLE `clients` 
  DROP INDEX `uq_clients_company_name_active`,
  ADD CONSTRAINT `uq_clients_company_name_active` UNIQUE (`company_id`, `name_active`);

COMMIT;
