DROP PROCEDURE IF EXISTS `CheckDeletable`;

CREATE PROCEDURE `CheckDeletable`(
    IN `p_parent_table_schema` VARCHAR(64),
    IN `p_parent_table_name` VARCHAR(64),
    IN `p_parent_record_id_list` TEXT, 
    IN `p_soft_delete_column_name` VARCHAR(64),
    IN `p_ignore_tables` TEXT 
)
SQL SECURITY INVOKER
procedure_main_block: BEGIN
    DECLARE `v_parent_pk_column_name` VARCHAR(64);
    DECLARE `v_dynamic_sql` TEXT;
    DECLARE `v_union_query_part` TEXT;

    IF `p_parent_table_schema` IS NULL
        OR `p_parent_table_name` IS NULL
        OR `p_parent_record_id_list` IS NULL OR `p_parent_record_id_list` = ''
        OR `p_soft_delete_column_name` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid or missing input parameters.';
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Primary key not found for the specified parent table.';
        LEAVE procedure_main_block;
    END IF;

    SELECT
        GROUP_CONCAT(
            CONCAT(
                'SELECT `',
                child_fk_column,
                '` AS parent_id, COUNT(*) AS dependency_count FROM `',
                child_schema,
                '`.`',
                child_table,
                '` WHERE `',
                child_fk_column,
                '` IN (',
                `p_parent_record_id_list`,
                ')',
                
                CASE
                    WHEN has_soft_delete_column THEN CONCAT(
                        ' AND `',
                        `p_soft_delete_column_name`,
                        '` IS NULL'
                    )
                    ELSE ''
                END,
                ' GROUP BY `',
                child_fk_column, '`'
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

    IF `v_union_query_part` IS NOT NULL AND `v_union_query_part` != '' THEN
        SET `v_dynamic_sql` = CONCAT(
            'SELECT parent_id, SUM(dependency_count) AS total_dependencies FROM (',
            `v_union_query_part`,
            ') AS final_counts GROUP BY parent_id'
        ); 
        SET @sql = `v_dynamic_sql`;

        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    ELSE
        SELECT NULL AS parent_id, NULL AS total_dependencies LIMIT 0;
    END IF;

END;
