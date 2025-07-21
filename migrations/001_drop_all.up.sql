START TRANSACTION;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `client_main_features`;
DROP TABLE IF EXISTS `client_support_features`;
DROP TABLE IF EXISTS `profile_acquirers`;
DROP TABLE IF EXISTS `role_permissions`;
DROP TABLE IF EXISTS `issuer_principles`;
DROP TABLE IF EXISTS `user_roles`;
DROP TABLE IF EXISTS `stocks`;
DROP TABLE IF EXISTS `merchants`;
DROP TABLE IF EXISTS `bins`;
DROP TABLE IF EXISTS `roles`;
DROP TABLE IF EXISTS `acquirers`;
DROP TABLE IF EXISTS `clients`;
DROP TABLE IF EXISTS `main_features`;
DROP TABLE IF EXISTS `support_features`;
DROP TABLE IF EXISTS `tags`;
DROP TABLE IF EXISTS `permissions`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `groups`;
DROP TABLE IF EXISTS `principles`;
DROP TABLE IF EXISTS `profiles`;
DROP TABLE IF EXISTS `villages`;
DROP TABLE IF EXISTS `districts`;
DROP TABLE IF EXISTS `issuers`;
DROP TABLE IF EXISTS `companies`;
DROP TABLE IF EXISTS `cities`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `provinces`;
DROP TABLE IF EXISTS `endpoints`;
DROP TABLE IF EXISTS `emv_tags`;

DROP TABLE IF EXISTS `user_accounts`;
DROP TABLE IF EXISTS `master_role_accesses`;
DROP TABLE IF EXISTS `master_roles`;
DROP TABLE IF EXISTS `master_forms`;
DROP TABLE IF EXISTS `profile_bin_ranges`;
DROP TABLE IF EXISTS `master_principles`;
DROP TABLE IF EXISTS `master_merchants`;
DROP TABLE IF EXISTS `master_groups`;
DROP TABLE IF EXISTS `master_clients`;
DROP TABLE IF EXISTS `stock_lists`;
DROP TABLE IF EXISTS `stock_types`;
DROP TABLE IF EXISTS `master_companies`;
DROP TABLE IF EXISTS `aids`;
DROP TABLE IF EXISTS `aid_configs`;
DROP TABLE IF EXISTS `capks`;

DROP PROCEDURE IF EXISTS `CheckDeletable`;

SET FOREIGN_KEY_CHECKS = 1;

COMMIT;