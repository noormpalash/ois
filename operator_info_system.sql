-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Oct 05, 2025 at 03:39 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `operator_info_system`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin_login_log`
--

CREATE TABLE `admin_login_log` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `success` tinyint(1) NOT NULL DEFAULT 0,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `details` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin_login_log`
--

INSERT INTO `admin_login_log` (`id`, `username`, `success`, `ip_address`, `user_agent`, `details`, `created_at`) VALUES
(106, 'superadmin', 1, '::1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15', 'Cleared 50 login log entries (type: all)', '2025-10-04 14:23:29');

-- --------------------------------------------------------

--
-- Table structure for table `admin_users`
--

CREATE TABLE `admin_users` (
  `id` int(11) NOT NULL,
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
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin_users`
--

INSERT INTO `admin_users` (`id`, `username`, `password`, `full_name`, `role`, `status`, `email`, `is_active`, `created_at`, `updated_at`, `last_login`, `created_by`) VALUES
(9, 'admin', '$2y$10$Dlv/xCJ6spES.ul7p9TIv.BQRhLRmPTokTniPybpLem8kxR758K3C', 'System Administrator', 'admin', 'active', 'admin@ois.net', 1, '2025-10-04 06:28:15', '2025-10-04 14:10:07', '2025-10-04 14:10:07', NULL),
(10, 'superadmin', '$2y$10$Ek6N.obGNyQmbg9e7GQxGuQjxbESWc/uwfx/.oJkHWXt2oR3aOuxm', 'Noor M Palash', 'super_admin', 'active', 'superadmin@ois.net', 1, '2025-10-04 06:29:36', '2025-10-04 14:22:43', '2025-10-04 14:22:43', 9),
(11, 'staff', '$2y$10$wvz9H8eVWZxa100l6u3ikuTOSlwKqV7IRoahcWDD8Ei0lt.VJi29q', 'Staff', 'add_op', 'active', 'staff@ois.net', 1, '2025-10-04 06:30:27', '2025-10-04 14:09:14', '2025-10-04 14:09:14', 9);

-- --------------------------------------------------------

--
-- Table structure for table `animation_settings`
--

CREATE TABLE `animation_settings` (
  `id` int(11) NOT NULL,
  `setting_name` varchar(100) NOT NULL,
  `setting_value` tinyint(1) NOT NULL DEFAULT 1,
  `description` varchar(255) DEFAULT NULL,
  `updated_by` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `animation_settings`
--

INSERT INTO `animation_settings` (`id`, `setting_name`, `setting_value`, `description`, `updated_by`, `updated_at`, `created_at`) VALUES
(9, 'drone_animations', 0, 'Enable/disable military drone animation with scanning effects and operator info display', 'superadmin', '2025-10-04 14:26:33', '2025-10-03 05:36:29'),
(10, 'hero_animations', 0, 'Enable/disable hero section animations (logo rotation, gradient effects)', 'superadmin', '2025-10-04 14:24:48', '2025-10-03 05:45:04');

-- --------------------------------------------------------

--
-- Table structure for table `cores`
--

CREATE TABLE `cores` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cores`
--

INSERT INTO `cores` (`id`, `name`) VALUES
(19, 'Air Defence'),
(17, 'Armoured'),
(18, 'Artillery'),
(20, 'ASC'),
(14, 'EME'),
(5, 'Engineers'),
(9, 'Infantry (BIR)'),
(1, 'Infantry (EB)'),
(12, 'Ordnance'),
(6, 'Signals');

-- --------------------------------------------------------

--
-- Table structure for table `exercises`
--

CREATE TABLE `exercises` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `exercises`
--

INSERT INTO `exercises` (`id`, `name`) VALUES
(11, 'AC&S'),
(12, 'ACC&S'),
(10, 'DG'),
(9, 'MC'),
(8, 'SP');

-- --------------------------------------------------------

--
-- Table structure for table `formations`
--

CREATE TABLE `formations` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `formations`
--

INSERT INTO `formations` (`id`, `name`) VALUES
(29, '10  Inf Div'),
(27, '10 Inf Div'),
(28, '11 Inf Div'),
(30, '14 Indep ENGR Bde'),
(15, '15 Indep ARMR SQN'),
(26, '17  Inf Div'),
(5, '17 Inf Div'),
(3, '19 Inf Div'),
(16, '24 ENGR Construction Bde'),
(7, '24 Inf Div'),
(8, '33 Inf Div'),
(13, '34 ENGR Construction Bde'),
(12, '46 Indep Inf Bde'),
(9, '55 Inf Div'),
(17, '6 AD Bde'),
(10, '66 Inf Div'),
(25, '7  AD Bde'),
(18, '7 AD Bde'),
(6, '7 Inf Div'),
(14, '86 Indep Sig Bde'),
(4, '9 Inf Div'),
(22, '99 Composite Bde'),
(19, 'ARTDOC'),
(11, 'Log Area'),
(23, 'Para Cdo Bde');

-- --------------------------------------------------------

--
-- Table structure for table `med_categories`
--

CREATE TABLE `med_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `med_categories`
--

INSERT INTO `med_categories` (`id`, `name`) VALUES
(6, 'A'),
(7, 'C');

-- --------------------------------------------------------

--
-- Table structure for table `operators`
--

CREATE TABLE `operators` (
  `id` int(11) NOT NULL,
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
  `exercise_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `operators`
--

INSERT INTO `operators` (`id`, `personal_no`, `rank`, `name`, `cores_id`, `unit_id`, `course_cadre_name`, `formation_id`, `permanent_address`, `present_address`, `admission_date`, `birth_date`, `joining_date_awgc`, `worked_in_awgc`, `med_category_id`, `civil_edu`, `course`, `cadre`, `expertise_area`, `punishment`, `special_note`, `mobile_personal`, `mobile_family`, `created_at`, `updated_at`, `exercise_id`) VALUES
(2552, '1006089', 'LCpl (GNR)', 'Md Shahinur Rahaman', 17, 24, 'Trg On AWGSS-5', 8, 'Vill:Par Khukrali, PO: Satkhira, Thana:Satkhira, District:Satkhira', '6 Cavalory', '2006-07-09', '1989-01-08', '2019-02-22', 'no', 6, 'SSC', '', 'GPS Cadre, Marksmanship Cadre', '', 'no', '', '01728-658552', '01719-135959', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2553, '1005745', 'LCpl', 'Md Khandaker Abul Kalam Azad', 17, 25, 'Trg On AWGSS-5', 4, 'Vill: Adarshopara, PO:Charkashan, Thana:Charkashan, District:Bhola', '9 Bengal Lancher', '2004-11-06', '1985-10-25', '2019-02-22', 'no', 6, 'BA', '', 'ORBIC Cadre', '', 'no', '', '01719-779037', '01788-37607', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2554, '1007062', 'Snk', 'Md Shahin Alom', 17, 112, 'Trg On AWGSS-5', 3, 'Vill: Joldhaka,  PO: Joldhaka, Thana:Joldhaka, District: Nilphamari', '7 Horse', '2013-07-14', '1995-06-01', '2019-02-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01764-957943', '01744-951955', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2555, '1234214', 'Snk (OCU)', 'Md Abu Sayed', 18, 28, 'Trg On AWGSS-5', 8, 'Vill:Masilia,  PO: Boroichora, Thana: Khogsa, District:Khustia', '39 Div Locating Bty', '2012-07-08', '1994-10-25', '2019-02-23', 'no', 6, 'SSC', '', '', '', 'no', '', '01749-246306', '01737-722474', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2556, '1235502', 'Snk (GNR)', 'Sumon Hawlader', 18, 29, 'Trg On AWGSS-5', 7, 'Vill:Boilchori,  PO: K B Bazar , Thana: Bashkhali, District:Chittagong', '14 Fd Reg Arty', '2015-01-24', '1995-05-12', '2019-02-23', 'no', 6, 'BA', '', '', '', 'no', '', '01731-856756', '01738-185638', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2557, '1237774', 'Snk (OCU)', 'Razu Ahmed', 18, 30, 'Trg On AWGSS-5', 27, 'Vill:Chandipur,  PO:Chandipur, Thana: Manirampur, District: Jashore', '27 Fd Reg Arty', '2017-01-20', '1997-12-20', '2019-02-24', 'no', 6, 'SSC', '', '', '', 'no', '', '01772-994385', '01764-693215', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2558, '1237575', 'Snk', 'Md Jahid  Hasan Khan', 18, 31, 'Trg On AWGSS-5', 28, 'Vill: Charshonia,  PO: Sahebarhat , Thana: Barisal Sodor, District: Barisal', '35 Div Locating Bty', '2017-01-11', '1998-12-10', '2019-02-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01719-353318', '01728-950681', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2559, '1451525', 'Snk', 'Sajjad Chawdhory', 5, 33, 'Trg On AWGSS-5', 4, 'Vill: BoilChori,  PO: KB Bazar , Thana: Bashkhali, District: Chittagong', '3 ENGR BN', '2016-01-24', '1997-11-21', '2019-02-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01817-749347', '01826-659528', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2560, '1451628', 'Snk', 'Md Senajul Haque', 5, 32, 'Trg On AWGSS-5', 27, 'Vill: Chongpur,  PO: Kolmakanda , Thana: Kolmakanda, District: Netrokona', '6 ENGR BN', '2016-01-24', '1997-02-10', '2019-02-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01729-679327', '01716-106270', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2561, '1616039', 'Snk', 'Md Saidur Rahman', 6, 176, 'Trg On AWGSS-5', 10, 'Vill: Tribani,  PO: Mul Tribani , Thana: Shoilakupa, District:Jhenaidah', '2 Sig BN', '2006-07-09', '1988-04-25', '2019-02-23', 'no', 6, 'HSC', '', '', '', 'no', '', '01791-936994', '01710-673717', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2562, '1618540', 'Snk', 'Bashir Uddin', 6, 44, 'Trg On AWGSS-5', 28, 'Vill:Baherchar,  PO: Tejkhali , Thana:Bancharampur, District: B-Baria', '4 Sig BN', '2015-01-24', '1997-03-01', '2019-02-21', 'no', 6, 'HSC', '', '', '', 'no', '', '01817-575926', '01840-172608', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2563, '1229680', 'LCpl (GNR)', 'Faruk Hasan', 19, 26, 'Trg On AWGSS-5', 7, 'Vill:Shihi Nazirpara,  PO Uttor Hat sohor, Thana:KhatLal, District:Joypurhat', '21 AD', '2006-07-16', '1989-01-10', '2019-02-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01737-580702', '01774-770824', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2564, '1232955', 'Snk', 'Nurul Gofur Khorshed', 19, 27, 'Trg On AWGSS-5', 4, 'Vill: Horinafari,  PO: Pakua , Thana: Pakua, District: Coxbazar', '5 AD', '2011-01-09', '1992-07-15', '2019-02-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01769-240956', '01769-240955', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2565, '1816275', 'Snk (SMS)', 'Md Arif Mir Malot', 20, 177, 'Trg On AWGSS-5', 8, 'Vill: Vajondanga,  PO: Baitul Aman , Thana: Kotowali, District:Faridpur', '35 ST BN', '2018-01-14', '1998-12-20', '2019-02-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01866-917306', '01917-399156', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2566, '1815547', 'Snk', 'Md Badsha Islam', 20, 50, 'Trg On AWGSS-5', 3, 'Vill:Kocra,  PO:Kusumba , Thana:Manda, District:Naogaon', '37 ST BN', '2017-01-12', '1998-11-10', '2019-02-23', 'no', 6, 'SSC', '', '', '', 'no', '', '01749-297023', '01710-557509', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2567, '1814983', 'Snk', 'Masudur Rahaman', 20, 178, 'Trg On AWGSS-5', 5, 'Vill:Mayane,  PO: Abu Torab, Thana:Mirsorai, District:Chattogram', '38 ST BN', '2015-01-24', '1995-04-05', '2019-02-22', 'no', 6, 'BA', 'DIC', 'INT Cadre', '', 'no', '', '01870-604735', '01813-621963', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2568, '4029873', 'Sgt', 'Md Abu Taleb', 1, 35, 'Trg On AWGSS-5', 3, 'Vill: 100/9 T Hosen Rode Islam Bag Nobigong,  PO: Nobigong  , Thana: Bondor, District: Narayongong', '29 EB (SP BN)', '1998-11-11', '1981-01-12', '2019-02-22', 'no', 6, 'HSC', 'NAC', 'Computer Cadre,  ATGW Cadre, MG Cadre', '', 'no', '', '01637-662557', '01637-662558', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2569, '4027515', 'Cpl', 'Md  Obaidur Rahaman Hanif', 1, 34, 'Trg On AWGSS-5', 28, 'Vill: Rupati,  PO: Hat Gogdol, Thana: Magura, District: Magura', '59 EB (SP BN)', '1998-05-08', '1980-01-31', '2019-02-22', 'no', 6, 'HSC', 'NCOC, ATGM', 'Computer Cadre, Signal Cadre', '', 'no', '', '01716-038053', '01710-785027', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2570, '4039676', 'LCpl', 'Md Mehidi Hasan', 1, 36, 'Trg On AWGSS-5', 6, 'Vill: Pagla Samnogor,  PO: Fokirhat , Thana: Fokirhat, District: Bagerhat', '62 EB', '2003-02-06', '1984-02-29', '2019-02-22', 'no', 6, 'BSS', 'CSEC', 'INT Cadre, 60mm MOR Cadre', '', 'no', '', '01708-517000', '01753-222397', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2571, '4058208', 'Snk', 'Md Kawser Hossen', 1, 21, 'Trg On AWGSS-5', 3, 'Vill:Sarkerpara,  PO: Heyako , Thana:Vhuzpur, District: Chittagong', '8 EB', '2016-07-17', '1997-04-25', '2019-02-22', 'no', 6, 'HSC', '', 'ICT Cadre, Signal Cadre', '', 'no', '', '01845-928119', '01813-731746', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2572, '4052029', 'Snk', 'Md Milon Hossain', 1, 56, 'Trg On AWGSS-5', 5, 'Vill: Choddokahonia,  PO: Bawshia , Thana: Gojaria, District: Munshigonj', '57 EB', '2012-01-08', '1992-01-04', '2019-02-22', 'no', 6, 'BSS', '', '', '', 'no', '', '01965-231481', '01906-057842', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2573, '4502395', 'Sgt', 'Md Monirul Islam', 9, 65, 'Trg On AWGSS-5', 4, 'Vill:Khapura,  PO: Chapitola, Thana:Banga Bazar, District: Comilla', '29 BIR', '2003-07-17', '1985-01-01', '2019-02-22', 'no', 6, 'BA', 'NCOC', 'Mor Cadre, Signal Cadre', '', 'no', '', '01720-222001', '01732-852257', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2574, '4507992', 'Snk', 'Md Ruhul Amin', 9, 167, 'Trg On AWGSS-5', 28, 'Vill:Jamgram,  PO;Jamgram, Thana:Kahalu, District:Bogura', '1 BIR', '2008-01-13', '1989-05-13', '2019-02-22', 'no', 6, 'HSC', '', 'ICT Cadre', '', 'no', '', '01834-218770', '01832-368760', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2575, '4519557', 'Snk', 'Parvez', 9, 151, 'Trg On AWGSS-5', 27, 'Vill:Jhinaiya,  PO: Subil , Thana:Dabiddar, District:Comilla', '13 BIR', '2017-01-20', '1997-09-08', '2019-02-22', 'no', 6, 'SSC', '', '', '', 'no', '', '01871-249364', '01731-827348', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2576, '4518876', 'Snk', 'Nur Mohammad', 9, 20, 'Trg On AWGSS-5', 7, 'Vill: Purnomoti,  PO:Purnomoti , Thana: Burichong, District:Comilla', '34 BIR', '2017-01-20', '1999-07-20', '2019-02-21', 'no', 6, 'HSC', '', 'Computer Cadre', '', 'no', '', '01772-834297', '01795-026781', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2577, '4521386', 'Snk', 'Md Rasel Miah', 9, 131, 'Trg On AWGSS-5', 9, 'Vill:Beyatir Char,  PO:Beyatir Char , Thana:Nicli, District: Kishorgong', '37 BIR', '2018-01-12', '1999-01-06', '2019-02-24', 'no', 6, 'HSC', '', '', '', 'no', '', '01864-670433', '01836-528271', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2578, '2206964', 'Snk', 'Md Khalil Ahmed', 12, 179, 'Trg On AWGSS-5', 8, 'Vill:Gondimari, PO: Gondimari , Thana:,Hatibandha District:Lalmonirhat', '508 DOC', '2017-01-19', '1997-12-19', '2019-02-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01784-049302', '01722-304344', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2579, '2415214', 'LCpl (RCT)', 'Salim MIah', 14, 180, 'Trg On AWGSS-5', 27, 'Vill:Gilaber,  PO:Kumartec, Thana: Shibpur, District:Narsingdi', '41 Medium Arty Wrksp Sec EME', '2008-07-06', '1990-01-11', '2019-02-22', 'no', 6, 'BA', '', '', '', 'no', '', '01762-115562', '01813-854783', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2580, '2415213', 'LCpl (RCT)', 'Md Riyad Hossain', 14, 181, 'Trg On AWGSS-5', 9, 'Vill:Gopinathpur,  PO:Gopinathpur , Thana:Lakhimpur Sadar, District:Lakhimpur', '12 Lancher Wrksp Sec EME', '2008-07-06', '1989-12-31', '2019-02-22', 'no', 6, 'SSC', '', '', '', 'no', '', '01738-488072', '01936-255783', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2581, '1005932', 'LCpl (OP)', 'Mohammad Imranul Haque', 17, 104, 'Trg On AWGSS-6', 10, 'Vill:Jongolkata,  PO: Batuwa, Thana:Chokoria, District:CoxBazar', '4 Horse', '2005-11-12', '1987-05-01', '2019-07-27', 'no', 6, 'SSC', '', 'ICT Cadre', '', 'no', '', '01731-764846', '01864-148575', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2582, '1007786', 'Snk', 'Md Obaidur Rahaman', 17, 202, 'Trg On AWGSS-6', 9, 'Vill:Kaluhati,  PO: Khuti Durgapur , Thana:Jhenaidah, District:Jhenaidah', '12 Lancher', '2017-02-01', '1998-06-25', '2019-07-27', 'no', 6, 'HSC', '', '', '', 'no', '', '01403-748397', '01782-516858', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2583, '1007353', 'Snk', 'Sojibur Rahaman', 17, 136, 'Trg On AWGSS-6', 28, 'Vill:Mosdira,  PO: Khas Mothurapur , Thana: Dowlotpur, District:Kushtia', 'Bengal Cavalory', '2015-08-04', '1997-10-27', '2019-07-27', 'no', 6, 'HSC', 'ARC-2', '', '', 'no', '', '01787-312989', '01742-428996', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2584, '1227028', 'Cpl (OCU)', 'Md Harun Or Rashid', 18, 81, 'Trg On AWGSS-6', 3, 'Vill:Talugmubs,  PO: Jatemoira , Thana: Razarhat, District:Kurigram', '4 Fd Reg Arty', '2005-01-15', '1987-06-01', '2019-07-27', 'no', 6, 'SSC', 'NCOC', 'ORBIC  Cadre', '', 'no', '', '01731-659617', '01728-116360', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2585, '1223996', 'Cpl (GNR)', 'Md Maksud Alom Khan', 18, 82, 'Trg On AWGSS-6', 10, 'Vill: Sugondhi,  PO: Soformali , Thana: Chandpur, District:Chandpur', '19 Med Reg Arty', '2001-07-20', '1983-02-01', '2019-07-27', 'no', 6, 'HSC', '', '', '', 'no', '', '01831-844774', '01859-574726', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2586, '1228888', 'LCpl (TA)', 'Md Nazmul', 18, 80, 'Trg On AWGSS-6', 9, 'Vill:Harisangan,  PO: Chandanpur , Thana: Belab, District:Jashore', '2 Fd Reg Arty', '2006-01-15', '1987-12-22', '2019-07-27', 'no', 6, 'HSC', '', 'ARIC  Cadre', '', 'no', '', '01722-181835', '01785-938738', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2587, '1230323', 'Cpl (OCU)', 'Md Majahar Uddin Mollah', 18, 12, 'Trg On AWGSS-6', 7, 'Vill: Chotovobanipur,  PO: Notunmirpur , Thana: Aminpur, District:Pabna', '18 Fd Reg Arty', '2007-01-14', '1989-11-12', '2019-07-27', 'no', 6, 'HSC', 'ICT', '1st Aid Cadre', '', 'no', '', '01767-640555', '01849-688043', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2588, '1227590', 'LCpl', 'Roich Uddin', 18, 13, 'Trg On AWGSS-6', 6, 'Vill:Dishail Dewan,  PO:Gati , Thana:Ishwardi, District:Pabna', '42 Fd Reg Arty', '2005-07-16', '1986-12-01', '2019-07-27', 'no', 6, 'HSC', '', '', '', 'no', '', '01728-806099', '01710-612192', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2589, '1238667', 'Snk', 'Md Mohinuddin', 18, 84, 'Trg On AWGSS-6', 4, 'Vill: Maligong, PO:Kashimpur, Thana: Hazigong, District:Chandpur', '46 Div Locating Bty', '2017-01-21', '1998-04-03', '2019-07-27', 'no', 6, 'SSC', '', 'ITT', '', 'no', '', '01309-644452', '01781-882045', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2590, '1444008', 'Cpl', 'Nurul Haider', 5, 39, 'Trg On AWGSS-6', 27, 'Vill: Tengrail,  PO: Bonomalipur , Thana: Bowalmari, District:Foridpur', '8 ENGR BN', '2002-01-04', '1984-08-10', '2019-07-28', 'no', 6, 'HSC', '', '', '', 'no', '', '01723-261774', '01721-013158', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2591, '1446649', 'LCpl', 'Md Khorshed Alom', 5, 40, 'Trg On AWGSS-6', 10, 'Vill: Sonipur, PO: Subar Bazar, Thana: Porsuram, District: Feni', '9 ENGR BN', '2005-11-15', '1988-02-12', '2019-07-27', 'no', 6, 'HSC', '', '', '', 'no', '', '01846-437343', '01839-666132', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2592, '1614073', 'Cpl (OP)', 'Md Badsha Alom', 6, 182, 'Trg On AWGSS-6', 4, 'Vill: Bania Sisa, PO: Poradoho, Thana:, District: Kustia', '7 Sig BN', '2003-07-10', '1985-01-25', '2019-07-27', 'no', 6, 'SSC', '', '', '', 'no', '', '01721-373560', '01794-434510', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2593, '1619436', 'Snk (WSS)', 'Shoriful Islam', 6, 45, 'Trg On AWGSS-6', 3, 'Vill:Khupi Dokhin Para,  PO:Khupi Dokhin Para, Thana:Gabtoli, District:Bogura', '3 Sig BN', '2017-01-15', '1997-06-20', '2019-07-27', 'no', 6, 'HSC', '', '', '', 'no', '', '01782-465976', '01833-663749', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2594, '1815627', 'Snk (MT)', 'Md Hasan Rahi', 20, 183, 'Trg On AWGSS-6', 27, 'Vill: Charchandina,  PO: Sonagaji, Thana: Sonagaji, District:Feni', '39 ST BN', '2017-01-20', '1998-08-27', '2019-07-27', 'no', 6, 'HSC', '', '', '', 'no', '', '01816-603377', '01836-74216', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2595, '4054364', 'Snk', 'Md Jabed Khan', 1, 51, 'Trg On AWGSS-6', 10, 'Vill:Biddakot,  PO: Biddakot , Thana: Nobinagar, District:Brahmanbaria', '1 EB', '2013-07-14', '1994-08-27', '2019-07-27', 'no', 6, 'BBS', '', '', '', 'no', '', '01789-997407', '01771-737691', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2596, '4056907', 'Snk', 'Md Al Mamun Asad', 1, 88, 'Trg On AWGSS-6', 8, 'Vill:Towasia,  PO: Kollanpur, Thana:Belcuchi, District: Sirajganj', '6 EB', '2016-01-23', '1997-05-08', '2019-07-27', 'no', 6, 'HSC', '', 'ICT Cadre, CTC Cadre', '', 'no', '', '01704-319888', '01748-710092', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2597, '4052992', 'Snk', 'Md Jahidul Islam', 1, 90, 'Trg On AWGSS-6', 29, 'Vill: Charlakhi Gong,  PO: Kutirhat, Thana: Sonagazi, District: Feni', '24 EB', '2013-01-06', '1995-03-10', '2019-07-27', 'no', 6, 'SSC', '', 'ICT Cadre, Marksmanship Cadre, Radar Cadre', '', 'no', '', '01703-033152', '01863-774611', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2598, '4043028', 'Snk', 'Kazi Md Imtiaz', 1, 87, 'Trg On AWGSS-6', 9, 'Vill:Pirshain ,  PO Pirshain: , Thana: Anowara, District:Chattogram', '3 EB', '2005-04-09', '1987-06-01', '2019-07-27', 'no', 6, 'HSC', 'NTC-19', 'ICT Cadre', '', 'no', '', '01753-651088', '01816-645524', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2599, '4051430', 'Snk', 'Md Azizur Rahman', 1, 93, 'Trg On AWGSS-6', 28, 'Vill: Taluk Gotamara,  PO: Taluk Gotamara, Thana:Sadar, District: Lalmonirhat', '12 EB', '2012-01-08', '1994-01-11', '2019-07-27', 'no', 6, 'HSC', '', 'ICT Cadre, 1st Aid Cadre', '', 'no', '', '01752-243635', '01720-993148', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2600, '4048164', 'Snk', 'Bablur Rahman', 1, 89, 'Trg On AWGSS-6', 4, 'Vill: Dighirpar,  PO:Dighirpar , Thana:Monirampur, District:Jashore', '18 EB', '2008-01-14', '1990-01-15', '2019-07-27', 'no', 6, 'SSC', '', 'ICT Cadre, ATGW Cadre', '', 'no', '', '01736-380863', '01736-085964', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2601, '4052698', 'Snk', 'Md Al Amin', 1, 89, 'Trg On AWGSS-6', 4, '12 Kamarpotti Rode,Jhalakathi', '18 EB', '2013-01-06', '1995-10-10', '2019-07-27', 'no', 6, 'HSC', 'SIGNAL', 'ICT Cadre', '', 'BAA Sec 55, 3 Days Extra Duty', '', '01734-080852', '01704-609990', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2602, '4044959', 'Snk', 'Md Nasir Ahmed', 1, 55, 'Trg On AWGSS-6', 12, 'Vill: Chorkuyorpur,  PO: Koarpur , Thana:Shariatpur, District:Shariatpur', '56 EB', '2006-06-16', '1987-04-13', '2019-07-27', 'no', 6, 'HSC', '', 'ICT Cadre', '', 'no', '', '01729-730217', '01993-304458', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2603, '4502074', 'Cpl', 'Md Abu Sayed', 9, 173, 'Trg On AWGSS-6', 28, 'Vill: Maluar,  PO: Sibdokabi , Thana: Nolcity, District:Jhalakathi`', '40 BIR', '2003-01-15', '1985-03-04', '2019-07-27', 'no', 6, 'SSC', 'TTI', '', '', 'no', '', '01925-354008', '01983-597811', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2604, '4032818', 'Cpl', 'Md Jowel Hossen Khan', 9, 146, 'Trg On AWGSS-6', 4, 'Vill: Asua Bayet,  PO: Shonkhola, Thana: Ghatail, District: Tangail', '15 BIR (SP BN)', '1999-11-18', '1981-12-01', '2019-07-27', 'no', 6, 'HSC', 'NCOA-58', 'Signal Cadre', '', 'no', '', '01712-477036', '01718-813603', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2605, '4514596', 'Snk', 'Abid Hasan', 9, 100, 'Trg On AWGSS-6', 7, 'Vill: GolerHour,  PO: Islampur , Thana: Komolgonj, District:Moulvibazar', '26 BIR', '2014-08-09', '1996-01-01', '2019-07-27', 'no', 6, 'BA', '', 'ICT Cadre', '', 'no', '', '01883-942572', '01779-467483', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2606, '4506536', 'Snk', 'Md Saiful Islam', 9, 152, 'Trg On AWGSS-6', 9, 'Vill: Natabaria,  PO: Holibani , Thana:Jhenaidah, District:Jhenaidah', '14 BIR', '2006-07-16', '1988-01-01', '2019-07-27', 'no', 6, 'BA', '', 'ICT Cadre, RL/GF Cadre', '', 'no', '', '01716-372132', '01792-578813', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2607, '4504581', 'Snk', 'Md Asaduzzamann Asad', 9, 148, 'Trg On AWGSS-6', 28, 'Vill: Kanaimadari,  PO: Pathandondi , Thana: Chondanais, District: Chattogram', '9 BIR (Mech)', '2005-07-16', '1988-03-24', '2019-07-27', 'no', 6, 'BA (Hons)', 'ICT Course', '', '', 'no', '', '01728-850350', '01883-407887', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2608, '4514587', 'Snk', 'Md Siblu Ahmed Selim', 9, 99, 'Trg On AWGSS-6', 10, 'Vill: Bagabayet,  PO:Bagabayet, Thana:Jamalpur, District:Jamalpur', '25 BIR (SP BN)', '2014-08-09', '1996-08-22', '2019-07-27', 'no', 6, 'BA', 'TTTI Course', '', '', 'no', '', '01760-260909', '01723-140415', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2609, '4521222', 'Snk', 'Md Jakaria Khan', 9, 97, 'Trg On AWGSS-6', 9, 'Vill: Muktaras,  PO: KholilGonj , Thana:Kurigram, District:Kurigram', '17 BIR (Mech)', '2017-07-12', '1998-09-27', '2019-07-27', 'no', 6, 'HSC', 'ICT Course', '', '', 'no', '', '01783-116131', '01764-412134', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2610, '4522520', 'Snk', 'Md Abdus Samad', 9, 132, 'Trg On AWGSS-6', 7, 'Vill: Jhawdia,  PO: Jhawdia , Thana:Islami bissobiddaloy, District:Kushtia', '36 BIR', '2018-01-14', '1998-06-07', '2019-07-28', 'no', 6, 'HSC', '', '', '', 'no', '', '01706-681445', '01770-050573', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2611, '1006398', 'LCpl (DVR)', 'Md Mamun Miah', 17, 79, 'Trg On AWGSS-7', 6, 'Vill: Kawnia,  PO: Amtoli, Thana: Amtoli, District: Barguna', '26 Horse', '2008-01-13', '1989-01-13', '2020-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01712-709437', '01722-541239', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2612, '1008114', 'Snk (GNR)', 'Md Imran Nazir', 17, 202, 'Trg On AWGSS-7', 4, 'Vill: Batiya, PO: Borina , Thana: Shahajatpur,  District:Sirajganj', '12 Lancher', '2017-01-21', '1999-11-15', '2020-01-30', 'no', 6, 'HSC', '', '', '', 'no', '', '01891-904230', '01773-064253', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2613, '1226787', 'Cpl (GNR)', 'Gole Ahmed', 18, 184, 'Trg On AWGSS-7', 7, 'Vill: Masudpur,  PO: Sajiura, Thana: Kendua  District: Netrokona', '30 Fd Reg Arty', '2005-01-15', '1985-12-03', '2020-01-30', 'no', 6, 'HSC', '', 'ICT Cadre', '', 'no', '', '01732-55757579', '01404-787884', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2614, '1229630', 'LCpl (TA)', 'Md Liton Sarker', 18, 185, 'Trg On AWGSS-7', 27, 'Vill: Guzabari,  PO: Chargiris, Thana: Kazipur District: Sirajganj', '9 Fd Reg Arty', '2006-07-16', '1988-10-14', '2020-01-31', 'no', 6, 'HSC', '', 'INT Cadre', '', 'no', '', '01749-411412', '01953-859873', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2615, '1231366', 'LCpl (OCU)', 'Shree Mithu Biswas', 18, 13, 'Trg On AWGSS-7', 6, 'Vill: Potherhat,  PO: Guyal Bathan, Thana: Magura  District: Magura', '42 Fd Reg Arty', '2008-01-13', '1990-01-28', '2020-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01737-400113', '01719-485560', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2616, '1231711', 'LCpl (TA)', 'Md Mukles Alam', 18, 186, 'Trg On AWGSS-7', 10, 'Vill: Medulia,  PO: Boliyadi, Thana: Kaliyakoir, District: Gazipur', '26 Fd Reg Arty', '2008-07-13', '1990-12-15', '2020-01-31', 'no', 6, 'HSC', '', 'FSCC Cadre', '', 'no', '', '01743-995862', '01781-919310', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2617, '1232299', 'LCpl (OCU)', 'Md Ashrafuzzaman', 19, 187, 'Trg On AWGSS-7', 17, 'Vill: South Mirzapur,  PO: Hazrapur, Thana: Magura, District: Magura', '25 AD Reg Arty', '2009-07-05', '1991-10-23', '2020-01-31', 'no', 6, 'BA', '', 'CTC Cadre, Kote Magazine Cadre, Gym Cadre', '', 'no', '', '01735-788424', '01714-661587', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2618, '1237428', 'Snk (OCU)', 'Md Nazmul Islam', 19, 188, 'Trg On AWGSS-7', 25, 'Vill: Murshidhat,  PO: Satabgonj , Thana: Bochagong  District: Dinajpur', '56 Indep Med AD Bty', '2017-01-13', '1997-06-19', '2020-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01774-624185', '01751-921684', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2619, '1237221', 'Snk (OCU)', 'Mohammad Hasan', 18, 12, 'Trg On AWGSS-7', 5, 'Vill: Asabari,  PO: Sosidol, Thana: Bramhonpara, District: Cumilla', '18 Fd Reg Arty', '2016-01-23', '1997-10-22', '2020-01-31', 'no', 6, 'SSC', '', '', '', 'no', '', '01720-475557', '01882-435327', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2620, '1238499', 'Snk (OCU)', 'Md Rashidul Haque', 18, 30, 'Trg On AWGSS-7', 27, 'Vill: Gondhmorua,  PO: Durgapur, Thana: Adtomari District: Lalmonirhat', '27 Fd Reg Arty', '2017-01-22', '1997-07-11', '2020-02-01', 'no', 6, 'HSC', '', '', '', 'no', '', '01761-127483', '01725-693200', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2621, '1238869', 'Snk (GNR)', 'Md Rana Ahmed', 18, 115, 'Trg On AWGSS-7', 5, 'Vill: Kishorpur,  PO: Kishorpur, Thana: Bagha,  District: Rajshahi', '22 Fd Reg Arty', '2017-01-22', '1998-04-22', '2020-01-31', 'no', 6, 'SSC', '', '', '', 'no', '', '01791-859231', '01748-292583', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2622, '1452272', 'Snk', 'Md Abdullah Mahmud', 5, 189, 'Trg On AWGSS-7', 30, 'Vill: Patapara,  PO:Joypurhat   , Thana:Joypurhat  District:Joypurhat', '12 ENGR BN', '2016-01-24', '1998-07-02', '2020-02-02', 'no', 6, 'HSC', '', 'CIED Cadre', '', 'no', '', '01769-621757', '01731-217552', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2623, '1454038', 'Snk (M DVR)', 'Md Abdullah Al Amin', 5, 190, 'Trg On AWGSS-7', 3, 'Vill: Tista Tokdar para,  PO:  Tista, Thana: Lalmonirhat  District:   Lalmonirhat', '11 RE BN', '2017-07-21', '1998-07-15', '2020-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01770-974003', '01735-400804', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2624, '1614299', 'Sgt (OP)', 'Md Monsur Ahmed Shipon', 6, 119, 'Trg On AWGSS-7', 8, 'Vill: Baguni Para, PO:Shaistaganj  , Thana:Habiganj  District: Habiganj', '5 Sig Bn', '2004-01-08', '1986-01-10', '2020-01-31', 'no', 6, 'SSC', '', '', 'Computer SVC And Internet', 'no', '', '01717-128826', '01769-176261', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2625, '1617684', 'Snk (OP)', 'Md Lokman Hossain', 6, 191, 'Trg On AWGSS-7', 14, 'Vill: Monipur ,  PO Amzadhat , Thana: Fulgazi  District: Feni', 'Army Static Sig BN', '2013-01-06', '1995-06-10', '2020-01-31', 'no', 6, 'SSC', '', '', '', 'no', '', '01831-853976', '01856-339594', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2626, '4025481', 'Sgt', 'Mohammad Ataur Rahman', 1, 59, 'Trg On AWGSS-7', 5, 'Vill: Prodhanbad,  PO: Kaligonj  , Thana: Dabiogonj  District:Panchagarh', '64 EB', '1997-11-13', '1981-02-02', '2020-01-31', 'no', 6, 'BSS', 'ORBIC', 'MT Cadre, MG Cadre', '', 'no', '', '01769-020108', '01708-364920', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2627, '4038196', 'Cpl', 'Md Harun Or Rashid', 1, 91, 'Trg On AWGSS-7', 27, 'Vill: Charkaira,  PO: Nikrai, Thana: Vowapur  District: Tangail', '25 EB', '2002-01-11', '1984-01-01', '2020-01-31', 'no', 6, 'HSC', 'MOR', 'ICT Cadre', '', 'no', '', '01728-021319', '01872-704361', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2628, '4044666', 'Snk', 'Mazharul Islam', 1, 86, 'Trg On AWGSS-7', 7, 'Vill: Montola,  PO: Fulbaria, Thana: Kaliyakor, District: Gazipur', '16 EB', '2005-11-12', '1986-11-18', '2020-01-31', 'no', 6, 'HSC', '', 'Signal Cadre, MG Cadre, ICT Cadre', '', 'no', '', '01728-088258', '01760-691850', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2629, '4045574', 'Snk', 'Mohiuddin', 1, 165, 'Trg On AWGSS-7', 3, 'Vill: Bagmara,  PO: Chutna, Thana: Devidwar,  District: Cumilla', '36 EB', '2006-06-18', '1987-08-25', '2020-01-31', 'no', 6, 'BA', '', 'MT Cadre, PF-98 Cadre, SGT', '', 'no', '', '01815-095701', '01814-425159', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2630, '4052542', 'Snk', 'Md Nazmul Huda', 1, 60, 'Trg On AWGSS-7', 5, 'Vill: East Abdal pur,  PO: Hori Narayaonpur, Thana: Kushtia  District:  Kushtia', '65 EB', '2013-01-06', '1995-04-03', '2020-01-31', 'no', 6, 'HSC', '', 'RR Cadre, ICT Cadre', '', 'no', '', '01740-332243', '01770-355249', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2631, '4057240', 'Snk', 'Pavel Hasan', 1, 92, 'Trg On AWGSS-7', 3, 'Vill: Dainna Chawdhory,  PO: Bakhil, Thana: Sadar,  District: Tangail', '21 EB', '2016-01-23', '1997-11-28', '2020-01-31', 'no', 6, 'HSC', 'NTC-19, NAC-6', '', '', 'no', '', '01833-513036', '01740-233391', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2632, '4057327', 'Snk', 'Masum Gazi', 1, 57, 'Trg On AWGSS-7', 7, 'Vill: Munir Kandi,  PO:  Gohala , Thana: Muksudpur  District:Gopalganj', '61 EB', '2016-01-23', '1997-11-06', '2020-02-02', 'no', 6, 'HSC', '', '', '', 'no', '', '01788-282770', '01316-962954', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2633, '4058171', 'Snk', 'Md Belal Hossain', 1, 63, 'Trg On AWGSS-7', 29, 'Vill:Islampur,  PO: Panchari, Thana: Panchari, District: Khagrachari', '79 EB (SP BN)', '2016-07-17', '1997-02-12', '2020-01-31', 'no', 6, 'HSC', '', 'ICT Cadre', '', 'no', '', '01855-330318', '01828-881028', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2634, '4061679', 'Snk', 'Mahadi Hasan', 1, 166, 'Trg On AWGSS-7', 26, 'Vill: Kotbazalia ,  PO:  Chadpur , Thana: Kapashia  District:  Gazipur', '38 EB', '2018-01-14', '1999-05-05', '2020-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01943-806009', '01729-469792', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2635, '4063088', 'Snk', 'Md Polok Hossain', 1, 110, 'Trg On AWGSS-7', 3, 'Vill: Kalchadpur,  PO: Meherpur  , Thana: Sadar  District: Meherpur', '58 EB', '2018-01-21', '1999-11-15', '2020-01-31', 'no', 6, 'HSC', '', 'RR Cadre', '', 'no', '', '01958-512454', '01772-352928', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2636, '4063199', 'Snk', 'Md Abdur Rahman', 1, 58, 'Trg On AWGSS-7', 3, 'Vill: Soguna,  PO: Hanhill, Thana: Joypurhat, District: Joypurhat', '63 EB', '2018-01-21', '1999-01-13', '2020-01-31', 'no', 6, 'HSC', '', 'ICT Cadre', '', 'no', '', '01304-063200', '01741-097768', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2637, '4063447', 'Snk', 'Md Sumon Ahmed', 1, 94, 'Trg On AWGSS-7', 9, 'Vill: Uchitpur,  PO: Dibakorpur, Thana: Pachbibi, District: Joypurhat`', '10 EB', '2018-07-22', '1999-02-01', '2020-01-31', 'no', 6, 'HSC', 'TTTI', '', '', 'no', '', '01993-691372', '01710-868337', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2638, '4503265', 'LCpl', 'Md Nurislam', 9, 96, 'Trg On AWGSS-7', 7, 'Vill: Gokulpur,  PO: Kishurpur, Thana: Bagha, District:Rajshahi', '22 BIR', '2004-07-15', '1986-10-10', '2020-01-31', 'no', 6, 'HSC', '', 'ICT Cadre, RP Cadre', '', 'no', '', '01722-702135', '01705-955899', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2639, '4503671', 'LCpl', 'Md Boshir Uddin', 9, 131, 'Trg On AWGSS-7', 9, 'Vill:Kumarpur,  PO: Vullibazar, Thana: Sadar, District:Thakurgaon', '37 BIR', '2004-07-15', '1987-01-15', '2020-01-31', 'no', 6, 'HSC', '', 'ICT Cadre, MG Cadre', '', 'no', '', '01708-350972', '01708-350973', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2640, '4506684', 'Snk', 'Md Julfiker Haider', 9, 172, 'Trg On AWGSS-7', 28, 'Vill:Ghorimondol,  PO: Chitoshi , Thana: Shahrasti, District: Chadpur', '10 BIR', '2006-07-16', '1988-06-11', '2020-01-31', 'no', 6, 'HSC', 'ATGM Course', '', '', 'no', '', '01966-627006', '01777-241733', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2641, '4509970', 'Snk', 'Md Imran Biswas', 9, 64, 'Trg On AWGSS-7', 7, 'Vill:Molladanga,  PO: Kulapatghati, Thana: Digholia, District: Khulna', '3 BIR', '2010-01-10', '1991-09-27', '2020-01-31', 'no', 6, 'HSC', 'SAC', 'RR Cadre, ICT Cadre, FMC Cadre', '', 'no', '', '01769-337799', '01769-337798', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2642, '4510246', 'Snk', 'Md Abu Zafor', 9, 65, 'Trg On AWGSS-7', 3, 'Vill:Dhawa,  PO:Dhawa , Thana: Vandaria, District:Pirojpur', '4 BIR', '2010-07-11', '1991-11-25', '2020-01-31', 'no', 6, 'BA', 'ICTC-12, APC(GNR), Arabic Language Course', 'ICT Cadre, MG Cadre', '', 'no', '', '01724-891335', '01748-255176', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2643, '4510732', 'Snk', 'Hossain Ahmed', 9, 76, 'Trg On AWGSS-7', 5, 'Vill:Noyanogar,  PO: Bormi , Thana: Kapashia, District: Gazipur', '42 BIR', '2011-07-10', '1993-12-15', '2020-01-31', 'no', 6, 'HSC', 'ICTC-11, ATGWC-4, PFTC-1', 'ICT Cadre', '', 'no', '', '01714-889960', '01955-506122', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2644, '4511364', 'Snk', 'Nurnabi Islam', 9, 71, 'Trg On AWGSS-7', 10, 'Vill: Punotti,  PO: Gomirahat, Thana:Chirirbondor, District: Dinajpur', '28 BIR', '2012-01-08', '1991-12-31', '2020-01-31', 'no', 6, 'HSC', '', 'Matis-M-1 Cadre, Radar Cadre, RL/GF Cadre', '', 'no', '', '01738-037872', '01736-597296', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2645, '4519302', 'Snk', 'Md Ayub Ali', 9, 101, 'Trg On AWGSS-7', 4, 'Vill:Haidarpur,  PO: Jingedoh , Thana:Sadar, District:Chuadanga', '8 BIR', '2017-01-20', '1997-07-25', '2020-01-31', 'no', 6, 'HSC', '', '60/82 MOR  Cadre', '', 'no', '', '01776-152153', '01714-631343', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2646, '4522126', 'Snk', 'Md Mahfuz Al Mamun', 9, 73, 'Trg On AWGSS-7', 10, 'Vill: Fulbaria,  PO: Mirpur, Thana:Mirpur, District: Kushtia', '30 BIR', '2018-01-14', '1999-01-10', '2020-01-31', 'no', 6, 'HSC', '', 'ICT Cadre', '', 'no', '', '01871-975713', '01744-261038', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2647, '4522471', 'Snk', 'Md Azad Hossain', 9, 134, 'Trg On AWGSS-7', 27, 'Vill:Changini,  PO: Halimanagar, Thana:Cumilla, District: Cumilla', '39 BIR', '2018-01-14', '1999-03-20', '2020-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01860-545429', '01717-445461', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2648, '4522679', 'Snk', 'Md Faruk Hossain', 9, 69, 'Trg On AWGSS-7', 27, 'Vill:Kaldaiya,  PO: Rayed, Thana: Kapashia, District: Gazipur', '24 BIR', '2018-01-21', '1998-05-08', '2020-01-31', 'no', 6, 'SSC', '', '', '', 'no', '', '01629-121029', '01905-865429', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2649, '4524146', 'Snk', 'Mahadi Hasan Sheikh', 9, 167, 'Trg On AWGSS-7', 7, 'Vill:Bahadurpur,  PO: Sajiara, Thana:Dumuria, District:Khulna', '1 BIR', '2017-07-22', '1999-03-02', '2020-01-31', 'no', 6, 'HSC', '', 'IT Cadre', '', 'no', '', '01956-648211', '01910-313682', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2650, '2207059', 'Snk (SMT)', 'Md Masud Alom', 12, 192, 'Trg On AWGSS-7', 9, 'Vill:Amra,  PO: Gopalpur, Thana: Ghoraghat, District: Dinajpur', '505 DOC', '2017-01-20', '1998-12-28', '2020-02-01', 'no', 6, 'HSC', '', 'IT Cadre', '', 'no', '', '01791-896194', '01797-633256', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2651, '1007484', 'Snk (DVR)', 'Shamim Hosen', 17, 203, 'Trg On AWGSS-8', 27, 'Vill:Nannar,  PO:Nannar, Thana: Dhamrai, District: Dhaka', '16 Cavalory', '2016-01-23', '1998-04-08', '2021-01-31', 'no', 6, 'HSC', 'DIC Course', '', '', 'no', '', '01990-795574', '01937-690096', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2652, '1008612', 'Snk (DVR)', 'Md Younus Ali', 17, 79, 'Trg On AWGSS-8', 6, 'Vill: Soroli,  PO: Ihai, Thana:Sapahar, District: Naugaon', '26 Horse', '2019-01-27', '2000-05-20', '2021-01-31', 'no', 6, 'SSC', '', '', '', 'no', '', '01709-073156', '01776-483854', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2653, '1226777', 'Cpl (GNR)', 'Mohammad Sanowar Karim', 18, 117, 'Trg On AWGSS-8', 28, 'Vill:Dholakanda,  PO: Chander  Nagar, Thana: Sharpur, District: Sharpur', '1 Fd Reg Arty', '2005-01-15', '1987-08-01', '2021-01-31', 'no', 6, 'HSC', 'NCOC', '', '', 'no', '', '01723-001571', '01724-572402', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2654, '1222482', 'LCpl (OCU)', 'Masudar Rahman', 18, 193, 'Trg On AWGSS-8', 8, 'Vill: South Polas Bari,  PO: South Polas Bari, Thana: Chinibondor, District: Dinajpur', '22 Med Reg Arty', '1999-07-23', '1980-07-08', '2021-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01727--824498', '01719-987267', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2655, '1231145', 'LCpl (OCU)', 'Md Mizanur Rahman', 18, 204, 'Trg On AWGSS-8', 27, 'Vill: Charcifully,  PO: Kheyaghat, Thana: Bhola, District: Bhola', '6 Fd Reg Arty', '2008-01-13', '1990-04-20', '2021-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01736-910134', '01720-559949', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2656, '1226132', 'LCpl (GNR)', 'Manubendu Kumar Biswas', 18, 157, 'Trg On AWGSS-8', 5, 'Vill: Tarapur,  PO: Nowpara, Thana: Modhukhali, District: Faridpur', '50 Fd Reg Arty', '2004-07-17', '1988-01-01', '2021-01-31', 'no', 6, 'SSC', 'Swimming Course', '', '', 'no', '', '01828-438847', '01721-557854', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2657, '1235925', 'Snk (OCU)', 'Md Robiul Islam', 18, 16, 'Trg On AWGSS-8', 10, 'Vill: Charpatkol,  PO: Charpatkol, Thana: Singra, District: Natore', '20 Fd Reg Arty', '2015-01-24', '1996-09-22', '2021-01-31', 'no', 6, 'HSC', 'ACC-37', '', '', 'no', '', '01789-654049', '01745-160442', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2658, '1237406', 'Snk (TA)', 'Md Rubel Miah', 18, 186, 'Trg On AWGSS-8', 10, 'Vill: Chapuria,  PO: Fubaria, Thana: Kaliakoir, District: Gazipur', '26 Fd Reg Arty', '2017-01-20', '1998-02-12', '2021-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01795-361457', '01726-205075', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2659, '1237967', 'Snk (GNR)', 'Md Jashim Uddin Hawlader', 18, 116, 'Trg On AWGSS-8', 6, 'Vill: Ronshi,  PO: Ronshi , Thana: Bakergonj, District: Barishal', '49 Fd Reg Arty', '2017-01-20', '1996-01-17', '2021-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01818-921022', '01725-218575', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2660, '1238871', 'Snk (DMT)', 'Faruk Ahmmed', 18, 194, 'Trg On AWGSS-8', 3, 'Vill: Ambaria,  PO: Horospur , Thana Madhobpur:, District: habigonj', '23 Fd Reg Arty', '2017-01-22', '1998-03-06', '2021-01-31', 'no', 6, 'HSC', '', 'INT Cadre', '', 'no', '', '01760-007225', '01727-537539', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2661, '1240854', 'Snk (TA)', 'Md Atikur Rahman', 18, 205, 'Trg On AWGSS-8', 9, 'Vill: Chongdhu Mridho Para,  PO: Abdul Pur , Thana: Lalpur, District:Natore', '8 Fd Reg Arty', '2018-07-22', '1999-09-27', '2021-01-31', 'no', 6, 'HSC', '', 'INT Cadre', '', 'no', '', '01644-643091', '01637-889193', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2662, '1450490', 'LCpl', 'Md Abu Taleb', 5, 195, 'Trg On AWGSS-8', 30, 'Vill: North Hugra,  PO: Dhulbari, Thana: Tangail, District: Tangail', '57 ENGR COY', '2014-08-10', '1996-07-05', '2021-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01775-580244', '01733-571770', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2663, '1452658', 'Snk (OCU)', 'Md Hasibul Hasan', 5, 196, 'Trg On AWGSS-8', 30, 'Vill: Nolbaria,  PO: Khanpur, Thana: Sharpur, District: Bogura', '5 RE BN', '2017-01-22', '1999-09-15', '2021-01-31', 'no', 6, 'HSC', 'UACC-33', '', '', 'no', '', '01750-405056', '01768-817322', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2664, '1450197', 'Snk', 'Md Hasibul Hasan', 5, 196, 'Trg On AWGSS-8', 30, 'Vill: Baliadanga,  PO: Alokdia, Thana:Magura, District:Magura', '5 RE BN', '2014-01-26', '1994-12-30', '2021-02-11', 'no', 6, 'HSC', '', '', '', 'no', '', '01763-002500', '01728-825516', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2665, '1617249', 'Snk (OP)', 'Abul Kamal Azad', 6, 197, 'Trg On AWGSS-8', 14, 'Vill: Raherchar,  PO: Chandrakona, Thana: Nokla, District: Sherpur', '10 Sig BN', '2011-04-03', '1993-04-12', '2021-01-31', 'no', 6, 'BSS', '', 'ICT  Cadre, EW Cadre, Signal Equipment Cadre', '', 'no', '', '01687-015974', '01766-154987', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2666, '1619007', 'Snk', 'Md Khairul Basar Rasel', 6, 142, 'Trg On AWGSS-8', 14, 'Vill: Sawla,  PO: Paotanarhat , Thana: Pirgacha, District: Rangpur', '11 Sig BN', '2016-07-23', '1996-07-23', '2021-01-31', 'no', 6, 'HSC', '', 'Optical Fiber Cadre, Micro Wave Cadre', '', 'no', '', '01797-911384', '01737-333342', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2667, '4039393', 'Cpl', 'Md Rohmotulla Sarker', 1, 198, 'Trg On AWGSS-8', 28, 'Vill: Choraikhaola,  PO: Bottola, Thana: Nilphamari, District:Nilphamari', '40 EB (Mech)', '2002-07-25', '1985-01-12', '2021-01-31', 'no', 6, 'HSC', '', 'MT Cadre, AGC Cadre, 82 mm MOR Cadre', '', 'no', '', '01924-008789', '01997-662290', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2668, '4035381', 'LCpl', 'Mamun Sikdar', 1, 163, 'Trg On AWGSS-8', 10, 'Vill: Charsultanpur,  PO: Charhaziganj, Thana: Char Vodrason, District: Faridpur', '30 EB', '2001-01-05', '1981-10-10', '2021-01-31', 'no', 6, 'SSC', 'NCOC', 'MT Cadre, MG Cadre', '', 'no', '', '01716-106125', '01745-825445', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2669, '4047330', 'Snk', 'Saiful Islam', 1, 124, 'Trg On AWGSS-8', 10, 'Vill:Shukni,  PO: Kurigram , Thana: Ghatail, District:Tangail', '11 EB', '2008-01-14', '1989-01-01', '2021-01-31', 'no', 6, 'BA (Hons)', '', 'Computer Cadre', '', 'no', '', '01728-277015', '01710-651446', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2670, '4066271', 'Snk', 'Md Tokir Ahmed', 1, 127, 'Trg On AWGSS-8', 28, 'Vill: Kanchonnagor,  PO:Jhenaidah , Thana:Jhenaidah, District:Jhenaidah', '17 EB', '2006-06-18', '1988-07-27', '2021-01-31', 'no', 6, 'BSS', 'ICT STC-18', 'ICT Cadre, Signal Cadre, 82 mm MOR Cadre, RL/GF Cadre', '', 'no', '', '01725-834442', '01739-239739', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2671, '4052795', 'Snk', 'Md Miraz Al Mamun', 1, 145, 'Trg On AWGSS-8', 7, 'Vill: Mohammadpur,  PO:Mohammadpur , Thana:Mohammadpur, District: Magura', '4 EB', '2013-01-06', '1994-10-28', '2021-01-31', 'no', 6, 'HSC', 'ICTC, SIGNAL Course, MCSAC', '', '', 'no', '', '01946-421430', '01935-204836', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2672, '4053554', 'Snk', 'Md Mizanur Rahman', 1, 199, 'Trg On AWGSS-8', 5, 'Vill:Kodla,  PO:Kordi , Thana: Shreepur, District: Magura', '13 EB', '2013-01-14', '1995-07-12', '2021-02-02', 'no', 6, 'HSC', '', 'PF-98  Cadre, CPR Cadre', '', 'no', '', '01648-855109', '01739-743440', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2673, '4055199', 'Snk', 'Md Didar Hossain', 1, 122, 'Trg On AWGSS-8', 28, 'Vill: Tengarchar,  PO:Tengarchar , Thana:Gozaria, District: Munshiganj', '7 EB', '2014-01-26', '1995-05-11', '2021-01-31', 'no', 6, 'HSC', '', 'Marksmanship  Cadre, CPR Cadre, ICT Cadre', '', 'no', '', '01835-252980', '01883-402750', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2674, '4057120', 'Snk', 'Md Kawser Hossen', 1, 200, 'Trg On AWGSS-8', 3, 'Vill: Gowalgava,  PO: Khaderga, Thana: Motlob, District: Chadpur', '5 EB', '2016-01-23', '1996-10-27', '2021-01-31', 'no', 6, 'HSC', '', 'MG Cadre', '', 'no', '', '01836-822983', '01814-911401', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2675, '4061155', 'Snk', 'Md Rezvi Ahmed', 1, 199, 'Trg On AWGSS-8', 5, 'Vill: Chapashar,  PO: Kathaldangi, Thana: Horipur, District:Thakurgaon', '13 EB', '2018-01-14', '1999-06-11', '2021-01-31', 'no', 6, 'HSC', '', 'ICT Cadre', '', 'no', '', '01850-684422', '01717-202718', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2676, '4061425', 'Snk', 'Md Nasim Ahmed', 1, 163, 'Trg On AWGSS-8', 10, 'Vill: Koltapara,  PO: Mohojampur, Thana: Sonargaon, District: Narayongonj', '30 EB', '2018-01-14', '1999-08-22', '2021-01-31', 'no', 6, 'HSC', '', 'Signal Cadre', '', 'no', '', '01731-730432', '01814-475455', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2677, '4061512', 'Snk', 'Abdul Alim', 1, 129, 'Trg On AWGSS-8', 9, 'Vill: Joyrampur,  PO:Joyrampur, Thana: Damurhuda, District: Chuadanga', '20 EB', '2018-01-14', '2000-07-01', '2021-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01939-729901', '01719-731421', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2678, '4064300', 'Snk', 'Md Mahadi Hasan', 1, 53, 'Trg On AWGSS-8', 3, 'Vill: Baharbon,  PO: Dighirpara, Thana: Nageswari, District: Kurigram', '26 EB', '2019-01-13', '2001-12-25', '2021-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01740-484124', '01718-738298', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2679, '4066668', 'Snk', 'Md Mamunur Rashid', 1, 125, 'Trg On AWGSS-8', 9, 'Vill: Shayerpukur,  PO: Darusha, Thana: Poba, District: Rajshahi', '14 EB', '2019-07-21', '2000-05-27', '2021-01-31', 'no', 6, 'HSC', '', 'ICT Cadre', '', 'no', '', '01750-366679', '01734-392681', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2680, '4502216', 'Cpl', 'Md Salah Uddin', 9, 168, 'Trg On AWGSS-8', 4, 'Vill: Vabokpara,  PO: Hazipur, Thana:Laksham, District: Cumilla', '5 BIR (SP BN)', '2003-01-16', '1984-01-01', '2021-01-31', 'no', 6, 'HSC', 'ATGM Course', 'MG  Cadre, MIT Cadre, ICT Cadre', '', 'no', '', '01719-165625', '01626-688534', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2681, '4506149', 'LCpl', 'Md Saidur Rahman', 9, 155, 'Trg On AWGSS-8', 7, 'Vill: Izrotpur,  PO: Balarhat, Thana: Mithapukur, District: Rangpur', '21 BIR', '2006-07-16', '1987-12-02', '2021-01-31', 'no', 6, 'SSC', '', 'RR  Cadre, GS Cadre, ICT Cadre', '', 'no', '', '01822-843378', '01728-75760', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2682, '4510943', 'Snk', 'Md Nazem Ali', 9, 147, 'Trg On AWGSS-8', 10, 'Vill: Khurapakhia,  PO: Ramchandrapurhat , Thana:Nababganj, District: Nababganj', '2 BIR', '2011-07-10', '1992-11-20', '2021-01-31', 'no', 6, 'BSS', '', 'CTC  Cadre, RL/GF Cadre, ICT Cadre', '', 'no', '', '01740-147032', '01777-693435', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2683, '4512910', 'Snk', 'Md Moniruzzaman', 9, 148, 'Trg On AWGSS-8', 28, 'Vill: Kakina,  PO: Kakina, Thana: Kaligonj, District: Lalmonirhat', '9 BIR (Mech)', '2013-07-14', '1995-12-31', '2021-01-31', 'no', 6, 'BSS', 'NTC', 'Signal Cadre, ICT Cadre', '', 'no', '', '01632-339570', '01743-882616', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2684, '4513372', 'Snk', 'Md Ahsanur Kabir', 9, 20, 'Trg On AWGSS-8', 5, 'Vill: Doctorpara,  PO: Rajholi, Thana:Rajholi, District: Rangamati', '34 BIR', '2013-07-14', '1994-12-30', '2021-01-31', 'no', 6, 'HSC', '', 'MT Cadre', '', 'no', '', '01632-141137', '01611-770995', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2685, '4515284', 'Snk', 'Md Lotiful Islam', 9, 154, 'Trg On AWGSS-8', 4, 'Vill: Barghoria,  PO: Mohiskhucha, Thana: Aditmari, District: Lalmonirhat', '9 Inf Div', '2015-01-24', '1995-12-12', '2021-01-31', 'no', 6, 'HSC', '', 'MG Cadre, M-1 Cadre', '', 'no', '', '01767-218171', '01735-438969', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2686, '4515430', 'Snk', 'Md Nure Alam', 9, 150, 'Trg On AWGSS-8', 7, 'Vill: Sathbaria,  PO: Ishibpur, Thana: Rajoir, District: Madaripur', '12 BIR', '2015-01-24', '1995-02-08', '2021-01-31', 'no', 6, 'HSC', '', 'ICT Cadre', '', 'no', '', '01877-408334', '01934-302508', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2687, '4519189', 'Snk', 'Sheikh Md Forid', 9, 68, 'Trg On AWGSS-8', 8, 'Vill: Kewaposchim Khondo,  PO: Mawna, Thana: Shree Pur, District: Gazipur', '23 BIR', '2017-01-20', '1998-07-15', '2021-01-31', 'no', 6, 'HSC', '', 'RL/GF Cadre', '', 'no', '', '01763-944554', '01727-782763', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2688, '4519838', 'Snk', 'Shawan Miah', 9, 153, 'Trg On AWGSS-8', 7, 'Vill: Chakkawria,  PO: Chakkawria, Thana: Sree Bordi, District: Sherpur', '18 BIR', '2017-01-20', '1997-10-30', '2021-01-31', 'no', 6, 'HSC', '', 'ICT Cadre, MOR Cadre', '', 'no', '', '01972-101782', '01743-387249', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2689, '4517516', 'Snk', 'Md Rahmat Hossain', 9, 152, 'Trg On AWGSS-8', 9, 'Vill: Bowalia,  PO: Bowalia, Thana: Naogaon , District: Naogaon', '14 BIR', '2017-01-15', '1999-05-15', '2021-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01797-173881', '01704-480990', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2690, '4517768', 'Snk', 'Md Alomgir Miah', 9, 149, 'Trg On AWGSS-8', 4, 'Vill: Sukhia,  PO: Sukhia, Thana: Pakundia, District: Kishorgonj', '11 BIR (Mech)', '2017-01-13', '1998-08-01', '2021-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01782-821198', '01732-457882', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2691, '4520408', 'Snk', 'Md Forid Mondol', 9, 170, 'Trg On AWGSS-8', 7, 'Vill: Ekbarpur,  PO: Panbazar, Thana: Pirganj, District: Rangpur', '7 BIR', '2017-07-23', '1998-10-05', '2021-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01838-853728', '01750-280121', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2692, '1816636', 'Snk (MT)', 'Shayekh Ahammed', 20, 201, 'Trg On AWGSS-8', 11, 'Vill: Dhopaghat,  PO: Pachua, Thana:Goforgaon, District:Mymensingh', 'Army ST BN', '2018-01-21', '1999-11-01', '2021-01-31', 'no', 6, 'HSC', '', '', '', 'no', '', '01880-156971', '01767-728085', '2025-10-04 14:11:02', '2025-10-04 14:11:02', NULL),
(2693, '1226549', 'Sgt (TA)', 'Md. Shafiqul Islam', 18, 184, 'no', 12, 'Vill: Potua Para,  PO: Sandikona, Thana:Kendua, District:Netrokona', '30 Fd Reg Arty', '2005-01-15', '1986-10-10', '2025-03-12', 'no', 6, 'HSC', 'NCO\'s Course - 57, ARIC (TA), JNGSC (Fd)', 'ICT, AutoCAD', NULL, 'no', 'Trg NCO', '1722486346', NULL, '2025-10-04 14:11:02', '2025-10-04 14:18:45', NULL),
(2694, '1007600', 'Snk (GNR)', 'Anisur Rahman', 17, 112, 'WGSOC-1', 10, 'Vill: Sadekpur, PO: Sadekpur, Thana: Sadar, District: Brahmanbaria', '7 Horse', '2017-01-15', '1997-11-26', '2025-08-07', 'no', 6, 'BA/BSS', '', 'Marksmanship Cadre, Photography Cader, SP Guard Trainning', '', 'no', '', '01303-320847', '01789-270980', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2695, '1009634', 'Snk', 'Jomir Uddin', 17, 202, 'WGSOC-1', 4, 'Vill: East Mayani, PO: Abu Towab, Thana: Mirshorai, District: Chattogram', '12 Lancher', '2023-02-03', '2004-04-01', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01883-132719', '01806-207605', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2696, '1009493', 'Snk', 'Ariful Islam Shuvo', 17, 203, 'WGSOC-1', 27, 'Vill: Churali, PO: Douhakhola, Thana: Gouripur, District: Mymensingh', '16 Cavalory', '2022-02-04', '2003-12-04', '2025-08-07', 'no', 6, 'SSC', '', '', '', 'no', '', '01700-992212', '01625-822010', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2697, '1239539', 'Snk', 'MD Ridoy Hossen', 18, 204, 'WGSOC-1', 28, 'Vill: North Mokimpur, PO: Krisnopur, Thana: Manikganj, District: Manikganj', '6 Fd Reg Arty', '2018-01-14', '1999-12-28', '2025-08-07', 'no', 6, 'HSC', '', 'CLS Cader', '', 'no', '', '01787-805182', '01609-515606', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2698, '1244215', 'Snk (OCU)', 'MD Oli Ullah', 18, 205, 'WGSOC-1', 9, 'Vill: Rafiar Algi, PO: Uchahila, Thana: Iswarganj, District: Mymensingh', '8 Fd Reg Arty', '2020-01-10', '2000-08-27', '2025-08-07', 'no', 6, 'HSC', '', '12.7 AD MG', '', 'no', '', '01718-870737', '01403-444472', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2699, '1243693', 'Snk', 'Md Tuhin Mia', 18, 205, 'WGSOC-1', 9, 'Vill: Bhurghata, PO: Shibganj, Thana: Shibganj, District: Bogura', '8 Fd Reg Arty', '2019-07-21', '2000-10-14', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01741-724889', '01303-538035', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL);
INSERT INTO `operators` (`id`, `personal_no`, `rank`, `name`, `cores_id`, `unit_id`, `course_cadre_name`, `formation_id`, `permanent_address`, `present_address`, `admission_date`, `birth_date`, `joining_date_awgc`, `worked_in_awgc`, `med_category_id`, `civil_edu`, `course`, `cadre`, `expertise_area`, `punishment`, `special_note`, `mobile_personal`, `mobile_family`, `created_at`, `updated_at`, `exercise_id`) VALUES
(2700, '1244184', 'Snk (GNR)', 'Al Amin', 18, 37, 'WGSOC-1', 28, 'Vill: Letarob, PO: Jashore Bazar, Thana: Shibpur, District: Narshingdi', '11 SP Reg Arty', '2020-01-12', '2000-04-12', '2025-08-07', 'no', 6, 'HSC', '', 'CLS Cadre', '', 'no', '', '01762-992400', '01734-634565', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2701, '1243525', 'Snk (GNR)', 'Md Sakib Khan', 18, 11, 'WGSOC-1', 8, 'Vill: Hayderpur, PO: Boiddo Jamtoil, Thana: Kamarkhondo, District: Shirajganj', '17 Fd Reg Arty', '2019-07-21', '2001-01-05', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01763-537357', '01723-452721', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2702, '1248275', 'Snk (OCU)', 'Md Baharul Alam', 18, 11, 'WGSOC-1', 8, 'Vill: kalkeyot, PO: Mirganj Hat, Thana: Joldhaka, District: Nilphamari', '17 Fd Reg Arty', '2023-02-05', '2003-11-24', '2025-08-07', 'no', 6, 'HSC', '', '', 'Graphic Designer, Websight Designer', 'no', '', '01319-190718', '01811-397701', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2703, '1245486', 'Snk (OCU)', 'Biddut Islam', 18, 12, 'WGSOC-1', 7, 'Vill: Gochor, PO: Arani, Thana: Bagha, District: Rajshahi', '18 Fd Reg Arty', '2020-01-26', '2001-01-28', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01785-305848', '01323-769170', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2704, '1238964', 'Snk (OCU)', 'Md Obaidul Azad', 18, 13, 'WGSOC-1', 6, 'Vill: Rampur, PO: Fotepur, Thana: Pirganj, District: Rangpur', '42 Fd Reg Arty', '2017-07-21', '1998-07-15', '2025-08-07', 'no', 6, 'HSC', '', 'ICT Cadre', '', 'no', '', '01887-544284', '01737-130013', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2705, '1245506', 'Snk (OCU)', 'Md Al Mamun', 18, 14, 'WGSOC-1', 27, 'Vill: Baghata, PO: Nouhata, Thana: Poba, District: Rajshahi', '12 Fd Reg Arty', '2020-01-24', '2001-10-01', '2025-08-07', 'no', 6, 'SSC', '', 'Signal Cadre', 'Song', 'no', '', '01615-857448', '01730-890905', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2706, '1244476', 'Snk (OCU)', 'Md Jahangir Hossain', 18, 15, 'WGSOC-1', 5, 'Vill: Putimari, PO: Alaipur, Thana: Rupsha, District: Khulna', '15 Fd Reg Arty', '2020-01-12', '2001-06-08', '2025-08-07', 'no', 6, 'BA/BSS', '', '12.7 AD MG', '', 'no', '', '01739-841839', '01928-300677', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2707, '1244574', 'Snk (GNR)', 'Md Ibrahim Hossain', 18, 16, 'WGSOC-1', 7, 'Vill: Chak Nojirpur, PO: Gopalpur, Thana: Lalpur, District: Natore', '20 Fd Reg Arty', '2020-01-12', '2001-07-07', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01750-045534', '01735-332138', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2708, '1247444', 'Snk', 'Md Shahin', 18, 17, 'WGSOC-1', 28, 'Vill: Kamarganj, PO: NSkhola, Thana: Lohagora, District: Norail', '40 Fd Reg Arty', '2022-02-04', '2002-08-01', '2025-08-07', 'no', 6, 'HSC', '', 'APC Driving Cadre', '', 'no', '', '01993-232631', '01909-228543', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2709, '1457046', 'Snk', 'Md Sabbir Ahmed', 5, 38, 'WGSOC-1', 30, 'Vill: Bohora, PO: Terosri, Thana: Doulotpur, District: Manikganj', '7 RE BN', '2020-01-26', '2002-01-04', '2025-08-07', 'no', 6, 'HSC', 'PFTC-19', '82 mm Mor Cadre', '', 'no', '', '01609-647369', '01715-220735', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2710, '1454433', 'Snk', 'Md Rakibul Hasan', 5, 39, 'WGSOC-1', 4, 'Vill: Monigram, PO: Monigram, Thana: Bagha, District: Rajshahi', '8 ENGR BN', '2018-01-21', '1998-09-05', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01786-908828', '01734-894736', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2711, '1457472', 'Snk', 'Md Sayedur Rahman', 5, 40, 'WGSOC-1', 27, 'Vill: Gala, PO: Borohatkora, Thana: Doulotpur, District: Manikganj', '9 ENGR BN', '2020-01-26', '2000-08-20', '2025-08-07', 'no', 6, 'SSC', '', 'ICT Cadre', '', 'no', '', '01732-104909', '01789-412420', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2712, '1455242', 'Snk', 'Md Jahidul Islam', 5, 41, 'WGSOC-1', 16, 'Vill: Baichail, PO: Ghatail, Thana: Ghatail, District: Tangail', '16 ECB', '2019-01-13', '1999-07-05', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01604-427357', '01645-371387', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2713, '1458626', 'Snk', 'Rabbi Miah Sagor', 5, 42, 'WGSOC-1', 13, 'Vill: Basati, PO: Basati, Thana: Kendua, District: Netrokona', '17 ECB', '2021-01-31', '2002-10-03', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01770-473290', '01407-652145', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2714, '1617974', 'Cpl', 'Md Nuruzzaman', 6, 43, 'WGSOC-1', 5, 'Vill: Soruidanga, PO: Hasimpur, Thana: Kotwali, District: Jashore', '6 Sig BN', '2013-07-14', '1995-11-05', '2025-08-07', 'no', 6, 'HSC', 'ICT NTC', '', '', 'no', '', '01764-525852', '01737-406231', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2715, '1618916', 'LCpl', 'Md Liton Ali', 6, 44, 'WGSOC-1', 28, 'Vill: Dhumdangi, PO: Dhirganj, Thana: Haripur, District: Thakurgaon', '4 Sig BN', '2016-01-23', '1998-02-01', '2025-08-07', 'no', 6, 'HSC', 'ICT Network Tech Course-23, Tower Climbing Course, VTC', 'ICT Cadre', 'Networking', 'no', '', '01774-486531', '01737-902872', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2716, '1619435', 'Snk', 'Md Jahid Hasan', 6, 45, 'WGSOC-1', 3, 'Vill: Puraton Chakla, PO: Roypur, Thana: Jibon Nagar, District: Chuadanga', '3 Sig BN', '2017-01-15', '1997-08-06', '2025-08-07', 'no', 6, 'HSC', 'CCNA, ICT NTC-32', '', '', 'no', '', '01742-735215', '01722-563146', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2717, '1249256', 'Snk', 'Md Ali Mortaza', 19, 46, 'WGSOC-1', 17, 'Vill: Bahadur, PO: Sunakorkathi, Thana: Ashaguni, District: Shatkhira', '43 SHORAD Missile Reg', '2024-03-03', '2004-09-10', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01333-560110', '01710-127033', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2718, '1237863', 'Snk (OCU)', 'Md Rasel', 19, 47, 'WGSOC-1', 18, 'Vill: Karkhanapara, PO: Kauniyar Char, Thana: Dewanganj, District: Jamalpur', '44 SHORAD Missile Reg', '2017-01-20', '1999-01-01', '2025-08-07', 'no', 6, 'HSC', 'Swimming Trg Course-10', '', '', 'no', '', '01782-811321', '01862-460408', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2719, '1247349', 'Snk', 'Md Rabbi', 19, 48, 'WGSOC-1', 18, 'Vill: Lohaliya, PO: Lohaliya Borbari, Thana: Patuakhali, District: Patuakhali', '38 AD', '2022-02-02', '2002-12-25', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01313-334145', '01722-278270', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2720, '1818801', 'Snk', 'Shahin Alom Akonda', 20, 49, 'WGSOC-1', 10, 'Vill: Dhitpur, PO: Rohimganj, Thana: Fulpur, District: Mymensingh', '36 ST BN', '2022-02-04', '2002-01-01', '2025-08-07', 'no', 6, 'HSC', '', 'CLS Cadre, BDT Cadre', '', 'no', '', '01791-353710', '01934-784644', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2721, '1818738', 'Snk (SMS)', 'Md Royal Mia', 20, 50, 'WGSOC-1', 3, 'Vill: Ful Chouki, PO: Sukorer Hat, Thana: Mithapukur, District: Rangpur', '37 ST BN', '2021-12-05', '2002-07-04', '2025-08-07', 'no', 6, 'HSC', '', 'ICT Cadre', 'Song', 'no', '', '01784-944566', '01739-691025', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2722, '4064888', 'Snk', 'Shohan', 1, 51, 'WGSOC-1', 27, 'Vill: Chandpur, PO: Roynagar, Thana: Kalukhali, District: Rajbari', '1 EB', '2019-01-27', '2001-01-05', '2025-08-07', 'no', 6, 'HSC', '', 'MG Cadre', '', 'no', '', '01781-782042', '01767-205645', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2723, '4066814', 'Snk', 'Md Raihan Hossain', 1, 52, 'WGSOC-1', 9, 'Vill: Keshobpur, PO: Chak Atitha, Thana: Naogaon Sadar, District: Naogaon', '2 EB', '2020-01-26', '2002-12-06', '2025-08-07', 'no', 6, 'HSC', '', 'CLS Cadre, ICT Cadre', '', 'no', '', '01739-788045', '01746-052670', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2724, '4067626', 'Snk', 'Fahimul Islam', 1, 53, 'WGSOC-1', 27, 'Vill: Shachail, PO: Tarail, Thana: Tarail, District: Kishoreganj', '26 EB', '2020-01-26', '2000-11-30', '2025-08-07', 'no', 6, 'HSC', '', 'MT Cadre, RL/GF Cadre', '', 'no', '', '01815-890966', '01718-526373', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2725, '4068841', 'Snk', 'Abdullah Al Noman', 1, 54, 'WGSOC-1', 10, 'Vill: Salpukuriya, PO: Dangapara, Thana: Hakimpur, District: Dinajpur', '34 EB (Mech)', '2021-01-31', '2001-07-18', '2025-08-07', 'no', 6, 'HSC', '', 'APC Driving Cadre', '1. Computer                    2. Boxing and Volleyball', 'no', '', '01768-221641', '01712-210637', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2726, '4071427', 'Snk', 'Md Shaharia Ferdous Emon', 1, 55, 'WGSOC-1', 4, 'Vill: Mosolondopur, PO: kamarkhali, Thana: Modhukhali, District: Faridpur', '56 EB', '2022-02-04', '2003-02-27', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01930-972045', '01720-801996', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2727, '4068592', 'Snk', 'Najmus Sajjad', 1, 56, 'WGSOC-1', 5, 'Vill: Dhuturhat, PO: Sorojganj, Thana: Chuadanga, District: Chuadanga', '57 EB', '2020-01-26', '2000-12-29', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01889-336185', '01716-982725', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2728, '4071318', 'Snk', 'Md Biplob Hasan', 1, 34, 'WGSOC-1', 28, 'Vill: Ratanpur, PO: Ganganj Bazar, Thana: Pirganj, District: Rangpur', '59 EB (SP BN)', '2022-02-04', '2002-02-12', '2025-08-07', 'no', 6, 'HSC', 'Bugle Course', 'ICT Course, MG Cadre', '', 'no', '', '01647-554355', '01721-518868', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2729, '4057360', 'Snk', 'Ahmad Ullah', 1, 57, 'WGSOC-1', 7, 'Vill: Par Natabari, PO: Natabari, Thana: Dhunot, District: Bogura', '61 EB', '2016-01-23', '1998-05-20', '2025-08-07', 'no', 6, 'HSC', 'MIC (UN-19)', 'ICT Cadre, RL/GF Cadre, Signal Cadre', '', 'no', '', '01769-177116', '01707-323262', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2730, '4061610', 'Snk', 'Md Ariful Islam', 1, 36, 'WGSOC-1', 6, 'Vill: Shripotipur, PO: Mahimaganj, Thana: Gobindaganj, District: Gaibandha', '62 EB', '2018-01-14', '1999-12-03', '2025-08-07', 'no', 6, 'HSC', '', 'MT Cadre', 'Computer', 'no', '', '01772-401717', '01724-164315', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2731, '4054863', 'Snk', 'Md Nazrul Islam', 1, 58, 'WGSOC-1', 3, 'Vill: Sorkarkati, PO: Gongarhat, Thana: Fulbari, District: Kurigram', '63 EB', '2014-01-26', '1996-09-25', '2025-08-07', 'no', 6, 'HSC', '', 'ICT Cadre, Mor Cadre, CTC Cadre', '', 'no', '', '01612-537342', '01791-197957', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2732, '4067213', 'Snk', 'Rouful Islam', 1, 59, 'WGSOC-1', 5, 'Vill: Melabor, PO: Melabor, Thana: Kishoreganj, District: Nilphamari', '64 EB', '2020-01-26', '2002-01-01', '2025-08-07', 'no', 6, 'HSC', '', 'MT Cadre', '', 'no', '', '01774-111824', '01305-118926', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2733, '4052470', 'Snk', 'Rasel Dewan', 1, 60, 'WGSOC-1', 5, 'Vill: Chanpara Purbason Kendro, PO: Purbogram, Thana: Rupganj, District: Narayanganj', '65 EB', '2012-07-08', '1994-06-05', '2025-08-07', 'no', 6, 'HSC', '', 'ORBIC-9 Cadre', '', 'no', '', '01819-734543', '01937-051880', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2734, '4069341', 'Snk', 'Mehedi Hasan', 1, 61, 'WGSOC-1', 6, 'Vill: Garanata, PO: Polashbari, Thana: Polashbari, District: Gaibandha', '66 EB', '2021-01-31', '2002-04-10', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01787-896249', '01747-834959', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2735, '4061879', 'Snk', 'Md  Shohanur Rahman Suhan', 1, 62, 'WGSOC-1', 6, 'Vill: Gohailbari, PO: Shimuliya, Thana: Ashuliya, District: Dhaka', '67 EB', '2018-01-21', '2000-11-05', '2025-08-07', 'no', 6, 'HSC', '', 'First Aid Cadre', 'Computer', 'no', '', '01679-613449', '01625-044476', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2736, '4070941', 'Snk', 'Md Ali Hosen', 1, 63, 'WGSOC-1', 27, 'Vill: Choto Badarkhali, PO: Gourichonna, Thana: Barguna, District: Barguna', '79 EB (SP BN)', '2022-02-04', '2003-02-03', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01874-135040', '01721-148919', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2737, '4517497', 'Snk', 'Md Ashraful Islam', 9, 64, 'WGSOC-1', 7, 'Vill: Tajnagar, PO: Tajnagar, Thana: Parbotipur, District: Dinajpur', '3 BIR', '2017-01-15', '1997-01-10', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01618-789480', '01794-976069', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2738, '4518437', 'Snk', 'Md Sumon Hosen', 9, 65, 'WGSOC-1', 12, 'Vill: Nemarpara, PO: Dighirhat, Thana: Gobindaganj, District: Gaibandha', '4 BIR', '2017-01-15', '1998-05-18', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01791-887825', '01836-646795', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2739, '4529990', 'Snk', 'Md Mubarak Hossain Shuvo', 9, 66, 'WGSOC-1', 27, 'Vill: Arazi Gongarampur, PO: Pirganj, Thana: Pirganj, District: Rangpur', '16 BIR', '2021-01-31', '2002-10-22', '2025-08-07', 'no', 6, 'HSC', '', 'AGL Cadre, Mor Cadre', '', 'no', '', '01737-922761', '01324-081075', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2740, '4519350', 'Snk', 'Md Miraz Ali', 9, 67, 'WGSOC-1', 10, 'Vill: Charvobanipur, PO: Charkharicha Bazar, Thana: Sadar, District: Mymensingh', '20 BIR', '2017-01-20', '1997-03-08', '2025-08-07', 'no', 6, 'HSC', '', 'Marksmanship Cadre, Sharp Shooter Cadre, CIED Cadre', '', 'no', '', '01969-568456', '01618-679609', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2741, '4518124', 'Snk', 'Mirajul Islam', 9, 68, 'WGSOC-1', 8, 'Vill: Krisnokathi, PO: Goma-dudhal, Thana: Bakerganj, District: Barishal', '23 BIR', '2017-01-15', '1997-09-25', '2025-08-07', 'no', 6, 'HSC', '', 'RL/GF Cadre, Metis M-1 Cadre', '', 'no', '', '01793-111938', '01321-906106', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2742, '4529573', 'Snk', 'Md Arif Hossain', 9, 69, 'WGSOC-1', 27, 'Vill: Galua Durgapur, PO: Galua Bazar, Thana: Rajapur, District: Jhalkathi', '24 BIR', '2020-01-26', '2002-01-01', '2025-08-07', 'no', 6, 'HSC', '', 'Computer Cadre, MT Cadre', '', 'no', '', '01604-920714', '01763-894696', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2743, '4527664', 'Snk', 'Md Ratol Alahi Bhuyan', 9, 70, 'WGSOC-1', 5, 'Vill: Dhakipara, PO: Gangatiya, Thana: Nandail, District: Mymensingh', '27 BIR', '2020-01-26', '2002-12-31', '2025-08-07', 'no', 6, 'HSC', '', '', 'Computer', 'no', '', '01757-543526', '01746-184411', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2744, '4517874', 'Snk', 'Md Ashraful Islam', 9, 71, 'WGSOC-1', 10, 'Vill: Shutarpara, PO: Niyamotpur, Thana: Korimganj, District: Kishoreganj', '28 BIR', '2017-01-13', '1997-06-01', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01310-404200', '01717-781045', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2745, '4523143', 'Snk', 'Noushad Jahan Prince', 9, 72, 'WGSOC-1', 10, 'Vill: Gor Bisudiya, PO: Mesera, Thana: Hosenpur, District: Kishoreganj', '29 BIR', '2018-01-21', '1999-11-05', '2025-08-07', 'no', 6, 'HSC', '', 'RL/GF Cadre', '1. Computer                    2. Football and Basketball', 'no', '', '01725-760756', '01747-069968', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2746, '4530764', 'Snk', 'Md Ariful Islam', 9, 73, 'WGSOC-1', 7, 'Vill: Gopalpur, PO: Gopalpur, Thana: Shaturiya, District: Manikganj', '30 BIR', '2021-01-31', '2001-10-18', '2025-08-07', 'no', 6, 'HSC', '', 'RL/GF Cadre', '', 'no', '', '01876-768746', '01768-340649', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2747, '4521522', 'Snk', 'Sajib', 9, 74, 'WGSOC-1', 7, 'Vill: Paschimsonkanda, PO: Bottola Bazar, Thana: Shribordi, District: Sherpur', '32 BIR', '2018-01-14', '1998-12-15', '2025-08-07', 'no', 6, 'HSC', 'MT Course', 'RL/GF Cadre, MT Cadre', '', 'no', '', '01731-768616', '01980-892664', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2748, '4516668', 'Snk', 'Md Helal Uddin', 9, 20, 'WGSOC-1', 5, 'Vill: Juidandi, PO: Barumchora, Thana: Anowara, District: Chittagong', '34 BIR', '2016-01-23', '1997-12-30', '2025-08-07', 'no', 6, 'HSC', '', 'SP Guard Trg-46', '', 'no', '', '01824-763384', '01602-380648', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2749, '4520998', 'Snk', 'Md Sagor Ali', 9, 75, 'WGSOC-1', 6, 'Vill: Bahadurpur, PO: Bahadurpur, Thana: Pangsa, District: Rajbari', '35 BIR (SP BN)', '2017-07-23', '1997-12-27', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01714-824385', '01716-858341', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2750, '4535525', 'Snk', 'Md Sajib Molla', 9, 76, 'WGSOC-1', 5, 'Vill: Boyra, PO: Amada, Thana: Lohagora, District: Norail', '42 BIR', '2024-03-03', '2005-12-29', '2025-08-07', 'no', 6, 'HSC', '', '', '', 'no', '', '01312-831752', '01404-218350', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2751, '4534772', 'Snk', 'Sifat Ali', 9, 77, 'WGSOC-1', 6, 'Vill: Malihata, PO: Budhol, Thana: Sadar, District: Brahmanbaria', '43 BIR', '2023-03-02', '2003-12-25', '2025-08-07', 'no', 6, 'HSC', '', 'RL/GF Cadre', '', 'no', '', '01306-957864', '01918-208065', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2752, '2207851', 'Snk (CLK)', 'Md Rakib Hossain', 12, 78, 'WGSOC-1', 6, 'Vill:Charmonai, PO: Budhainaga, Thana: Kotwali, District: Barishal', '510 DOC', '2019-01-24', '2000-07-25', '2025-08-07', 'no', 6, 'HSC', '', '', 'Kabadi and Football', 'no', '', '017139-716689', '01765-356225', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2753, '1007279', 'LCpl', 'Md Nadim Al Hasnat', 17, 79, 'Trg On AWGSS-9/2022', 6, 'Vill: Noirpukurpar, PO: Ghasipukurpar, Thana: Munshiganj, District: Munshiganj', '26 Horse', '2014-10-08', '1996-11-10', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01703-962255', '01704-564840', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2754, '1008264', 'Snk', 'Md Monir Hossen', 17, 203, 'Trg On AWGSS-9/2022', 27, 'Vill: Ramchandrapur, PO: Doulotpur, Thana: Doulotpur, District: Manikganj', '16 Cavalory', '2018-07-22', '2000-10-09', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01865-452626', '01987-696596', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2755, '1231063', 'LCpl', 'Md Juwel Rana', 18, 80, 'Trg On AWGSS-9/2022', 9, 'Vill: Pachbaria, PO: Notun Upashahar, Thana: Kotwali, District: Jashore', '2 Fd Reg Arty', '2008-01-13', '1990-05-16', '2022-01-22', 'no', 6, 'HSC', '', '', 'Computer', 'no', '', '01749-389697', '01792-130761', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2756, '1235708', 'Snk (OCU)', 'Md Masum Billah', 18, 81, 'Trg On AWGSS-9/2022', 3, 'Vill: Chonkanda, PO: Kashiganj, Thana: Trishal, District: Mymensingh', '4 Fd Reg Arty', '2015-01-25', '1996-07-12', '2022-01-22', 'no', 6, 'BA/BSS', '', 'RP Cadre', '', 'no', '', '01775-866972', '01745-631623', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2757, '1237805', 'Snk (OCU)', 'Md Shohel Rana', 18, 82, 'Trg On AWGSS-9/2022', 10, 'Vill: Arpara, PO: Kamarkhali, Thana: Modhukhali, District: Faridpur', '19 Med Reg Arty', '2017-01-22', '1997-12-30', '2022-01-22', 'no', 6, 'SSC', '', '', '', 'no', '', '01880-148566', '01846-460836', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2758, '1238169', 'Snk (OCU)', 'Md Shahar Ali', 18, 12, 'Trg On AWGSS-9/2022', 5, 'Vill: Chakhoridaspur, PO: Birampur, Thana: Birampur, District: Dinajpur', '18 Fd Reg Arty', '2017-01-22', '1999-03-18', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01776-847819', '01774-471863', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2759, '1238666', 'Snk (OCU)', 'Md Mofasin', 18, 37, 'Trg On AWGSS-9/2022', 28, 'Vill: Bahram khanpara, PO: Shukhiya, Thana: Pakundiya, District: Kishoreganj', '11 SP Reg Arty', '2017-01-22', '1997-10-31', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01714-598138', '01768-286528', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2760, '1239364', 'Snk (OCU)', 'Md Hasan Hawlader', 18, 83, 'Trg On AWGSS-9/2022', 8, 'Vill: Pasribuniya, PO: Pasribuniya, Thana: Vandariya, District: Pirojpur', '41 Med Reg Arty', '2018-01-14', '2000-06-10', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01710-878168', '01721-455950', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2761, '1240271', 'Snk', 'Shohel Rana', 18, 84, 'Trg On AWGSS-9/2022', 4, 'Vill: Purbomiyapara, PO: Longkarchar, Thana: Dewanganj, District: Jamalpur', '46 Div Locating Bty', '2018-01-21', '1997-12-30', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01938-778544', '01955-312179', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2762, '1447035', 'LCpl', 'Md Mahabub Hosen', 5, 85, 'Trg On AWGSS-9/2022', 6, 'Vill: Arjunpur, PO: Bigro Halsa, Thana: Natore, District: Natore', '22 ENGR BN', '2006-07-02', '1987-06-10', '2022-01-22', 'no', 6, 'HSC', '', '', '', '1X Red Entry      28 Days RI', '', '01725-831311', '01732-989661', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2763, '1621032', 'Snk (DVR)', 'Md Shaon Bapery', 6, 43, 'Trg On AWGSS-9/2022', 7, 'Vill: Thantoli, PO: Madaripur, Thana: Madaripur, District: Madaripur', '6 Sig BN', '2018-01-19', '1998-12-28', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01797-262301', '01917-337725', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2764, '1232145', 'Cpl (OCU)', 'Md Ruhul Amin', 19, 26, 'Trg On AWGSS-9/2022', 18, 'Vill: Rampur, PO: Rampur, Thana: Burichang, District: Cumilla', '21 AD', '2009-07-05', '1990-08-30', '2022-01-22', 'no', 6, 'HSC', '', 'Computer Cadre', 'Compuer', 'no', '', '01740-334349', '01798-699716', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2765, '1241864', 'Snk (OCU)', 'Md Meherab Hossen', 19, 27, 'Trg On AWGSS-9/2022', 17, 'Vill: Nirankuri, PO: Atpukurhat, Thana: Fulbari, District: Dinajpur', '5 AD', '2019-01-13', '1999-11-07', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01608-826567', '01722-828552', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2766, '4045070', 'LCpl', 'Md Shoriful Islam', 1, 86, 'Trg On AWGSS-9/2022', 8, 'Vill: Sadhu, PO: Mirbag, Thana: Kauniya, District: Rangpur', '16 EB', '2006-06-18', '1987-12-10', '2022-01-22', 'no', 6, 'BA/BSS', '', 'Computer Cadre', 'Computer', 'no', '', '01723-450987', '01714-333600', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2767, '4048334', 'Snk', 'Md Mostagir Hossen', 1, 87, 'Trg On AWGSS-9/2022', 7, 'Vill: Anantapur, PO: Aludbariya, Thana: Jibonnagar, District: Chuadanga', '3 EB', '2008-07-13', '1990-09-17', '2022-01-22', 'no', 6, 'HSC', '', 'ICT Cadre', '', 'no', '', '01747-457936', '01904-871240', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2768, '4049540', 'Snk', 'Md Juwel Babu', 1, 88, 'Trg On AWGSS-9/2022', 7, 'Vill: Binodnagar, PO: Binodnagar, Thana: Nobabganj, District: Dinajpur', '6 EB', '2010-01-10', '1991-02-15', '2022-01-22', 'no', 6, 'HSC', '', 'Computer Cadre', 'Computer', 'no', '', '01746-959135', '01774-484426', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2769, '4057871', 'Snk', 'Md Majedur Rahman', 1, 51, 'Trg On AWGSS-9/2022', 10, 'Vill: Durgapur, PO: Potol, Thana: Kalihati, District: Tangail', '1 EB', '2016-01-23', '1997-05-04', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01782-125350', '01735-987764', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2770, '4058228', 'Snk', 'Md Arafat Hossen', 1, 89, 'Trg On AWGSS-9/2022', 4, 'Vill: Purbobejgram, PO: Naodabas, Thana: Hatibanda, District: Lalmonirhat', '18 EB', '2016-07-17', '1997-10-10', '2022-01-22', 'no', 6, 'HSC', 'ICT & NTC-21', 'Signal Cadre, ICT Cadre', 'Computer', 'no', '', '01759-806476', '01723-053910', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2771, '4059629', 'Snk', 'Md Jahidul Islam', 1, 90, 'Trg On AWGSS-9/2022', 27, 'Vill: Nolchopa, PO: Pachtikobhi, Thana: Ghatail, District: Ghatail', '24 EB', '2017-01-22', '1997-02-01', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01681-937795', '01721-204253', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2772, '4059738', 'Snk', 'Md Rakibul Islam', 1, 61, 'Trg On AWGSS-9/2022', 6, 'Vill: Sonatola, PO: Chotrakachari, Thana: Pirganj, District: Rangpur', '66 EB', '2017-01-22', '1999-04-15', '2022-01-22', 'no', 6, 'HSC', '', 'Compute and ICT Cadre', '', 'no', '', '01783-166178', '01722-626049', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2773, '4060871', 'Snk', 'Md Sagor Hossen', 1, 91, 'Trg On AWGSS-9/2022', 4, 'Vill: Shahapur, PO: Jamalganj, Thana: Joypurhat, District: Joypurhat', '25 EB', '2018-01-14', '1999-02-15', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01642-140642', '01771-212363', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2774, '4061441', 'Snk', 'Md Emam Hossen', 1, 92, 'Trg On AWGSS-9/2022', 19, 'Vill: Hariapara, PO: Amgachi, Thana: Durgapur, District: Rajshahi', '21 EB', '2018-01-14', '1999-10-28', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01705-298307', '01919-452996', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2775, '4062097', 'Snk', 'Md Soikot Rahman', 1, 93, 'Trg On AWGSS-9/2022', 28, 'Vill: Ghatpar, PO: Birampur, Thana: Birampur, District: Birampur', '12 EB', '2018-01-21', '1999-07-11', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01304-062097', '01780-643101', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2776, '4063052', 'Snk', 'Md Jahid Hasan Mun', 1, 21, 'Trg On AWGSS-9/2022', 3, 'Vill: Doulotpur, PO: Khordokomorpur, Thana: Sadullapur, District: Gaibandha', '8 EB', '2018-01-21', '1998-07-08', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01883-742583', '01712-982175', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2777, '4063245', 'Snk', 'Kamruzzaman', 1, 94, 'Trg On AWGSS-9/2022', 9, 'Vill: Kaydapara, PO: Ostodharbajar, Thana: Sadar, District: Mymensingh', '10 EB', '2018-07-22', '2000-12-25', '2022-01-22', 'no', 6, 'HSC', 'Computer Office App (Civil Course), Level-2', '', 'Computer', 'no', '', '01700-677910', '01788-906891', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2778, '4507986', 'Snk', 'Arbind Das', 9, 95, 'Trg On AWGSS-9/2022', 8, 'Vill: Ramnagar, PO: Darshana, Thana: Damurhuda, District: Chuadanga', '33 BIR', '2008-01-13', '1988-11-05', '2022-01-22', 'no', 6, 'HSC', 'DBC-08, DMC-1, MRIC-16', 'ICT Cadre', '', 'no', '', '01737-445483', '01915-068833', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2779, '4508446', 'LCpl', 'Md Rajib Hosen', 9, 77, 'Trg On AWGSS-9/2022', 6, 'Vill: Charpara, PO: Chatmohor, Thana: Chatmohor, District: Pabna', '43 BIR', '2008-07-14', '1990-05-15', '2022-01-22', 'no', 6, 'HSC', 'ATGWC-4, LEVEL-1 Course, LEVEL 2  Course, MIC-1', 'Signal Cadre, RL/GF Cadre', 'Computer', 'no', '', '01557-159565', '01739-339352', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2780, '4509478', 'Snk', 'Md Oli Ullah', 9, 75, 'Trg On AWGSS-9/2022', 6, 'Vill: Alalpur, PO: Nolbaid, Thana: Kuriyachor, District: Kishoreganj', '35 BIR (SP BN)', '2009-07-05', '1990-10-30', '2022-01-22', 'no', 6, 'HSC', '', 'Computer Cadre', '', 'no', '', '01767-951147', '01777-423867', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2781, '4516991', 'Snk', 'Md Mokbul Hossain', 9, 96, 'Trg On AWGSS-9/2022', 10, 'Vill: Madla, PO: Shahjadpur, Thana: Shahjadpur, District: Shirajganj', '22 BIR', '2016-07-17', '1997-10-15', '2022-01-22', 'no', 6, 'HSC', '', 'ATW Cadre, RL/GF Cadre, ICT Cadre', 'Computer', 'no', '', '01760-637682', '01726-140206', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2782, '4517327', 'Snk', 'Md Abdul Alim', 9, 97, 'Trg On AWGSS-9/2022', 9, 'Vill: Gondobpur, PO: Anuhola, Thana: Tangail, District: Tangail', '17 BIR (Mech)', '2016-07-17', '1997-07-15', '2022-01-22', 'no', 6, 'HSC', '', 'Compute and ICT Cadre', '', 'no', '', '01870-968369', '01762-133318', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2783, '4518926', 'Snk', 'Md Sabbir Hossen', 9, 98, 'Trg On AWGSS-9/2022', 8, 'Vill: South Baniapara, PO: Baniapara, Thana: Joypurhat, District: Joypurhat', '31 BIR', '2017-01-20', '1999-07-15', '2022-01-22', 'no', 6, 'HSC', '', 'Computer Cadre', '', 'no', '', '01784-726449', '01725-020901', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2784, '4519115', 'Snk', 'Md Sohag Islam', 9, 99, 'Trg On AWGSS-9/2022', 10, 'Vill: Purbo Parpugi, PO: Libganj, Thana: Sadar, District: Thakurgaon', '25 BIR (SP BN)', '2017-01-20', '1998-10-08', '2022-01-22', 'no', 6, 'HSC', '', '', 'Computer', 'no', '', '01786-946090', '01732-990153', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2785, '4519310', 'Snk', 'Ashraful Al Amin', 9, 76, 'Trg On AWGSS-9/2022', 5, 'Vill: Dorichorkhajuriya, PO: Dorichorkhajuriya, Thana: Mehendiganj, District: Barishal', '42 BIR', '2017-01-20', '1997-07-13', '2022-01-22', 'no', 6, 'HSC', '', 'Computer Cadre', '', 'no', '', '01723-586307', '01710-874607', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2786, '4520035', 'Snk', 'Md Habibur Rahman', 9, 100, 'Trg On AWGSS-9/2022', 3, 'Vill: Jagannathpur, PO: Shri Ratanpur, Thana: Damurhuda, District: Chuadanga', '26 BIR', '2017-01-20', '1997-11-12', '2022-01-22', 'no', 6, 'HSC', '', '', 'Computer', 'no', '', '01786-233447', '01959-044105', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2787, '4520149', 'Snk', 'Sheikh Yasar Arafat', 9, 101, 'Trg On AWGSS-9/2022', 4, 'Vill: Fulbari, PO: Nokipur, Thana: Shamnagar, District: Satkhira', '8 BIR', '2017-07-13', '1998-12-15', '2022-01-22', 'no', 6, 'HSC', '', 'MG Cadre', '', 'no', '', '01991-878394', '01758-833274', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2788, '2207038', 'Snk (SMT)', 'Kazi Nadim Ahmed', 12, 102, 'Trg On AWGSS-9/2022', 9, 'Vill: Pankharchar, PO: Mukimpur, Thana: Lohagora, District: Norail', 'ORDEP Jashore', '2017-01-20', '1999-02-03', '2022-01-22', 'no', 6, 'HSC', '', '', '', 'no', '', '01786-919591', '01925-343623', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2789, '2207346', 'Snk (CLK)', 'Md Shajedul Islam', 12, 103, 'Trg On AWGSS-9/2022', 11, 'Vill: Jharaborsha, PO: Dakbangla, Thana: Shaghata, District: Gaibandha', 'CMTD', '2018-01-19', '1999-02-10', '2022-01-22', 'no', 6, 'HSC', 'Level-1 Course', '', '', 'no', '', '01764-749366', '01721-595257', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2790, '1008665', 'Snk (GNR)', 'Md Nayem Ali', 17, 104, 'Trg On AWGSS-10/2022', 3, 'Vill: Keshobpur, PO: Panihar, Thana: Godagari, District: Rajshahi', '4 Horse', '2019-01-27', '1999-05-12', '2022-08-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01313-342935', '01713-769242', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2791, '1229120', 'Cpl (GNR)', 'Md Shahin Miya', 18, 14, 'Trg On AWGSS-10/2022', 27, 'Vill: Maigali, PO: Ghior, Thana: Ghior, District: Manikganj', '12 Fd Reg Arty', '2006-06-16', '1988-06-13', '2022-08-18', 'no', 6, 'HSC', '', 'RL/GF Cadre, Mor Cadre', '', 'no', '', '01723-658743', '01918-136933', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2792, '1235287', 'Snk (OCU)', 'Md Shajib', 18, 12, 'Trg On AWGSS-10/2022', 5, 'Vill: Purbo Hajar Bigha, PO: Charakgachia, Thana: Barguna, District: Barguna', '18 Fd Reg Arty', '2014-08-10', '1996-01-01', '2022-08-20', 'no', 6, 'BA/BSS', '', '', '', 'no', '', '01737-979879', '01726-767980', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2793, '1241521', 'Snk', 'Md Raihan Ali', 18, 13, 'Trg On AWGSS-10/2022', 6, 'Vill: Dabariya, PO: Shahajadpur, Thana: Shajadpur, District: Sirajganj', 'OSL', '2019-01-11', '2000-10-12', '2022-08-20', 'no', 6, 'HSC', '', 'Signal Cadre, ICT Cadre', 'Computer And Network', 'no', '', '01864-947940', '01728-315250', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2794, '1242326', 'Snk', 'Md Tuhin Molla', 18, 31, 'Trg On AWGSS-10/2022', 28, 'Vill: Rasulpur, PO: Rasulpur, Thana: Gojariya, District: Munshiganj', '35 Div Locating Bty', '2019-01-27', '2001-07-01', '2022-08-20', 'no', 6, 'Dakhil', '', '', '', 'no', '', '01743-578222', '01917-254700', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2795, '1447451', 'LCpl', 'Sohel Rana', 5, 105, 'Trg On AWGSS-10/2022', 7, 'Vill: Enayet Nagar, PO: Enayetnagar, Thana: Kalkini, District: Madaripur', '1 ENGR BN', '2007-01-14', '1988-07-03', '2022-08-20', 'no', 6, 'HSC', 'NCOS Course', '', '', 'no', '', '01731-866956', '', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2796, '1456141', 'Snk', 'Touhidul Islam Nabil', 5, 105, 'Trg On AWGSS-10/2022', 7, 'Vill: Pailam, PO: Jamira Para, Thana: Valuka, District: Mymensingh', '1 ENGR BN', '2019-01-27', '2000-12-30', '2022-08-20', 'no', 6, 'HSC', '', 'ICT Cadre', 'Computer', 'no', '', '01622-717374', '01827-745206', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2797, '1620752', 'Snk', 'Abdullah Abu Wasif Limon', 6, 106, 'Trg On AWGSS-10/2022', 5, 'Vill: Khodabaspur, PO: Korkodi, Thana: Modhukhali, District: Faridpur', '8 Sig Bn', '2018-01-21', '1998-11-28', '2022-08-18', 'no', 6, 'HSC', 'Computer Office Pogramme Course', '', 'Computer', 'no', '', '01538-162737', '01793-688056', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2798, '1817697', 'Snk (SMS)', 'Md Shipon Sorkar', 20, 107, 'Trg On AWGSS-10/2022', 7, 'Vill: Ronos, PO: Katakhali, Thana: Sadar, District: Munshiganj', '32 ST BN', '2020-01-26', '2001-06-26', '2022-08-20', 'no', 6, 'SSC', '', 'ICT Cadre', 'Computer', 'no', '', '01646-413820', '01949-379978', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2799, '4061686', 'Snk', 'Marzanul Islam Ramim', 1, 108, 'Trg On AWGSS-10/2022', 9, 'Vill: Islampur, PO: Khakbuniya, Thana: Barguna, District: Barguna', '19 EB (SP BN)', '2018-01-10', '1999-08-06', '2022-08-18', 'no', 6, 'HSC', '', 'GSR Cadre, ATW Cadre', '', '1X Black Entry    1X Increment', '', '01704-519867', '01735-9947040', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2800, '4047204', 'LCpl', 'Md Rokon Miya', 1, 109, 'Trg On AWGSS-10/2022', 4, 'Vill: Nalikhali, PO: Chechuwa Bazar, Thana: Muktagacha, District: Mymensingh', '27 EB', '2007-07-08', '1988-09-21', '2022-08-18', 'no', 6, 'HSC', 'SAC-72', 'ICT Cadre, DPT Cadre', '', 'no', '', '01735-976908', '01725-859080', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2801, '4059560', 'Snk', 'Md Nazmul Islam', 1, 55, 'Trg On AWGSS-10/2022', 7, 'Vill: North Sharifpur, PO: Abdullah Miya Bari, Thana: Sadar, District: Noakhali', 'OCL', '2017-01-22', '1997-11-10', '2022-08-18', 'no', 6, 'HSC', '', 'Marksmanship Cadre, Signal Cadre', '', 'no', '', '01641-433294', '01726-436054', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2802, '4049881', 'Snk', 'Md Sohel Hasem', 1, 56, 'Trg On AWGSS-10/2022', 7, 'Vill: Khoirabad, PO: Gongamondol, Thana: Debiddar, District: Cumilla', '57 EB', '2010-07-11', '1991-07-15', '2022-08-18', 'no', 6, 'BA/BSS', 'MIC Course', 'Signal Cadre, Computer Cadre', 'Computer Office Pogramme', '1X Red Entry      14Xdays RI', '', '01626-336766', '01533-141771', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2803, '4061884', 'Snk', 'Shakhawat Hossen', 1, 110, 'Trg On AWGSS-10/2022', 3, 'Vill: Poduwa, PO: Boliya, Thana: Hajiganj, District: Chandpur', '58 EB', '2018-01-21', '2000-11-01', '2022-08-18', 'no', 6, 'HSC', 'ICT NTC Course-24', '', 'Computer Office Pogramme', 'no', '', '01849-584376', '01829-235546', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2804, '4062923', 'Snk', 'Md Miraz Ahmed', 1, 111, 'Trg On AWGSS-10/2022', 4, 'Vill: Bheemsahar, PO: Vendabari, Thana: Pirganj, District: Rangpur', '60 EB', '2018-01-21', '2000-02-15', '2022-08-18', 'no', 6, 'HSC', '', 'MG Cadre', '', 'no', '', '01954-807884', '01719-181603', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2805, '40522588', 'Snk', 'Md Shakil Khan', 9, 64, 'Trg On AWGSS-10/2022', 7, 'Vill: Paniya, PO: Obaidurnagar, Thana: Kaliganj, District: Shatkhira', '3 BIR', '2018-01-21', '1999-09-23', '2022-08-18', 'no', 6, 'SSC', '', 'ICT Cadre, RL/GF Cadre', '', 'no', '', '01872-838021', '01731-597764', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2806, '4517496', 'Snk', 'Md Redwanul Haque', 9, 65, 'Trg On AWGSS-10/2022', 12, 'Vill: Modonkhali, PO: Kadirabad, Thana: Pirganj, District: Rangpur', '4 BIR', '2017-01-13', '1998-12-15', '2022-08-18', 'no', 6, 'HSC', '', 'Metis M-1 Cadre', '', 'no', '', '01784-034665', '01780-886927', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2807, '4518860', 'Snk', 'Md Shajib Ali', 9, 67, 'Trg On AWGSS-10/2022', 10, 'Vill: Doliyarpur, PO: Gopalpur, Thana: Damurhuda, District: Chuwadanga', 'PGR', '2017-01-20', '1997-10-12', '2022-08-18', 'no', 6, 'HSC', '', 'ICT Cadre, CPR Cadre', '', 'no', '', '01855-535835', '01984-914418', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2808, '4521933', 'Snk', 'Md Akram Hossen', 9, 68, 'Trg On AWGSS-10/2022', 8, 'Vill: Horipur, PO: Kamariya Bazar, Thana: Tarakanda, District: Mymensingh', '23 BIR', '2018-01-14', '1998-01-15', '2022-08-18', 'no', 6, 'HSC', '', 'PNR Cadre', '', 'no', '', '01734-402310', '01703-395533', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2809, '4509474', 'Snk', 'Md Joshim Uddin', 9, 70, 'Trg On AWGSS-10/2022', 5, 'Vill: Jolusha, PO: Abidnagar, Thana: Dhormopasha, District: Sunamganj', '27 BIR', '2009-07-05', '1992-03-01', '2022-08-18', 'no', 6, 'BA/BSS', '', 'ATW Cadre, ATGW Cadre, Rp Cadre, Marksmanship Cadre', '', 'no', '', '01728-666314', '01882-112521', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2810, '4511250', 'Snk', 'Al Amin', 9, 71, 'Trg On AWGSS-10/2022', 7, 'Vill: Kushakanda, PO: Sukhiya, Thana: Pakundiya, District: Kishoreganj', '28 BIR', '2012-01-08', '1994-10-08', '2022-08-18', 'no', 6, 'BA/BSS', '', 'Mor Cadre, Computer Cadre', 'Computer', 'no', '', '01764-779202', '01752-248476', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2811, '1008463', 'Snk', 'Shaju Khan', 17, 203, 'Trg On AWGSS-11/2023', 27, 'Vill: Hatibanda, PO: Hatibanda, Thana: Shokhipur, District: Tangail', '16 Cavalory', '2019-01-11', '1999-03-20', '2023-07-20', 'no', 6, 'SSC', '', '', '', 'no', '', '01703-392419', '01859-297300', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2812, '1006393', 'Cpl', 'Kazi Sadi Mahmud', 17, 202, 'Trg On AWGSS-11/2023', 4, 'Vill: Tarail, PO: Tarail, Thana: Kasiyani, District: Gopalganj', '12 Lancher', '2008-07-13', '1990-12-25', '2023-07-20', 'no', 6, 'SSC', 'DIC', '', '', '1X Red Entry               3 Year Increment Cutting', '', '01912-616218', '01736-232166', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2813, '1239904', 'Snk', 'Md Mahmud Hasan', 18, 175, 'Trg On AWGSS-11/2023', 7, 'Vill: Shimuliya, PO: Dargatlahat, Thana: Joypurhat, District: Joypurhat', 'Death by bike Accident', '2018-01-21', '1998-08-25', '2023-07-20', 'no', 6, 'HSC', '', 'CLS Cadre', '', 'no', '', '01609-817142', '01752-842993', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2814, '1234145', 'LCpl', 'Mehedi Hasan', 18, 81, 'Trg On AWGSS-11/2023', 3, 'Vill: Palpara, PO: Fularpara, Thana: Muksudpur, District: Gopalganj', '4 Fd Reg Arty', '2012-07-08', '1994-07-10', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01740-368626', '01763-759358', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2815, '1236648', 'Snk', 'Md Sohag Hosen Mamun', 18, 113, 'Trg On AWGSS-11/2023', 4, 'Vill: Mesera, PO: Mesera, Thana: Hosenpur, District: Kishoreganj', '7 Fd Reg Arty', '2016-01-23', '1997-07-01', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01773-128808', '01714-198086', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2816, '1244557', 'Snk', 'Md Nurunnabi Nishad', 18, 114, 'Trg On AWGSS-11/2023', 28, 'Vill: Ronchondi Dalalpara, PO: Ronchondi, Thana: Kishoreganj, District: Nilphamari', '10 Med Reg Arty', '2020-01-10', '2001-06-04', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01318-641377', '01752-298640', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2817, '1238557', 'Snk', 'Md Robiul Islam', 18, 115, 'Trg On AWGSS-11/2023', 5, 'Vill: Shrirampur, PO: Nachol, Thana: Nachol, District: Chapainobabganj', '22 Fd Reg Arty', '2017-02-01', '1999-02-26', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01310-133967', '01738-979431', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2818, '1237576', 'Snk', 'Md Touhidul Islam', 18, 83, 'Trg On AWGSS-11/2023', 8, 'Vill: Hajipur, PO: Kolom, Thana: Singra, District: Natore', '41 Med Reg Arty', '2017-01-13', '1998-04-09', '2023-07-20', 'no', 6, 'HSC', '', 'ICT Cadre', '', 'no', '', '01720-857795', '01715-167191', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2819, '1243446', 'Snk', 'Rasel Babu', 18, 116, 'Trg On AWGSS-11/2023', 6, 'Vill: Khapur, PO: Usti, Thana: Potnitola, District: Naogaon', '49 Fd Reg Arty', '2019-07-21', '2001-06-06', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01764-240671', '01761-239716', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2820, '1243570', 'Snk', 'Md Tajul Islam', 18, 117, 'Trg On AWGSS-11/2023', 27, 'Vill: kanuriya, PO: kanuriya, Thana: Muksudpur, District: Gopalganj', '1 Fd Reg Arty', '2019-07-20', '2000-06-01', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01732-770242', '01798-224218', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2821, '1446412', 'Sgt', 'Mohammad Adnan Hanif', 5, 33, 'Trg On AWGSS-11/2023', 9, 'Vill: Maijpara, PO: Khutakhali, Thana: Chakriya, District: Cox\'s Bazar', '3 ENGR BN', '2006-01-01', '1988-07-10', '2023-07-20', 'no', 6, 'BSS', 'PTC Course, DIC Course, UCC Course, CTC Course, SAC course, Scuba Diving, ACC', '', '', 'no', '', '01812-000696', '01818-124924', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2822, '1456326', 'Snk', 'Md Tanvir Alam', 5, 118, 'Trg On AWGSS-11/2023', 8, 'Vill: Charrupur, PO: Pakshi, Thana: Iswardi, District: Pabna', '2 ENGR BN', '2019-01-27', '1999-09-25', '2023-07-20', 'no', 6, 'SSC', '', 'ICT Cadre', '', 'no', '', '01790-400051', '01711-317956', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2823, '1620074', 'Snk', 'Md Sayeduzzaman', 6, 119, 'Trg On AWGSS-11/2023', 8, 'Vill: Sundarganj, PO: Sundarganj, Thana: Sundarganj, District: Gaibandha', '5 Sig Bn', '2017-01-22', '1997-08-30', '2023-07-20', 'no', 6, 'SSC', '', '', '', 'no', '', '01793-85589', '01521-423805', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2824, '1619779', 'Snk', 'Md Abu Horaira', 6, 120, 'Trg On AWGSS-11/2023', 4, 'Vill: Shamkur, PO: Chinatola, Thana: Monirampur, District: Jashore', '9 Sig Bn', '2017-01-22', '1997-11-11', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01983-125082', '01982-727959', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2825, '1246374', 'Snk', 'Md Rahat Miya', 19, 47, 'Trg On AWGSS-11/2023', 7, 'Vill: Uttar Dapuniya, PO: kandapara, Thana: Sadar, District: Mymensingh', '44 SHORAD Missile Reg', '2021-01-31', '2002-08-12', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01860-815499', '01982-107311', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2826, '2208222', 'Snk', 'Habibul Bashar', 20, 121, 'Trg On AWGSS-11/2023', 11, 'Vill: Hariadeyara, PO: Hariadeyara, Thana: Jhikargacha, District: Jashore', 'COD, Dhaka', '2021-01-31', '2003-04-18', '2023-07-20', 'no', 6, 'HSC', '', 'ATGW Cadre', '', 'no', '', '01772-349171', '01926-325265', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2827, '4047810', 'Cpl', 'Noor Mohammad Palash', 1, 35, 'Trg On AWGSS-11/2023', 3, 'House no: 30, Road: 01/B, Block: D, Mirpur, Dhaka', '29 EB (SP BN)', '2008-01-14', '1989-10-20', '2023-07-20', 'no', 6, 'HSC', 'ATGW - 3, ICT NTC-19', '', '1. OS                                 2. Routing                            3. Windows Server                  4. Troubleshooting', 'no', '', '01914-331734', '01933-585897', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2828, '4057123', 'Snk', 'Md Juwel Rana', 1, 122, 'Trg On AWGSS-11/2023', 28, 'Vill: Sonapur, PO: Mujibnagar, Thana: Mujibnagar, District: Meherpur', '7 EB', '2016-01-23', '1997-05-07', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01791-623534', '01792-107774', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2829, '4071202', 'Snk', 'Sabbir Hossain', 1, 123, 'Trg On AWGSS-11/2023', 27, 'Vill: Momin, PO: Jorsoira, Thana: Rajarhat, District: Kurigram', '9 EB', '2022-02-04', '2002-05-10', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01318-903946', '01742-992326', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2830, '4064366', 'Snk', 'Md Sahinul Islam', 1, 124, 'Trg On AWGSS-11/2023', 7, 'Vill: Poschim Nij Kalikapur, PO: Bottoli Bazar, Thana: Porsuram, District: Feni', '11 EB', '2019-01-13', '1999-05-14', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01876-942814', '01812-185838', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2831, '4066275', 'Snk', 'Johirul Islam Sakil', 1, 125, 'Trg On AWGSS-11/2023', 9, 'Vill: Norton, PO: Norton, Thana: Kulaura, District: Moulvibazar', '14 EB', '2019-01-27', '2000-09-13', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01313-166275', '01646-473591', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2832, '4058754', 'Snk', 'Md Saiful Islam', 1, 126, 'Trg On AWGSS-11/2023', 4, 'Vill: Charkoishal, PO: Hatiya, Thana: Hatiya, District: Noakhali', '15 EB (Mech)', '2017-01-15', '1996-12-31', '2023-07-20', 'no', 6, 'HSC', '', 'ATGW Cadre', '', 'no', '', '01758-290933', '01640-564244', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2833, '4051858', 'Snk', 'Md Shahin Alam', 1, 127, 'Trg On AWGSS-11/2023', 28, 'Vill: Chandkhali, PO: South Chandkhali, Thana: Patuakhali, District: Patuakhali', '17 EB', '2012-01-08', '1993-01-26', '2023-07-20', 'no', 6, 'HSC', 'BPC Course', 'ORBIC Cadre, ICT Cadre', '', 'no', '', '01775-515894', '01733-196484', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2834, '4064431', 'Snk', 'Ashikur Rahman', 1, 128, 'Trg On AWGSS-11/2023', 22, 'Vill: Kazirchar, PO: Boiragir Char, Thana: Kotiyadi, District: Kishoreganj', '28 EB', '2019-01-13', '1999-09-11', '2023-07-20', 'no', 6, 'HSC', '', '', '1. Graphic Design              2. Multimedia Programming', 'no', '', '01316-944173', '01734-662533', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2835, '4065631', 'Snk', 'Sagor Miya', 1, 129, 'Trg On AWGSS-11/2023', 9, 'Vill: Bujruk Bisnopur, PO: Bujruk Bisnopur, Thana: Polashbari, District: Gaibandha', '20 EB', '2019-01-25', '2000-10-29', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01792-982471', '01310-132020', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2836, '4065029', 'Snk', 'Md Mohiuddin Hridoy', 1, 130, 'Trg On AWGSS-11/2023', 12, 'Vill: Poil, PO: Poil, Thana: Hobiganj, District: Hobiganj', '23 EB', '2019-01-27', '2001-09-25', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01737-943478', '01777-800156', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2837, '4063081', 'Snk', 'Md Abu Bakkar Siddique', 1, 53, 'Trg On AWGSS-11/2023', 27, 'Vill: Batargram, PO: Shoulmari, Thana: Roumari, District: Kurigram', '26 EB', '2018-01-21', '1999-11-20', '2023-07-20', 'no', 6, 'HSC', '', 'RL/GF Cadre', '', 'no', '', '01885-868048', '01985-078676', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2838, '4512429', 'LCpl', 'Said Al Mamun Roni', 9, 131, 'Trg On AWGSS-11/2023', 9, 'Vill: Chiksha, PO: Tahirpur, Thana: Tahirpur, District: Sunamganj', '37 BIR', '2013-01-06', '1994-10-17', '2023-07-20', 'no', 6, 'HSC', '', 'RL/GF Cadre', '', 'no', '', '01751-735818', '01741-741578', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2839, '4519888', 'Snk', 'Shakil Bin Shams', 9, 66, 'Trg On AWGSS-11/2023', 27, 'Vill: Paschim Manikdi, PO: Cantonment, Thana: Cantonment, District: Dhaka', '16 BIR', '2017-01-20', '1999-11-05', '2023-07-20', 'no', 6, 'HSC', '', 'Signal Cadre', '', 'no', '', '01877-748875', '01731-267557', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2840, '4525943', 'Snk', 'Sheikh Imran Hossen', 9, 69, 'Trg On AWGSS-11/2023', 27, 'Vill: Gopalpur, PO: Gopalpur, Thana: Kochuwa, District: Bagerhat', '24 BIR', '2019-01-27', '2000-06-10', '2023-07-20', 'no', 6, 'HSC', '', 'RL/GF Cadre. AGL Cadre', '', 'no', '', '01743-380720', '01740-788479', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2841, '4515111', 'Snk', 'Md Mahmudul Hasan', 9, 72, 'Trg On AWGSS-11/2023', 10, 'Vill: Horirampur, PO: Horirampur, Thana: Gobindaganj, District: Gaibandha', '29 BIR', '2015-01-24', '1995-11-30', '2023-07-20', 'no', 6, 'BA/BSS', '', '', 'ICT', 'no', '', '01766-176044', '01728-703452', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2842, '4525931', 'Snk', 'Minhajul Islam', 9, 73, 'Trg On AWGSS-11/2023', 7, 'Vill: North Baghia, PO: Kashipur, Thana: Barishal Sadar, District: Barishal', '30 BIR', '2019-02-01', '2001-08-21', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01611-903815', '01715-195020', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2843, '4517549', 'Snk', 'Md Faisal Miya', 9, 74, 'Trg On AWGSS-11/2023', 7, 'Vill: Projarkanda, PO: Mriga, Thana: Itna, District: Kishoreganj', '32 BIR', '2017-01-13', '1997-01-05', '2023-07-20', 'no', 6, 'HSC', '', '', 'ICT', 'no', '', '01571-016766', '01746-096085', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2844, '4515889', 'Snk', 'Sakil Ahmed', 9, 132, 'Trg On AWGSS-11/2023', 10, 'Vill: Malipara, PO: Malipara, Thana: Sorishabari, District: Jamalpur', '36 BIR', '2016-01-23', '1997-12-31', '2023-07-20', 'no', 6, 'HSC', 'ICT & NTC Course', '', '', 'no', '', '01891-940785', '01713-570420', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2845, '4521641', 'Snk', 'Md Juwel Miya', 9, 133, 'Trg On AWGSS-11/2023', 8, 'Vill: Ostoghoriya, PO: Achmita, Thana: Kotiyadi, District: Kishoreganj', '38 BIR', '2018-01-14', '1999-01-10', '2023-07-20', 'no', 6, 'HSC', '', 'ICT Cadre', '', 'no', '', '01718-291718', '01726-549825', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL);
INSERT INTO `operators` (`id`, `personal_no`, `rank`, `name`, `cores_id`, `unit_id`, `course_cadre_name`, `formation_id`, `permanent_address`, `present_address`, `admission_date`, `birth_date`, `joining_date_awgc`, `worked_in_awgc`, `med_category_id`, `civil_edu`, `course`, `cadre`, `expertise_area`, `punishment`, `special_note`, `mobile_personal`, `mobile_family`, `created_at`, `updated_at`, `exercise_id`) VALUES
(2846, '4525025', 'Snk', 'Md Rakibul Islam', 9, 134, 'Trg On AWGSS-11/2023', 28, 'Vill: Sorupacharak, PO: Goalondo, Thana: Goalondo, District: Rajbari', '39 BIR', '2019-01-13', '2000-11-25', '2023-07-20', 'no', 6, 'HSC', '', 'Signal Cadre', '', 'no', '', '01777-223261', '01725-002252', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2847, '4517546', 'Snk', 'Faijul Islam', 9, 135, 'Trg On AWGSS-11/2023', 6, 'Vill: Haidhonkhali, PO: Gujadiya, Thana: Korimganj, District: Kishoreganj', '41 BIR', '2017-01-15', '1997-07-20', '2023-07-20', 'no', 6, 'HSC', '', 'MIT Cadre, 82 mm Mor Cadre', '', 'no', '', '01777-060303', '01309-067994', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2848, '4517558', 'Snk', 'Md Abu Talha', 9, 23, 'Trg On AWGSS-11/2023', 6, 'Vill: Lamasampur, PO: Horipur Bazar, Thana: Jointapur, District: Sylhet', '44 BIR', '2017-01-13', '1997-01-01', '2023-07-20', 'no', 6, 'HSC', '', 'ATGW Cadre', '', 'no', '', '01745-351000', '01748-066099', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2849, '4524191', 'Snk', 'Raju Ahmed', 9, 20, 'Trg On AWGSS-11/2023', 5, 'Vill: Toilkupi, PO: Toilkupi, Thana: Kaliganj, District: Jhenaidah', '34 BIR', '2018-07-22', '1999-07-25', '2023-07-20', 'no', 6, 'HSC', '', '', '', 'no', '', '01629-215687', '01909-420264', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2850, '1008727', 'Snk', 'Md Yousuf Ali', 17, 79, 'Trg On AWGSS-12/2024', 6, 'Vill: Chanpur, PO: Basho, Thana: Nandigram, District: Bogura', '26 Horse', '2019-01-25', '1998-06-05', '2024-02-15', 'no', 6, 'HSC', 'Office Application & Database course', '', '', 'no', '', '01741-724659', '01732-261207', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2851, '1006673', 'Snk', 'Md Jakir Hosen', 17, 136, 'Trg On AWGSS-12/2024', 28, 'Vill: Gowal Danga, PO: Jamannagar, Thana: Ashasuni, District: Shatkhira', 'Bengal Cavalory', '2010-07-10', '1992-05-21', '2024-02-15', 'no', 6, 'SSC', '', 'Driving Cadre', '', 'no', '', '01838-995995', '01721-332746', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2852, '1236021', 'Snk', 'Md Jahangir Alam', 18, 80, 'Trg On AWGSS-12/2024', 9, 'Vill: Chakrajapur, PO: Gotgari, Thana: Manda, District: Naogaon', '2 Fd Reg Arty', '2015-01-24', '1995-06-25', '2024-02-15', 'no', 6, 'BA', '', 'Marksmanship Cadre, MG Cadre, Mor Cadre', 'Good Firer', 'no', '', '01302-552505', '01753-641210', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2853, '1243770', 'Snk', 'Md Enamul Haque', 18, 204, 'Trg On AWGSS-12/2024', 28, 'Vill: Minadiya, PO: Soilojana, Thana: Chowhali, District: Shirajganj', '6 Fd Reg Arty', '2020-01-12', '2001-04-15', '2024-02-15', 'no', 6, 'HSC', '', 'INT Cadre', '', 'no', '', '01780-107501', '01729-551583', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2854, '1241308', 'Snk (OCU)', 'Md Shakil Miya', 18, 82, 'Trg On AWGSS-12/2024', 10, 'Vill: Sristigor, PO: Sibpur, Thana: Choitanna, District: Narsingdi', '19 Med Reg Arty', '2019-01-13', '1999-12-10', '2024-02-15', 'no', 6, 'HSC', '', '', '', 'no', '', '01787-068752', '01772-085312', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2855, '1240311', 'Snk (OPR)', 'Md Apu Miya', 18, 137, 'Trg On AWGSS-12/2024', 27, 'Vill: Kolatola, PO: Kolatola, Thana: Chitolmari, District: Bagerhat', '29 Div Locating Bty', '2018-01-21', '2000-05-08', '2024-02-15', 'no', 6, 'HSC', '', 'ICT Cadre, Photographer Cadre', 'MS Word', 'no', '', '01751-5523326', '01988-862267', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2856, '1245064', 'Snk (OCU)', 'MD Ridoy Hossen', 18, 138, 'Trg On AWGSS-12/2024', 7, 'Vill: Chougram, PO: Chougram, Thana: Shingra, District: Natore', '32 Med Reg Arty', '2020-01-26', '2002-10-29', '2024-02-15', 'no', 6, 'HSC', '', 'INT Cadre', '', 'no', '', '01618-936818', '01788-920167', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2857, '1244808', 'Snk (TA)', 'Sheikh Morad Ahammed', 18, 139, 'Trg On AWGSS-12/2024', 27, 'Vill: Digha, PO: Digha, Thana: Gafargaon, District: Mymensingh', '47 Mor Reg Arty', '2020-01-26', '2002-03-20', '2024-02-15', 'no', 6, 'HSC', '', '', '', 'no', '', '01784-429606', '01731-038491', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2858, '1245099', 'Snk', 'Md Kamrul Hasan', 18, 140, 'Trg On AWGSS-12/2024', 4, 'Vill: Digdair, PO: Mohicharan, Thana: Sonatola, District: Bogura', '45 MLRS Reg Arty', '2020-01-26', '2001-12-20', '2024-02-15', 'no', 6, 'HSC', '', 'INT Cadre', '', 'no', '', '01788-225298', '01316-844190', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2859, '1449331', 'Cpl', 'Millat Hossen', 5, 32, 'Trg On AWGSS-12/2024', 10, 'Vill: Mohespur, PO: Bamyil, Thana: Potnitola, District: Naogaon', '6 ENGR BN', '2012-01-08', '1994-10-25', '2024-02-15', 'no', 6, 'HSC', '', '', '', 'no', '', '01769-120418', '01794-4425873', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2860, '1456806', 'Snk', 'Md Ekbal Ahammed Shourov', 5, 141, 'Trg On AWGSS-12/2024', 28, 'Vill: Dainno Rampal, PO: Binnafoir, Thana: Tangail, District: Tangail', '4 ENGR BN', '2020-01-10', '2001-11-12', '2024-02-15', 'no', 6, 'HSC', '', '', '', 'no', '', '01798-484599', '01925-497788', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2861, '1619518', 'Snk (Tech)', 'Md Al Amin Hossen', 6, 142, 'Trg On AWGSS-12/2024', 14, 'Vill: Kusdah, PO: Kusdah, Thana: Nobabganj, District: Dinajpur', '11 Sig BN', '2017-01-15', '1997-11-18', '2024-02-15', 'no', 6, 'HSC', '', 'ICT Cadre', '', 'no', '', '01797-716233', '01647-706001', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2862, '1237595', 'Snk', 'Md Kamal Parvej', 19, 26, 'Trg On AWGSS-12/2024', 7, 'Vill: Gojariya, PO: Gojariya, Thana: Lalmohon, District: Bhola', '21 AD', '2017-01-13', '1997-04-01', '2024-02-15', 'no', 6, 'BSS', '', '', '', 'no', '', '01715-754026', '01715-753836', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2863, '1240118', 'Snk (GNR)', 'Shahadat Hossen', 19, 143, 'Trg On AWGSS-12/2024', 17, 'Vill: Fajram Majhi, PO: Afajiya Bazar, Thana: Hatiya, District: Noakhali', '57 AD', '2018-01-21', '1998-12-06', '2024-02-15', 'no', 6, 'HSC', 'ICT & NTC Course-25', '', '', 'no', '', '01745-036680', '01714-936056', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2864, '1818951', 'Snk', 'Obayed Bin Khaled Nafiz', 20, 144, 'Trg On AWGSS-12/2024', 28, 'Vill: Notun Charkhagriya, PO: Satkaniya, Thana: Khagriya, District: Chittagong', '34 ST BN', '2022-02-04', '2003-07-16', '2024-02-15', 'no', 6, 'SSC', '', 'INT Cadre, Bugle Cadre', '', 'no', '', '01602-826770', '01876-018457', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2865, '4067281', 'Snk', 'Md Mehedi Hasan', 1, 51, 'Trg On AWGSS-12/2024', 27, 'Vill: Mollikpur, PO: Barhatta, Thana: Netrokona, District: Netrokona', '1 EB', '2020-01-26', '2002-12-04', '2024-02-15', 'no', 6, 'HSC', '', 'Signal Cadre', '', '1X Red Entry', '', '01314-959893', '01756-414996', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2866, '4061877', 'Snk', 'Mazharul Islam Akib', 1, 52, 'Trg On AWGSS-12/2024', 9, 'Vill: Modhurdiya, PO: Chowddoshoto, Thana: Kishoreganj, District: Kishoreganj', '2 EB', '2018-01-21', '2000-01-10', '2024-02-15', 'no', 6, 'HSC', 'Other Arms Sig and IT Course-48', 'Mor Cadre, First Aid Cadre', '', 'no', '', '01726-711626', '01758-655733', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2867, '4061642', 'Snk', 'Ashis Chandra Roy', 1, 87, 'Trg On AWGSS-12/2024', 8, 'Vill: Goshai Jowair, PO: Goshai Jowair, Thana: Tangail, District: Tangail', '3 EB', '2018-01-14', '1998-01-07', '2024-02-15', 'no', 6, 'HSC', '', '', '', 'no', '', '01616-332479', '01638-093484', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2868, '4064655', 'Snk', 'Masum Miya', 1, 145, 'Trg On AWGSS-12/2024', 7, 'Vill: Dumdiya, PO: Dumdiya, Thana: Kapashiya, District: Gazipur', '4 EB', '2019-01-13', '1999-11-02', '2024-02-15', 'no', 6, 'HSC', '', '', '', 'no', '', '01880-492500', '01732-756663', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2869, '4071590', 'Snk', 'Md Masum Billah', 1, 88, 'Trg On AWGSS-12/2024', 7, 'Vill: Vupotipur, PO: Porahati, Thana: Jhenaidah Sadar, District: Jhenaidah', '6 EB', '2022-02-04', '2002-07-23', '2024-02-15', 'no', 6, 'SSC', '', '', '', 'no', '', '01830-633076', '01910-141846', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2870, '4054555', 'Snk', 'Md Shahariar Najim Joy', 1, 21, 'Trg On AWGSS-12/2024', 3, 'Vill: Radhikapur, PO: Riajbagh, Thana: Pirganj, District: Thakurgaon', '8 EB', '2013-07-17', '1995-12-01', '2024-02-15', 'no', 6, 'SSC', '', '', '', 'no', '', '01618-118320', '01730-652708', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2871, '4058765', 'Snk', 'Md Saniyat Hossain', 1, 93, 'Trg On AWGSS-12/2024', 28, 'Vill: Sanok Boira, PO: Dhubliya, Thana: Bhuyapur, District: Tangail', '12 EB', '2017-01-15', '1998-05-15', '2024-02-15', 'no', 6, 'HSC', '', 'MG Cadre, RL/GF Cadre, PFT Cadre', '', 'no', '', '01613-262446', '01719-951007', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2872, '4065096', 'Snk', 'Kazi Sefat Ahmed', 1, 89, 'Trg On AWGSS-12/2024', 4, 'Vill: Betila, PO: Betila, Thana: Manikganj, District: Manikganj', '18 EB', '2019-01-27', '2001-04-17', '2024-02-15', 'no', 6, 'HSC', '', 'Clerk Cadre, Metis Cadre', '', 'no', '', '01905-130737', '01902-991725', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2873, '4061374', 'Snk', 'Md Monjurul Islam', 1, 90, 'Trg On AWGSS-12/2024', 3, 'Vill: Birahimpur, PO: Shalmara Bazar, Thana: Mithapukur, District: Rangpur', '24 EB', '2018-01-14', '1998-07-12', '2024-02-15', 'no', 6, 'HSC', 'PBC Course, PMC Course', 'AGL Cadre, Marksmanship Cadre', '', 'no', '', '01762-755914', '01732-683183', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2874, '4063842', 'Snk', 'Md Touhidul Islam', 1, 54, 'Trg On AWGSS-12/2024', 10, 'Vill: Kashipur, PO: Mirjapur, Thana: Jhikargacha, District: Jashore', '34 EB (Mech)', '2018-07-22', '1999-06-01', '2024-02-15', 'no', 6, 'HSC', 'Mor Course-65', 'Firs Aid Cadre, Marksmanship Cadre, Sharp Shooter Cadre, Mor Cadre, Fd ENGR Cadre', '', 'no', '', '01753-564405', '01751-844872', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2875, '4059918', 'Snk', 'Md Foysal Ahammed', 1, 34, 'Trg On AWGSS-12/2024', 28, 'Vill: Paschim Bamna, PO: Gilabari, Thana: Islampur, District: Jamalpur', '59 EB (SP BN)', '2017-01-22', '1997-11-30', '2024-02-15', 'no', 6, 'HSC', '', 'INT Cadre, Marksmanship Cadre, MIT Cadre', '', 'no', '', '01308-824999', '01714-587421', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2876, '4063130', 'Snk', 'Md Foysal Ahammed Shadhin', 1, 36, 'Trg On AWGSS-12/2024', 6, 'Vill: Charshibrampur, PO: Himayetpur, Thana: Pabna, District: Pabna', '62 EB', '2018-01-18', '1997-12-05', '2024-02-15', 'no', 6, 'HSC', '', '', '', 'no', '', '01798-282884', '01733-895019', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2877, '4507099', 'Cpl', 'Md Ashraful Islam', 1, 146, 'Trg On AWGSS-12/2024', 8, 'Vill: Nakati, PO: Saidpur, Thana: Jamalpur, District: Jamalpur', '15 BIR (SP BN)', '2007-01-14', '1988-05-01', '2024-02-15', 'no', 6, 'HSC', 'NCOS Course', 'Computer Cadre, ATGW Cadre', '', '1XRed Entry                    10 Days RI', '', '01736-440514', '01797-612119', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2878, '4526901', 'Snk', 'Md Abdul Kader', 9, 147, 'Trg On AWGSS-12/2024', 7, 'Vill: Chalapara, PO: Dhunot, Thana: Dhunot, District: Bogura', '2 BIR', '2019-07-21', '2002-05-15', '2024-02-15', 'no', 6, 'HSC', '', 'MG Cadre, ICT Cadre', '', 'no', '', '01617-677217', '01704-451315', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2879, '4529833', 'Snk', 'Md Istiak', 9, 148, 'Trg On AWGSS-12/2024', 28, 'Vill: Solok, PO: Solok, Thana: Ujirpur, District: Barishal', '9 BIR (Mech)', '2021-01-31', '2003-04-04', '2024-02-15', 'no', 6, 'HSC', 'ICT & NTC Course-30', 'AGL, CTC, Office Automation Cadre', '', 'no', '', '01707-908079', '01739-573268', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2880, '4518586', 'Snk', 'Anik Hossain', 9, 149, 'Trg On AWGSS-12/2024', 4, 'Vill: , PO: , Thana: , District:', '11 BIR (Mech)', '2017-01-13', '1997-04-05', '2024-02-15', 'no', 6, 'HSC', '', 'Marksmanship Cadre, APC Cadre', '', 'no', '', '01789-696275', '01736-090573', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2881, '4521271', 'Snk', 'Md Lavlu Miya', 9, 150, 'Trg On AWGSS-12/2024', 8, 'Vill: Bowaliya, PO: Bowaliya Bazar, Thana: Ullapara, District: Sirajganj', '12 BIR', '2017-07-17', '1998-03-19', '2024-02-15', 'no', 6, 'HSC', '', 'RL/GF Cadre, ICT Cadre, First Aid Cadre', '', 'no', '', '01770-435096', '01724-7437178', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2882, '4522532', 'Snk', 'Ekbal Hossen', 9, 151, 'Trg On AWGSS-12/2024', 3, 'Vill: Purbocharbata, PO: Ansar Miyar Hat, Thana: Charjobbar, District: Noakhali', '13 BIR', '2018-01-21', '1999-01-01', '2024-02-15', 'no', 6, 'HSC', '', '82 mm Mor Cadre, Aslt Pnr Cadre, Computer Maintenance & Troubleshooting Cadre', 'Computer Expert', 'no', '', '01601-297187', '01857-516526', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2883, '4522135', 'Snk', 'Torikul Islam', 9, 152, 'Trg On AWGSS-12/2024', 9, 'Vill: South Keroya, PO: Mollar Hat, Thana: Roypur, District: Laksmipur', '14 BIR', '2018-01-14', '1999-07-08', '2024-02-15', 'no', 6, 'HSC', 'CCNA Course', 'ICT Cadre', '', 'no', '', '01679-471150', '01776-131796', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2884, '4525802', 'Snk', 'Md Raihan Khan', 9, 97, 'Trg On AWGSS-12/2024', 9, 'Vill: Najirpur, PO: BP Najirpur, Thana: Pabna, District: Pabna', '17 BIR (Mech)', '2019-01-27', '2000-09-12', '2024-02-15', 'no', 6, 'HSC', '', 'MIT Cadre, FE Cadre, ICT Cadre', '', 'no', '', '01744-181272', '01745-247036', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2885, '4522469', 'Snk', 'Md Hasanuzzaman', 9, 153, 'Trg On AWGSS-12/2024', 7, 'Vill: Horinakundu, PO: Horinakundu, Thana: Horinakundu, District: Jhenaidah', '18 BIR', '2018-01-14', '1998-06-12', '2024-02-15', 'no', 6, 'HSC', 'ICTNTC Course-25', '', '', 'no', '', '01785-86665', '01712-394165', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2886, '4525142', 'Snk', 'Md Habibur Islam', 9, 154, 'Trg On AWGSS-12/2024', 4, 'Vill: Gobindapur, PO: Mommothpur, Thana: Parbotipur, District: Dinajpur', '19 BIR', '2019-01-13', '2000-10-08', '2024-02-15', 'no', 6, 'HSC', '', '82 mm Mor Cadre, First Aid Cadre, Clerk Cadre', '', 'no', '', '01737-743305', '01737-049069', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2887, '4518515', 'Snk', 'Md Miraz Ahammed', 9, 155, 'Trg On AWGSS-12/2024', 8, 'Vill: Boidanga, PO: Sadhuhati, Thana: Jhenaidah, District: Jhenaidah', '21 BIR', '2017-01-15', '1998-02-01', '2024-02-15', 'no', 6, 'HSC', '', '', '', 'no', '', '01642-135402', '01917-369884', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2888, '1616696', 'Sgt', 'Md Enamul Haque', 9, 156, 'Trg On AWGSS-12/2024', 23, 'Vill: Jhakra, PO: Chaikhola, Thana: Chatmohor, District: Pabna', '1 Para Commando BN', '2008-07-06', '1990-07-14', '2024-02-15', 'no', 6, 'HSC', 'ACC-27, BCC-75, CCC-40, NCOC-62', '', '', 'no', '', '01731-285882', '01780-106570', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2889, '1008517', 'Snk (DVR)', 'Md Moniruzzaman Akash', 17, 104, 'Trg On AWGSS-13/2024', 3, 'Vill: Shatbariya, PO: Shatbariya, Thana: Bheramara, District: Kustia', '4 Horse', '2019-01-13', '1999-10-28', '2024-08-02', 'no', 6, 'HSC', '', '', '', 'no', '', '01778-200594', '01729-664585', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2890, '109650', 'Snk (OP)', 'Md Mohsin Ali', 17, 24, 'Trg On AWGSS-13/2024', 8, 'Vill: Nandura, PO: Atmul, Thana: Shibganj, District: Bogura', '6 Cavalory', '2021-02-03', '2004-12-31', '2024-07-18', 'no', 6, 'HSC', '', '', '', 'no', '', '01721-119658', '01745-322641', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2891, '1242667', 'Snk (DMT)', 'Md Nafis Sadik', 18, 117, 'Trg On AWGSS-13/2024', 27, 'Vill: North Digong, PO: Hetatola, Thana: Kolarowa, District:', '1 Fd Reg Arty', '2019-01-25', '1999-01-16', '2024-07-18', 'no', 6, 'HSC', '', 'Computer Cadre', '', 'no', '', '01725-750123', '01317-725289', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2892, '1243238', 'Snk (DMT)', 'Md Nazmul Huda', 18, 81, 'Trg On AWGSS-13/2024', 3, 'Vill: Kashariyar Hat, PO: Baguwa, Thana: Ulipur, District: Kurigram', 'Dead During Cdo Cadre', '2019-07-21', '2000-11-06', '2024-07-18', 'no', 6, 'HSC', '', 'MT Cadre', '', 'no', '', '01705-928900', '01717-297019', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2893, '1239733', 'Snk', 'Md Allama Mashkiri', 18, 205, 'Trg On AWGSS-13/2024', 9, 'Vill: Biswanathpur, PO: Binodpur, Thana: Shibganj, District: Chapainawabganj', '8 Fd Reg Arty', '2018-01-21', '1999-12-12', '2024-07-18', 'no', 6, 'HSC', '', 'ICT Cadre, FE Cadre', '', 'no', '', '01751-413913', '01724-338825', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2894, '1245785', 'Snk', 'Md Easin Sikder', 18, 30, 'Trg On AWGSS-13/2024', 9, 'Vill: Chalitabuniya, PO: Nobaber Hat, Thana: Bamna, District: Barguna', '27 Fd Reg Arty', '2020-01-26', '2001-09-02', '2024-07-18', 'no', 6, 'HSC', '', 'Fire Fighting Cadre', '', 'no', '', '01729-161123', '01716-369123', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2895, '1239649', 'Snk (OCU)', 'Md Masud Rana', 18, 28, 'Trg On AWGSS-13/2024', 8, 'Vill: Gonopoit, PO: Bhela Muraripur, Thana: Birganj, District: Dinajpur', '39 Div Locating Bty', '2018-01-14', '1999-07-17', '2024-07-18', 'no', 6, 'HSC', '', 'CCTV Cadre, CLS Cadre', '', 'no', '', '017010-522243', '01733-134149', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2896, '1242680', 'Snk', 'Aminur Islam', 18, 157, 'Trg On AWGSS-13/2024', 5, 'Vill: Polashbari, PO: Jaforpur, Thana: Akkelpur, District: Joypurhat', '50 Fd Reg Arty', '2019-01-27', '2001-02-25', '2024-07-18', 'no', 6, 'HSC', '', '', '', 'no', '', '01794-051595', '01749-585012', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2897, '1241827', 'Snk (OCU)', 'Md Ahsan Habib', 18, 158, 'Trg On AWGSS-13/2024', 6, 'Vill: Hatsira, PO: Hatsira, Thana: Kazipur, District: Sirajganj', '52 Indep MLRS Bty', '2019-01-13', '2000-12-10', '2024-07-18', 'no', 6, 'HSC', '', 'ADMG 12.7 Cadre', '', 'no', '', '01767-351592', '01723-883572', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2898, '1450356', 'LCpl', 'Md Sumon Miya', 5, 159, 'Trg On AWGSS-13/2024', 3, 'Vill: Chandipur, PO: Thutiyapakur, Thana: Polashbari, District: Gaibandha', '18 ENGR BN', '2014-01-24', '1995-01-24', '2024-07-18', 'no', 6, 'HSC', '', 'Computer Cadre, CIED Cadre', '', 'no', '', '01609-588631', '01862-697030', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2899, '1451447', 'Snk', 'Eyakub Ali', 5, 160, 'Trg On AWGSS-13/2024', 30, 'Vill: Roysimul, PO: Shantipur, Thana: Sujanagar, District: Pabna', '21 ENGR BN', '2016-01-24', '1997-02-05', '2024-07-18', 'no', 6, 'BSS', 'CEC Course-9', 'CIED Cadre, S&D Cadre, UAV Cadre', 'Deploma in Computer Application Course', 'no', '', '01303-857534', '01738-243751', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2900, '1618648', 'Cpl (OP)', 'Md Rasel', 6, 161, 'Trg On AWGSS-13/2024', 9, 'Vill: kacharikandi, PO: Moddhonagar, Thana: Roypura, District: Narsingdi', '1 Sig BN', '2016-01-23', '1998-11-22', '2024-07-18', 'no', 6, 'HSC', 'ICT NTC-07', '', '', 'no', '', '01316-480685', '01316-330796', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2901, '1621796', 'Cpl (Crypto)', 'Siyam Molla', 6, 44, 'Trg On AWGSS-13/2024', 28, 'Vill: Char-Bangrail, PO: Fulbaria Hat, Thana: Shaltha, District: Faridpur', '4 Sig BN', '2019-01-27', '2000-05-05', '2024-07-18', 'no', 6, 'HSC', 'ICT NTC-27, Table Analist Course', 'Div ICT Cadre', '', 'no', '', '01722-003656', '01785-978921', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2902, '1238094', 'Snk (OCU)', 'Anik Kumar Bormon', 19, 162, 'Trg On AWGSS-13/2024', 17, 'Vill: Mohanondopur, PO: Ebadotnagar, Thana: Shokhipur, District: Tangail', '36 AD', '2017-01-22', '1998-05-14', '2024-07-18', 'no', 6, 'HSC', '', '', '', 'no', '', '01771-024111', '01626-761498', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2903, '4051712', 'LCpl', 'Sajid Mahmud', 1, 35, 'Trg On AWGSS-13/2024', 3, 'Vill: Pachkhola, PO: Madaripur, Thana: Madaripur, District: Madaripur', '29 EB (SP BN)', '2012-01-08', '1993-09-05', '2024-07-18', 'no', 6, 'HSC', '', 'MT Cadre, ICT Cadre, RL/GF Cadre', '', 'no', '', '01736-420412', '01305-416830', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2904, '4070953', 'Snk', 'Md Nurnobi', 1, 123, 'Trg On AWGSS-13/2024', 27, 'Vill: Putiapara, PO: Khashimara, Thana: Melandaha, District: Jamalpur', '9 EB', '2022-02-04', '2003-11-11', '2024-07-18', 'no', 6, 'HSC', '', '', '', 'no', '', '01647-401701', '01937-475987', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2905, '4067356', 'Snk', 'Omor Faruk Shakib', 1, 130, 'Trg On AWGSS-13/2024', 12, 'Vill: Aiyubpur, PO: Joynarayanpur, Thana: Begumganj, District: Noakhali', 'Retired', '2020-01-26', '2002-08-26', '2024-07-18', 'no', 6, 'HSC', '', '', '', 'no', '', '01644-624112', '01833-033460', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2906, '4054368', 'Snk', 'Amir Hamza', 1, 91, 'Trg On AWGSS-13/2024', 12, 'Vill: Akaniya, PO: Shahedapur, Thana: Kochuwa, District: Chandpur', '25 EB', '2013-07-14', '1995-02-02', '2024-07-18', 'no', 6, 'HSC', '', 'Computer Automation Cadre, RL/GF Cadre', '', 'no', '', '01820-917006', '01878-952543', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2907, '4063517', 'Snk', 'Jahangir', 1, 53, 'Trg On AWGSS-13/2024', 27, 'Vill: Horshi, PO: Shukhiya, Thana: Pakundiya, District: Kishoreganj', '26 EB', '2018-07-20', '2001-09-05', '2024-07-18', 'no', 6, 'HSC', '', 'RL/GF Cadre', '', 'no', '', '01628-144365', '01918-714875', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2908, '4069170', 'Snk', 'Md Moniruzzaman Akash', 1, 109, 'Trg On AWGSS-13/2024', 4, 'Vill: Majhgram, PO: Boda, Thana: Boda, District: Panchagarh', '27 EB', '2021-01-31', '2002-09-14', '2024-07-18', 'no', 6, 'HSC', '', '', '', 'no', '', '01750-180590', '01714-254081', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2909, '4052273', 'Snk', 'Md Nayem Sorker', 1, 128, 'Trg On AWGSS-13/2024', 4, 'Vill: Bir Uzli, PO: Bir Uzli, Thana: Kapasia, District: Gazipur', '28 EB', '2012-07-08', '1994-06-13', '2024-07-18', 'no', 6, 'BA', '', '', '', 'no', '', '01988-892402', '01785-527900', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2910, '4068938', 'Snk', 'Tanjin Hayder Roudro', 1, 163, 'Trg On AWGSS-13/2024', 10, 'Vill: Borokashiya, PO: Mohonganj, Thana: Mohonganj, District: Netrokona', '30 EB', '2021-01-31', '2002-10-28', '2024-07-18', 'no', 6, 'HSC', 'Burmese Language Course', 'Mor Cadre', '', 'no', '', '01745-339640', '01760-841050', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2911, '4063944', 'Snk', 'Humayun Kobir', 1, 164, 'Trg On AWGSS-13/2024', 10, 'Vill: Shadipur, PO: Sardah, Thana: Charghat, District: Rajshahi', '32 EB', '2018-06-26', '1999-12-30', '2024-07-18', 'no', 6, 'HSC', '', 'ICT Cadre, Metis Cadre, Marksmanship Cadre', '', 'no', '', '01948-208585', '01610-875047', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2912, '4064101', 'Snk', 'Md Saiful Islam Mithu', 1, 165, 'Trg On AWGSS-13/2024', 27, 'Vill: Gourichonna, PO: Barguna, Thana: Barguna Sadar, District: Barguna', '36 EB', '2018-07-20', '2000-01-01', '2024-07-18', 'no', 6, 'HSC', '', 'RP Cadre, ICT Cadre, Metis Cadre', '', 'no', '', '01317-009738', '01634-840019', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2913, '4064646', 'Snk', 'Md Shahin Hossen', 1, 166, 'Trg On AWGSS-13/2024', 27, 'Vill: Rudropur, PO: Rudropur, Thana: Kotwali, District: Jashore', '38 EB', '2019-01-13', '2001-01-01', '2024-07-18', 'no', 6, 'HSC', '', 'RL/GF Cadre', '', 'no', '', '01609-570958', '01758-010367', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2914, '4062778', 'Snk', 'Md Jahidul Hasan', 1, 62, 'Trg On AWGSS-13/2024', 6, 'Vill: Tarapaira, PO: Gazimura, Thana: Laksham, District: Cumilla', '67 EB', '2018-01-21', '1999-04-24', '2024-07-18', 'no', 6, 'HSC', 'ICT Network Technician Course-21', '', '', 'no', '', '01304-062778', '01771-2636751', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2915, '4507087', 'Cpl', 'Mohammod Saifan Hossain', 9, 96, 'Trg On AWGSS-13/2024', 10, 'Vill: Chondroghona, PO: Khondakarpara, Thana: Ranguniya, District: Chittagong', '22 BIR', '2007-01-14', '1988-08-19', '2024-07-18', 'no', 6, 'HSC', '', 'Computer Cadre, Radar Cadre', 'Computer And Sound System', 'no', '', '01811-946434', '01673-496582', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2916, '4520818', 'Snk', 'Hafizur Rahman', 9, 167, 'Trg On AWGSS-13/2024', 27, 'Vill: Nurpur, PO: Churamonkathi, Thana: Jashore Sadar, District: Jashore', '1 BIR', '2017-07-21', '1998-09-15', '2024-07-18', 'no', 6, 'HSC', '', '', '', 'no', '', '01880-060422', '01745-658039', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2917, '4525905', 'Snk', 'Md Rakibul Islam', 9, 168, 'Trg On AWGSS-13/2024', 4, 'Vill: Kagmari, PO: Boluhar, Thana: Kotchandpur, District: Jhenaidah', '5 BIR (SP BN)', '2019-01-27', '2000-06-08', '2024-07-18', 'no', 6, 'HSC', 'cyber Security Course-2', '', '', 'no', '', '01852-801877', '01765-784315', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2918, '4520624', 'Snk', 'Md Sohag Hosen', 9, 169, 'Trg On AWGSS-13/2024', 5, 'Vill: Ektarpur, PO: Mongolpoita, Thana: Kaliganj, District: Jhenaidah', '6 BIR', '2017-07-23', '1998-02-01', '2024-07-18', 'no', 6, 'HSC', '', 'ICT Cadre, RL/GF Cadre,  MG Cadre', '', 'no', '', '01307-675465', '01608-364947', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2919, '4527857', 'Snk', 'Md Aktarul Islam', 9, 170, 'Trg On AWGSS-13/2024', 10, 'Vill: Nijpara, PO: Bolrampur, Thana: Birganj, District: Dinajpur', '7 BIR', '2020-01-26', '2001-12-20', '2024-07-18', 'no', 6, 'HSC', '', 'Radar Cadre', '', 'no', '', '01609-986461', '01736-674498', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2920, '4530936', 'Snk', 'Md Ariful Islam', 9, 171, 'Trg On AWGSS-13/2024', 4, 'Vill: Kamirar Para, PO: Kutubjom, Thana: Moheskhali, District: Cox\'s Bazar', '8 BIR', '2021-01-31', '2001-08-14', '2024-07-18', 'no', 6, 'HSC', '', '', '', 'no', '', '01858-574152', '01871-015330', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2921, '4530225', 'Snk', 'Md Emran Hasan', 9, 172, 'Trg On AWGSS-13/2024', 28, 'Vill: Khalkula, PO: Matiakhali Para, Thana: Tarash, District: Shirajganj', '10 BIR', '2021-01-31', '2002-11-01', '2024-07-18', 'no', 6, 'HSC', '', '', '', 'no', '', '01608-454768', '01740-856245', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2922, '4528380', 'Snk', 'Md Masud Miya', 9, 99, 'Trg On AWGSS-13/2024', 10, 'Vill: Tushpur, PO: Tushpur, Thana: Motlob (South), District: Chandpur', '25 BIR (SP BN)', '2020-01-26', '2000-09-07', '2024-07-18', 'no', 6, 'HSC', '', 'ICT Cadre, APC Cadre', '', 'no', '', '01787-981262', '01813-797223', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2923, '4526113', 'Snk', 'Md Tuhin Babu', 9, 100, 'Trg On AWGSS-13/2024', 3, 'Vill: Bisnopur, PO: Gangnogor, Thana: Shibganj, District: Bogura', '26 BIR', '2019-01-27', '2000-05-12', '2024-07-18', 'no', 6, 'HSC', '', '', '', 'no', '', '01717-955819', '01707-440097', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2924, '4518133', 'Snk', 'Md Sanowar Hossen', 9, 98, 'Trg On AWGSS-13/2024', 7, 'Vill: Chakmodhupur, PO: Chaikola, Thana: Chatmohor, District: Pabna', '31 BIR', '2017-01-15', '1998-10-10', '2024-07-18', 'no', 6, 'HSC', '', 'MT Cadre, ICT Cadre, RL/GF Cadre', '', 'no', '', '01309-798803', '01306-116493', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2925, '4532402', 'Snk', 'Md Sabbir Hossen', 9, 95, 'Trg On AWGSS-13/2024', 8, 'Vill: Rajarampur, PO: Singul, Thana: Birol, District: Dinajpur', '33 BIR', '2022-02-04', '2003-10-08', '2024-07-18', 'no', 6, 'SSC', '', '', '', 'no', '', '01307-333547', '01789-462253', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2926, '4510982', 'Snk', 'Delowar Hossen', 9, 173, 'Trg On AWGSS-13/2024', 28, 'Vill: Dhormoroy, PO: Shukhari, Thana: Atpara, District: Netrokona', '40 BIR', '2011-01-10', '1993-02-04', '2024-07-18', 'no', 6, 'HSC', 'ICT Adv Course', 'ICT Cadre, OPD-2, Signal Cadre, DCMS', '', '1XBlack Entry', '', '01622-063702', '01601-665326', '2025-10-04 14:11:31', '2025-10-04 14:11:31', NULL),
(2927, '2207337', 'Snk (CLK)', 'Milon Sharder', 12, 174, 'Trg On AWGSS-13/2024', 27, 'Vill: Sarder Danga, PO: Aronghata, Thana: Aronghata, District: Khulna', 'CAD', '2017-07-21', '1998-09-15', '2024-07-18', 'no', 6, 'HSC', NULL, NULL, NULL, 'no', 'Retired', '01990-004652', '01624-995623', '2025-10-04 14:11:31', '2025-10-04 14:14:42', 8);

-- --------------------------------------------------------

--
-- Table structure for table `operator_exercises`
--

CREATE TABLE `operator_exercises` (
  `id` int(11) NOT NULL,
  `operator_id` int(11) NOT NULL,
  `exercise_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `operator_exercises`
--

INSERT INTO `operator_exercises` (`id`, `operator_id`, `exercise_id`, `created_at`) VALUES
(32, 22, 2, '2025-09-29 16:59:30'),
(33, 22, 4, '2025-09-29 16:59:30'),
(34, 435, 1, '2025-10-01 17:20:29'),
(35, 1842, 3, '2025-10-03 04:21:09'),
(37, 2927, 8, '2025-10-04 14:14:42');

-- --------------------------------------------------------

--
-- Table structure for table `operator_special_notes`
--

CREATE TABLE `operator_special_notes` (
  `id` int(11) NOT NULL,
  `operator_id` int(11) NOT NULL,
  `special_note_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `operator_special_notes`
--

INSERT INTO `operator_special_notes` (`id`, `operator_id`, `special_note_id`, `created_at`) VALUES
(27, 434, 8, '2025-10-01 14:21:03'),
(28, 433, 2, '2025-10-01 17:16:59'),
(29, 432, 10, '2025-10-01 17:17:21'),
(30, 435, 4, '2025-10-01 17:20:29'),
(31, 2409, 9, '2025-10-04 06:40:34'),
(32, 2927, 13, '2025-10-04 14:14:42'),
(33, 2693, 9, '2025-10-04 14:18:45');

-- --------------------------------------------------------

--
-- Table structure for table `ranks`
--

CREATE TABLE `ranks` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ranks`
--

INSERT INTO `ranks` (`id`, `name`, `created_at`) VALUES
(11, 'WO', '2025-10-01 14:17:03'),
(33, 'LCpl (GNR)', '2025-10-03 03:53:19'),
(34, 'Snk (OCU)', '2025-10-03 03:53:19'),
(35, 'Snk (GNR)', '2025-10-03 03:53:19'),
(36, 'Snk (SMS)', '2025-10-03 03:53:19'),
(37, 'LCpl (RCT)', '2025-10-03 03:53:19'),
(38, 'LCpl (OP)', '2025-10-03 03:53:19'),
(39, 'Cpl (OCU)', '2025-10-03 03:53:19'),
(40, 'Cpl (GNR)', '2025-10-03 03:53:19'),
(41, 'LCpl (TA)', '2025-10-03 03:53:19'),
(42, 'Cpl (OP)', '2025-10-03 03:53:19'),
(43, 'Snk (WSS)', '2025-10-03 03:53:19'),
(44, 'Snk (MT)', '2025-10-03 03:53:19'),
(45, 'LCpl (DVR)', '2025-10-03 03:53:19'),
(46, 'LCpl (OCU)', '2025-10-03 03:53:19'),
(47, 'Snk (M DVR)', '2025-10-03 03:53:19'),
(48, 'Sgt (OP)', '2025-10-03 03:53:19'),
(49, 'Snk (OP)', '2025-10-03 03:53:19'),
(50, 'Snk (SMT)', '2025-10-03 03:53:19'),
(51, 'Snk (DVR)', '2025-10-03 03:53:19'),
(52, 'Snk (TA)', '2025-10-03 03:53:19'),
(53, 'Snk (DMT)', '2025-10-03 03:53:19'),
(54, 'Snk (CLK)', '2025-10-03 05:18:26'),
(55, 'Snk (OPR)', '2025-10-03 05:18:26'),
(56, 'Snk (Tech)', '2025-10-03 05:18:26'),
(57, 'Cpl (Crypto)', '2025-10-03 05:18:26'),
(58, 'LCpl', '2025-10-04 06:32:42'),
(59, 'Snk', '2025-10-04 06:32:42'),
(60, 'Sgt', '2025-10-04 06:32:43'),
(61, 'Cpl', '2025-10-04 06:32:43'),
(62, 'Sgt (TA)', '2025-10-04 06:32:43');

-- --------------------------------------------------------

--
-- Table structure for table `special_notes`
--

CREATE TABLE `special_notes` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `color` varchar(7) DEFAULT '#ff4757',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `special_notes`
--

INSERT INTO `special_notes` (`id`, `name`, `description`, `color`, `created_at`, `updated_at`) VALUES
(9, 'Trg NCO', NULL, '#ff4757', '2025-09-27 15:31:00', '2025-09-27 15:31:00'),
(10, 'Died', NULL, '#ff4757', '2025-10-01 14:35:06', '2025-10-01 14:35:06'),
(11, 'Instructor', NULL, '#ff4757', '2025-10-03 05:45:41', '2025-10-03 05:45:41'),
(12, 'AWGC Prohibited ', NULL, '#ff4757', '2025-10-04 07:00:26', '2025-10-04 07:00:26'),
(13, 'Retired', NULL, '#ff4757', '2025-10-04 07:00:40', '2025-10-04 07:00:40'),
(14, 'Court Marshal', NULL, '#ff4757', '2025-10-04 07:01:06', '2025-10-04 07:01:06');

-- --------------------------------------------------------

--
-- Table structure for table `units`
--

CREATE TABLE `units` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `units`
--

INSERT INTO `units` (`id`, `name`) VALUES
(11, '17 Fd Reg Arty'),
(12, '18 Fd Reg Arty'),
(13, '42 Fd Reg Arty'),
(14, '12 Fd Reg Arty'),
(15, '15 Fd Reg Arty'),
(16, '20 Fd Reg Arty'),
(17, '40 Fd Reg Arty'),
(18, '29 EB'),
(19, '57 Engr Br'),
(20, '34 BIR'),
(21, '8 EB'),
(22, '46 Loc Bty'),
(23, '44 BIR'),
(24, '6 Cavalory'),
(25, '9 Bengal Lancher'),
(26, '21 AD'),
(27, '5 AD'),
(28, '39 Div Locating Bty'),
(29, '14 Fd Reg Arty'),
(30, '27 Fd Reg Arty'),
(31, '35 Div Locating Bty'),
(32, '6 ENGR BN'),
(33, '3 ENGR BN'),
(34, '59 EB (SP BN)'),
(35, '29 EB (SP BN)'),
(36, '62 EB'),
(37, '11 SP Reg Arty'),
(38, '7 RE BN'),
(39, '8 ENGR BN'),
(40, '9 ENGR BN'),
(41, '16 ECB'),
(42, '17 ECB'),
(43, '6 Sig BN'),
(44, '4 Sig BN'),
(45, '3 Sig BN'),
(46, '43 SHORAD Missile Reg'),
(47, '44 SHORAD Missile Reg'),
(48, '38 AD'),
(49, '36 ST BN'),
(50, '37 ST BN'),
(51, '1 EB'),
(52, '2 EB'),
(53, '26 EB'),
(54, '34 EB (Mech)'),
(55, '56 EB'),
(56, '57 EB'),
(57, '61 EB'),
(58, '63 EB'),
(59, '64 EB'),
(60, '65 EB'),
(61, '66 EB'),
(62, '67 EB'),
(63, '79 EB (SP BN)'),
(64, '3 BIR'),
(65, '4 BIR'),
(66, '16 BIR'),
(67, '20 BIR'),
(68, '23 BIR'),
(69, '24 BIR'),
(70, '27 BIR'),
(71, '28 BIR'),
(72, '29 BIR'),
(73, '30 BIR'),
(74, '32 BIR'),
(75, '35 BIR (SP BN)'),
(76, '42 BIR'),
(77, '43 BIR'),
(78, '510 DOC'),
(79, '26 Horse'),
(80, '2 Fd Reg Arty'),
(81, '4 Fd Reg Arty'),
(82, '19 Med Reg Arty'),
(83, '41 Med Reg Arty'),
(84, '46 Div Locating Bty'),
(85, '22 ENGR BN'),
(86, '16 EB'),
(87, '3 EB'),
(88, '6 EB'),
(89, '18 EB'),
(90, '24 EB'),
(91, '25 EB'),
(92, '21 EB'),
(93, '12 EB'),
(94, '10 EB'),
(95, '33 BIR'),
(96, '22 BIR'),
(97, '17 BIR (Mech)'),
(98, '31 BIR'),
(99, '25 BIR (SP BN)'),
(100, '26 BIR'),
(101, '8 BIR'),
(102, 'ORDEP Jashore'),
(103, 'CMTD'),
(104, '4 Horse'),
(105, '1 ENGR BN'),
(106, '8 Sig Bn'),
(107, '32 ST BN'),
(108, '19 EB (SP BN)'),
(109, '27 EB'),
(110, '58 EB'),
(111, '60 EB'),
(112, '7 Horse'),
(113, '7 Fd Reg Arty'),
(114, '10 Med Reg Arty'),
(115, '22 Fd Reg Arty'),
(116, '49 Fd Reg Arty'),
(117, '1 Fd Reg Arty'),
(118, '2 ENGR BN'),
(119, '5 Sig Bn'),
(120, '9 Sig Bn'),
(121, 'COD, Dhaka'),
(122, '7 EB'),
(123, '9 EB'),
(124, '11 EB'),
(125, '14 EB'),
(126, '15 EB (Mech)'),
(127, '17 EB'),
(128, '28 EB'),
(129, '20 EB'),
(130, '23 EB'),
(131, '37 BIR'),
(132, '36 BIR'),
(133, '38 BIR'),
(134, '39 BIR'),
(135, '41 BIR'),
(136, 'Bengal Cavalory'),
(137, '29 Div Locating Bty'),
(138, '32 Med Reg Arty'),
(139, '47 Mor Reg Arty'),
(140, '45 MLRS Reg Arty'),
(141, '4 ENGR BN'),
(142, '11 Sig BN'),
(143, '57 AD'),
(144, '34 ST BN'),
(145, '4 EB'),
(146, '15 BIR (SP BN)'),
(147, '2 BIR'),
(148, '9 BIR (Mech)'),
(149, '11 BIR (Mech)'),
(150, '12 BIR'),
(151, '13 BIR'),
(152, '14 BIR'),
(153, '18 BIR'),
(154, '19 BIR'),
(155, '21 BIR'),
(156, '1 Para Commando BN'),
(157, '50 Fd Reg Arty'),
(158, '52 Indep MLRS Bty'),
(159, '18 ENGR BN'),
(160, '21 ENGR BN'),
(161, '1 Sig BN'),
(162, '36 AD'),
(163, '30 EB'),
(164, '32 EB'),
(165, '36 EB'),
(166, '38 EB'),
(167, '1 BIR'),
(168, '5 BIR (SP BN)'),
(169, '6 BIR'),
(170, '7 BIR'),
(171, '8 BIR`'),
(172, '10 BIR'),
(173, '40 BIR'),
(174, 'CAD'),
(175, '3 Fd Reg Arty'),
(176, '2 Sig BN'),
(177, '35 ST BN'),
(178, '38 ST BN'),
(179, '504 DOC'),
(180, '41 Medium Arty Wrksp Sec EME'),
(181, '12 Lancher Wrksp Sec EME'),
(182, '7 Sig BN'),
(183, '39 ST BN'),
(184, '30 Fd Reg Arty'),
(185, '9 Fd Reg Arty'),
(186, '26 Fd Reg Arty'),
(187, '25 AD Reg Arty'),
(188, '56 Indep Med AD Bty'),
(189, '12 ENGR BN'),
(190, '11 RE BN'),
(191, 'Army Static Sig BN'),
(192, '505 DOC'),
(193, '28 Med Reg Arty'),
(194, '23 Fd Reg Arty'),
(195, '57 ENGR COY'),
(196, '5 RE BN'),
(197, '10 Sig BN'),
(198, '40 EB (Mech)'),
(199, '13 EB'),
(200, '5 EB'),
(201, 'Army ST BN'),
(202, '12 Lancher'),
(203, '16 Cavalory'),
(204, '6 Fd Reg Arty'),
(205, '8 Fd Reg Arty');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_login_log`
--
ALTER TABLE `admin_login_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_username` (`username`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_success` (`success`);

--
-- Indexes for table `admin_users`
--
ALTER TABLE `admin_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `fk_admin_created_by` (`created_by`);

--
-- Indexes for table `animation_settings`
--
ALTER TABLE `animation_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_name` (`setting_name`);

--
-- Indexes for table `cores`
--
ALTER TABLE `cores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `exercises`
--
ALTER TABLE `exercises`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `formations`
--
ALTER TABLE `formations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `med_categories`
--
ALTER TABLE `med_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `operators`
--
ALTER TABLE `operators`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_no` (`personal_no`),
  ADD KEY `cores_id` (`cores_id`),
  ADD KEY `unit_id` (`unit_id`),
  ADD KEY `formation_id` (`formation_id`),
  ADD KEY `med_category_id` (`med_category_id`),
  ADD KEY `fk_operators_exercise` (`exercise_id`);

--
-- Indexes for table `operator_exercises`
--
ALTER TABLE `operator_exercises`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_operator_exercise` (`operator_id`,`exercise_id`),
  ADD KEY `exercise_id` (`exercise_id`);

--
-- Indexes for table `operator_special_notes`
--
ALTER TABLE `operator_special_notes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ranks`
--
ALTER TABLE `ranks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `special_notes`
--
ALTER TABLE `special_notes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `units`
--
ALTER TABLE `units`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_login_log`
--
ALTER TABLE `admin_login_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=107;

--
-- AUTO_INCREMENT for table `admin_users`
--
ALTER TABLE `admin_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `animation_settings`
--
ALTER TABLE `animation_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `cores`
--
ALTER TABLE `cores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `exercises`
--
ALTER TABLE `exercises`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `formations`
--
ALTER TABLE `formations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `med_categories`
--
ALTER TABLE `med_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `operators`
--
ALTER TABLE `operators`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2928;

--
-- AUTO_INCREMENT for table `operator_exercises`
--
ALTER TABLE `operator_exercises`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `operator_special_notes`
--
ALTER TABLE `operator_special_notes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `ranks`
--
ALTER TABLE `ranks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=63;

--
-- AUTO_INCREMENT for table `special_notes`
--
ALTER TABLE `special_notes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `units`
--
ALTER TABLE `units`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=206;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
