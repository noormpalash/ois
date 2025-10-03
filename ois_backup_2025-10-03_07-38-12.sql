-- OIS Database Backup
-- Generated on: 2025-10-03 07:38:12
-- Database: operator_info_system

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET time_zone = '+00:00';

-- Table structure for table `admin_login_log`
DROP TABLE IF EXISTS `admin_login_log`;
CREATE TABLE `admin_login_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `success` tinyint(1) NOT NULL DEFAULT 0,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `details` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_username` (`username`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_success` (`success`)
) ENGINE=InnoDB AUTO_INCREMENT=95 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `admin_login_log`
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('55', 'palash', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-01 20:33:57');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('56', 'palash', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-01 20:40:31');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('57', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-01 20:41:28');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('58', 'palash', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15', 'Login successful', '2025-10-01 23:15:51');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('59', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-02 09:23:32');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('60', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-02 09:40:00');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('61', 'palash', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15', 'Login successful', '2025-10-02 19:42:46');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('62', 'Staff', '0', '192.168.141.120', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36', 'Invalid password', '2025-10-02 19:43:00');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('63', 'staff', '0', '192.168.141.120', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36', 'Invalid password', '2025-10-02 19:43:08');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('64', 'staff', '1', '192.168.141.120', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36', 'Login successful', '2025-10-02 19:43:29');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('65', 'admin', '1', '192.168.141.120', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36', 'Login successful', '2025-10-02 19:44:24');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('66', 'staff', '1', '192.168.141.216', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-02 20:00:40');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('67', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-02 21:08:58');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('68', 'admin', '1', '10.183.40.213', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36', 'Login successful', '2025-10-02 21:27:46');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('69', 'palash', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-02 21:28:02');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('70', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 09:28:43');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('71', 'palash', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15', 'Login successful', '2025-10-03 10:15:12');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('72', 'palash', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 10:21:36');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('73', 'admin', '0', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Invalid password', '2025-10-03 10:26:46');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('74', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 10:26:51');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('75', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 10:28:10');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('76', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 10:35:27');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('77', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 10:35:49');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('78', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 10:36:14');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('79', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 10:37:03');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('80', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 10:38:49');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('81', 'palash', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15', 'Login successful', '2025-10-03 10:39:50');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('82', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15', 'Login successful', '2025-10-03 10:40:11');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('83', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15', 'Login successful', '2025-10-03 10:40:29');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('84', 'palash', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15', 'Login successful', '2025-10-03 10:40:51');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('85', 'palash', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15', 'Login successful', '2025-10-03 10:42:14');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('86', 'admin', '0', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Invalid password', '2025-10-03 10:42:41');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('87', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 10:42:45');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('88', 'palash', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 10:43:43');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('89', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 10:45:50');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('90', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 10:46:12');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('91', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 10:48:04');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('92', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15', 'Login successful', '2025-10-03 10:48:41');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('93', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15', 'Login successful', '2025-10-03 10:49:00');
INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES ('94', 'admin', '1', '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'Login successful', '2025-10-03 10:50:02');

-- Table structure for table `admin_users`
DROP TABLE IF EXISTS `admin_users`;
CREATE TABLE `admin_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `role` enum('super_admin','admin','add_op') DEFAULT 'admin',
  `status` enum('active','inactive') DEFAULT 'active',
  `email` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_login` timestamp NULL DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `fk_admin_created_by` (`created_by`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `admin_users`

-- Table structure for table `animation_settings`
DROP TABLE IF EXISTS `animation_settings`;
CREATE TABLE `animation_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_name` varchar(100) NOT NULL,
  `setting_value` tinyint(1) NOT NULL DEFAULT 1,
  `description` varchar(255) DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_name` (`setting_name`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `animation_settings`
INSERT INTO `animation_settings` (`id`, `setting_name`, `setting_value`, `description`, `updated_by`, `updated_at`, `created_at`) VALUES ('8', 'hero_animations', '0', 'Enable/disable hero section animations (logo rotation, gradient effects)', 'admin', '2025-10-03 11:38:00', '2025-10-03 11:33:05');
INSERT INTO `animation_settings` (`id`, `setting_name`, `setting_value`, `description`, `updated_by`, `updated_at`, `created_at`) VALUES ('9', 'drone_animations', '0', 'Enable/disable military drone animation with scanning effects and operator info display', 'admin', '2025-10-03 11:38:00', '2025-10-03 11:36:29');

-- Table structure for table `cores`
DROP TABLE IF EXISTS `cores`;
CREATE TABLE `cores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `cores`
INSERT INTO `cores` (`id`, `name`) VALUES ('8', 'ASC');
INSERT INTO `cores` (`id`, `name`) VALUES ('14', 'EME');
INSERT INTO `cores` (`id`, `name`) VALUES ('5', 'Engineers');
INSERT INTO `cores` (`id`, `name`) VALUES ('9', 'Infantry (BIR)');
INSERT INTO `cores` (`id`, `name`) VALUES ('1', 'Infantry (EB)');
INSERT INTO `cores` (`id`, `name`) VALUES ('12', 'Ordnance');
INSERT INTO `cores` (`id`, `name`) VALUES ('6', 'Signals');

-- Table structure for table `exercises`
DROP TABLE IF EXISTS `exercises`;
CREATE TABLE `exercises` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `exercises`
INSERT INTO `exercises` (`id`, `name`) VALUES ('4', 'SP');

-- Table structure for table `formations`
DROP TABLE IF EXISTS `formations`;
CREATE TABLE `formations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `formations`
INSERT INTO `formations` (`id`, `name`) VALUES ('21', '14 Indep ENGR Bde');
INSERT INTO `formations` (`id`, `name`) VALUES ('15', '15 Indep ARMR SQN');
INSERT INTO `formations` (`id`, `name`) VALUES ('26', '17  Inf Div');
INSERT INTO `formations` (`id`, `name`) VALUES ('5', '17 Inf Div');
INSERT INTO `formations` (`id`, `name`) VALUES ('3', '19 Inf Div');
INSERT INTO `formations` (`id`, `name`) VALUES ('16', '24 ENGR Construction Bde');
INSERT INTO `formations` (`id`, `name`) VALUES ('7', '24 Inf Div');
INSERT INTO `formations` (`id`, `name`) VALUES ('8', '33 Inf Div');
INSERT INTO `formations` (`id`, `name`) VALUES ('13', '34 ENGR Construction Bde');
INSERT INTO `formations` (`id`, `name`) VALUES ('12', '46 Indep Inf Bde');
INSERT INTO `formations` (`id`, `name`) VALUES ('9', '55 Inf Div');
INSERT INTO `formations` (`id`, `name`) VALUES ('17', '6 AD Bde');
INSERT INTO `formations` (`id`, `name`) VALUES ('10', '66 Inf Div');
INSERT INTO `formations` (`id`, `name`) VALUES ('25', '7  AD Bde');
INSERT INTO `formations` (`id`, `name`) VALUES ('18', '7 AD Bde');
INSERT INTO `formations` (`id`, `name`) VALUES ('6', '7 Inf Div');
INSERT INTO `formations` (`id`, `name`) VALUES ('14', '86 Indep Sig Bde');
INSERT INTO `formations` (`id`, `name`) VALUES ('4', '9 Inf Div');
INSERT INTO `formations` (`id`, `name`) VALUES ('22', '99 Composite Bde');
INSERT INTO `formations` (`id`, `name`) VALUES ('19', 'ARTDOC');
INSERT INTO `formations` (`id`, `name`) VALUES ('11', 'Log Area');
INSERT INTO `formations` (`id`, `name`) VALUES ('23', 'Para Cdo Bde');

-- Table structure for table `med_categories`
DROP TABLE IF EXISTS `med_categories`;
CREATE TABLE `med_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `med_categories`

-- Table structure for table `operator_exercises`
DROP TABLE IF EXISTS `operator_exercises`;
CREATE TABLE `operator_exercises` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `operator_id` int(11) NOT NULL,
  `exercise_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_operator_exercise` (`operator_id`,`exercise_id`),
  KEY `exercise_id` (`exercise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `operator_exercises`
INSERT INTO `operator_exercises` (`id`, `operator_id`, `exercise_id`, `created_at`) VALUES ('31', '22', '1', '2025-09-29 22:59:30');
INSERT INTO `operator_exercises` (`id`, `operator_id`, `exercise_id`, `created_at`) VALUES ('32', '22', '2', '2025-09-29 22:59:30');
INSERT INTO `operator_exercises` (`id`, `operator_id`, `exercise_id`, `created_at`) VALUES ('33', '22', '4', '2025-09-29 22:59:30');
INSERT INTO `operator_exercises` (`id`, `operator_id`, `exercise_id`, `created_at`) VALUES ('34', '435', '1', '2025-10-01 23:20:29');
INSERT INTO `operator_exercises` (`id`, `operator_id`, `exercise_id`, `created_at`) VALUES ('35', '1842', '3', '2025-10-03 10:21:09');

-- Table structure for table `operator_special_notes`
DROP TABLE IF EXISTS `operator_special_notes`;
CREATE TABLE `operator_special_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `operator_id` int(11) NOT NULL,
  `special_note_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `operator_special_notes`
INSERT INTO `operator_special_notes` (`id`, `operator_id`, `special_note_id`, `created_at`) VALUES ('26', '323', '8', '2025-10-01 13:13:54');
INSERT INTO `operator_special_notes` (`id`, `operator_id`, `special_note_id`, `created_at`) VALUES ('27', '434', '8', '2025-10-01 20:21:03');
INSERT INTO `operator_special_notes` (`id`, `operator_id`, `special_note_id`, `created_at`) VALUES ('28', '433', '2', '2025-10-01 23:16:59');
INSERT INTO `operator_special_notes` (`id`, `operator_id`, `special_note_id`, `created_at`) VALUES ('29', '432', '10', '2025-10-01 23:17:21');
INSERT INTO `operator_special_notes` (`id`, `operator_id`, `special_note_id`, `created_at`) VALUES ('30', '435', '4', '2025-10-01 23:20:29');

-- Table structure for table `operators`
DROP TABLE IF EXISTS `operators`;
CREATE TABLE `operators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `personal_no` varchar(50) NOT NULL,
  `rank` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `cores_id` int(11) DEFAULT NULL,
  `unit_id` int(11) DEFAULT NULL,
  `course_cadre_name` varchar(100) DEFAULT NULL,
  `formation_id` int(11) DEFAULT NULL,
  `permanent_address` text DEFAULT NULL,
  `present_address` text DEFAULT NULL,
  `admission_date` date DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `joining_date_awgc` date DEFAULT NULL,
  `worked_in_awgc` text DEFAULT NULL,
  `med_category_id` int(11) DEFAULT NULL,
  `civil_edu` varchar(200) DEFAULT NULL,
  `course` varchar(100) DEFAULT NULL,
  `cadre` varchar(100) DEFAULT NULL,
  `expertise_area` text DEFAULT NULL,
  `punishment` text DEFAULT NULL,
  `special_note` varchar(255) DEFAULT NULL,
  `mobile_personal` varchar(20) DEFAULT NULL,
  `mobile_family` varchar(20) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `exercise_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_no` (`personal_no`),
  KEY `cores_id` (`cores_id`),
  KEY `unit_id` (`unit_id`),
  KEY `formation_id` (`formation_id`),
  KEY `med_category_id` (`med_category_id`),
  KEY `fk_operators_exercise` (`exercise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2268 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `operators`

-- Table structure for table `ranks`
DROP TABLE IF EXISTS `ranks`;
CREATE TABLE `ranks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `ranks`
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('10', 'Sgt', '2025-10-01 20:16:55');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('11', 'WO', '2025-10-01 20:17:03');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('33', 'LCpl (GNR)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('34', 'Snk (OCU)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('35', 'Snk (GNR)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('36', 'Snk (SMS)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('37', 'LCpl (RCT)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('38', 'LCpl (OP)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('39', 'Cpl (OCU)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('40', 'Cpl (GNR)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('41', 'LCpl (TA)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('42', 'Cpl (OP)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('43', 'Snk (WSS)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('44', 'Snk (MT)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('45', 'LCpl (DVR)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('46', 'LCpl (OCU)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('47', 'Snk (M DVR)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('48', 'Sgt (OP)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('49', 'Snk (OP)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('50', 'Snk (SMT)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('51', 'Snk (DVR)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('52', 'Snk (TA)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('53', 'Snk (DMT)', '2025-10-03 09:53:19');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('54', 'Snk (CLK)', '2025-10-03 11:18:26');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('55', 'Snk (OPR)', '2025-10-03 11:18:26');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('56', 'Snk (Tech)', '2025-10-03 11:18:26');
INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES ('57', 'Cpl (Crypto)', '2025-10-03 11:18:26');

-- Table structure for table `special_notes`
DROP TABLE IF EXISTS `special_notes`;
CREATE TABLE `special_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `color` varchar(7) DEFAULT '#ff4757',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `special_notes`
INSERT INTO `special_notes` (`id`, `name`, `description`, `color`, `created_at`, `updated_at`) VALUES ('8', 'AWGC Prohibited', NULL, '#ff4757', '2025-09-27 11:25:38', '2025-09-27 11:25:38');
INSERT INTO `special_notes` (`id`, `name`, `description`, `color`, `created_at`, `updated_at`) VALUES ('9', 'Trg NCO', NULL, '#ff4757', '2025-09-27 21:31:00', '2025-09-27 21:31:00');
INSERT INTO `special_notes` (`id`, `name`, `description`, `color`, `created_at`, `updated_at`) VALUES ('10', 'Died', NULL, '#ff4757', '2025-10-01 20:35:06', '2025-10-01 20:35:06');

-- Table structure for table `units`
DROP TABLE IF EXISTS `units`;
CREATE TABLE `units` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=202 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `units`
INSERT INTO `units` (`id`, `name`) VALUES ('10', '8 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('11', '17 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('12', '18 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('13', '42 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('14', '12 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('15', '15 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('16', '20 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('17', '40 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('18', '29 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('19', '57 Engr Br');
INSERT INTO `units` (`id`, `name`) VALUES ('20', '34 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('21', '8 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('22', '46 Loc Bty');
INSERT INTO `units` (`id`, `name`) VALUES ('23', '44 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('24', '6 Cavalory');
INSERT INTO `units` (`id`, `name`) VALUES ('25', '9 Bengal Lancher');
INSERT INTO `units` (`id`, `name`) VALUES ('26', '21 AD');
INSERT INTO `units` (`id`, `name`) VALUES ('27', '5 AD');
INSERT INTO `units` (`id`, `name`) VALUES ('28', '39 Div Locating Bty');
INSERT INTO `units` (`id`, `name`) VALUES ('29', '14 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('30', '27 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('31', '35 Div Locating Bty');
INSERT INTO `units` (`id`, `name`) VALUES ('32', '6 ENGR BN');
INSERT INTO `units` (`id`, `name`) VALUES ('33', '3 ENGR BN');
INSERT INTO `units` (`id`, `name`) VALUES ('34', '59 EB (SP BN)');
INSERT INTO `units` (`id`, `name`) VALUES ('35', '29 EB (SP BN)');
INSERT INTO `units` (`id`, `name`) VALUES ('36', '62 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('37', '11 SP Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('38', '7 RE BN');
INSERT INTO `units` (`id`, `name`) VALUES ('39', '8 ENGR BN');
INSERT INTO `units` (`id`, `name`) VALUES ('40', '9 ENGR BN');
INSERT INTO `units` (`id`, `name`) VALUES ('41', '16 ECB');
INSERT INTO `units` (`id`, `name`) VALUES ('42', '17 ECB');
INSERT INTO `units` (`id`, `name`) VALUES ('43', '6 Sig BN');
INSERT INTO `units` (`id`, `name`) VALUES ('44', '4 Sig BN');
INSERT INTO `units` (`id`, `name`) VALUES ('45', '3 Sig BN');
INSERT INTO `units` (`id`, `name`) VALUES ('46', '43 SHORAD Missile Reg');
INSERT INTO `units` (`id`, `name`) VALUES ('47', '44 SHORAD Missile Reg');
INSERT INTO `units` (`id`, `name`) VALUES ('48', '38 AD');
INSERT INTO `units` (`id`, `name`) VALUES ('49', '36 ST BN');
INSERT INTO `units` (`id`, `name`) VALUES ('50', '37 ST BN');
INSERT INTO `units` (`id`, `name`) VALUES ('51', '1 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('52', '2 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('53', '26 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('54', '34 EB (Mech)');
INSERT INTO `units` (`id`, `name`) VALUES ('55', '56 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('56', '57 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('57', '61 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('58', '63 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('59', '64 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('60', '65 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('61', '66 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('62', '67 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('63', '79 EB (SP BN)');
INSERT INTO `units` (`id`, `name`) VALUES ('64', '3 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('65', '4 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('66', '16 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('67', '20 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('68', '23 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('69', '24 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('70', '27 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('71', '28 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('72', '29 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('73', '30 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('74', '32 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('75', '35 BIR (SP BN)');
INSERT INTO `units` (`id`, `name`) VALUES ('76', '42 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('77', '43 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('78', '510 DOC');
INSERT INTO `units` (`id`, `name`) VALUES ('79', '26 Horse');
INSERT INTO `units` (`id`, `name`) VALUES ('80', '2 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('81', '4 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('82', '19 Med Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('83', '41 Med Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('84', '46 Div Locating Bty');
INSERT INTO `units` (`id`, `name`) VALUES ('85', '22 ENGR BN');
INSERT INTO `units` (`id`, `name`) VALUES ('86', '16 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('87', '3 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('88', '6 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('89', '18 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('90', '24 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('91', '25 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('92', '21 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('93', '12 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('94', '10 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('95', '33 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('96', '22 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('97', '17 BIR (Mech)');
INSERT INTO `units` (`id`, `name`) VALUES ('98', '31 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('99', '25 BIR (SP BN)');
INSERT INTO `units` (`id`, `name`) VALUES ('100', '26 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('101', '8 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('102', 'ORDEP Jashore');
INSERT INTO `units` (`id`, `name`) VALUES ('103', 'CMTD');
INSERT INTO `units` (`id`, `name`) VALUES ('104', '4 Horse');
INSERT INTO `units` (`id`, `name`) VALUES ('105', '1 ENGR BN');
INSERT INTO `units` (`id`, `name`) VALUES ('106', '8 Sig Bn');
INSERT INTO `units` (`id`, `name`) VALUES ('107', '32 ST BN');
INSERT INTO `units` (`id`, `name`) VALUES ('108', '19 EB (SP BN)');
INSERT INTO `units` (`id`, `name`) VALUES ('109', '27 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('110', '58 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('111', '60 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('112', '7 Horse');
INSERT INTO `units` (`id`, `name`) VALUES ('113', '7 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('114', '10 Med Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('115', '22 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('116', '49 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('117', '1 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('118', '2 ENGR BN');
INSERT INTO `units` (`id`, `name`) VALUES ('119', '5 Sig Bn');
INSERT INTO `units` (`id`, `name`) VALUES ('120', '9 Sig Bn');
INSERT INTO `units` (`id`, `name`) VALUES ('121', 'COD, Dhaka');
INSERT INTO `units` (`id`, `name`) VALUES ('122', '7 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('123', '9 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('124', '11 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('125', '14 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('126', '15 EB (Mech)');
INSERT INTO `units` (`id`, `name`) VALUES ('127', '17 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('128', '28 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('129', '20 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('130', '23 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('131', '37 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('132', '36 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('133', '38 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('134', '39 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('135', '41 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('136', 'Bengal Cavalory');
INSERT INTO `units` (`id`, `name`) VALUES ('137', '29 Div Locating Bty');
INSERT INTO `units` (`id`, `name`) VALUES ('138', '32 Med Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('139', '47 Mor Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('140', '45 MLRS Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('141', '4 ENGR BN');
INSERT INTO `units` (`id`, `name`) VALUES ('142', '11 Sig BN');
INSERT INTO `units` (`id`, `name`) VALUES ('143', '57 AD');
INSERT INTO `units` (`id`, `name`) VALUES ('144', '34 ST BN');
INSERT INTO `units` (`id`, `name`) VALUES ('145', '4 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('146', '15 BIR (SP BN)');
INSERT INTO `units` (`id`, `name`) VALUES ('147', '2 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('148', '9 BIR (Mech)');
INSERT INTO `units` (`id`, `name`) VALUES ('149', '11 BIR (Mech)');
INSERT INTO `units` (`id`, `name`) VALUES ('150', '12 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('151', '13 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('152', '14 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('153', '18 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('154', '19 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('155', '21 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('156', '1 Para Commando BN');
INSERT INTO `units` (`id`, `name`) VALUES ('157', '50 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('158', '52 Indep MLRS Bty');
INSERT INTO `units` (`id`, `name`) VALUES ('159', '18 ENGR BN');
INSERT INTO `units` (`id`, `name`) VALUES ('160', '21 ENGR BN');
INSERT INTO `units` (`id`, `name`) VALUES ('161', '1 Sig BN');
INSERT INTO `units` (`id`, `name`) VALUES ('162', '36 AD');
INSERT INTO `units` (`id`, `name`) VALUES ('163', '30 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('164', '32 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('165', '36 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('166', '38 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('167', '1 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('168', '5 BIR (SP BN)');
INSERT INTO `units` (`id`, `name`) VALUES ('169', '6 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('170', '7 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('171', '8 BIR`');
INSERT INTO `units` (`id`, `name`) VALUES ('172', '10 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('173', '40 BIR');
INSERT INTO `units` (`id`, `name`) VALUES ('174', 'CAD');
INSERT INTO `units` (`id`, `name`) VALUES ('175', '3 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('176', '2 Sig BN');
INSERT INTO `units` (`id`, `name`) VALUES ('177', '35 ST BN');
INSERT INTO `units` (`id`, `name`) VALUES ('178', '38 ST BN');
INSERT INTO `units` (`id`, `name`) VALUES ('179', '504 DOC');
INSERT INTO `units` (`id`, `name`) VALUES ('180', '41 Medium Arty Wrksp Sec EME');
INSERT INTO `units` (`id`, `name`) VALUES ('181', '12 Lancher Wrksp Sec EME');
INSERT INTO `units` (`id`, `name`) VALUES ('182', '7 Sig BN');
INSERT INTO `units` (`id`, `name`) VALUES ('183', '39 ST BN');
INSERT INTO `units` (`id`, `name`) VALUES ('184', '30 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('185', '9 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('186', '26 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('187', '25 AD Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('188', '56 Indep Med AD Bty');
INSERT INTO `units` (`id`, `name`) VALUES ('189', '12 ENGR BN');
INSERT INTO `units` (`id`, `name`) VALUES ('190', '11 RE BN');
INSERT INTO `units` (`id`, `name`) VALUES ('191', 'Army Static Sig BN');
INSERT INTO `units` (`id`, `name`) VALUES ('192', '505 DOC');
INSERT INTO `units` (`id`, `name`) VALUES ('193', '28 Med Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('194', '23 Fd Reg Arty');
INSERT INTO `units` (`id`, `name`) VALUES ('195', '57 ENGR COY');
INSERT INTO `units` (`id`, `name`) VALUES ('196', '5 RE BN');
INSERT INTO `units` (`id`, `name`) VALUES ('197', '10 Sig BN');
INSERT INTO `units` (`id`, `name`) VALUES ('198', '40 EB (Mech)');
INSERT INTO `units` (`id`, `name`) VALUES ('199', '13 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('200', '5 EB');
INSERT INTO `units` (`id`, `name`) VALUES ('201', 'Army ST BN');

SET FOREIGN_KEY_CHECKS = 1;
