SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `transport_management`
--
-- Create database
CREATE DATABASE IF NOT EXISTS transport_management;
USE transport_management;


-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `schedule_id` int(11) NOT NULL,
  `seat_number` int(11) NOT NULL,
  `booking_reference` varchar(20) NOT NULL,
  `status` enum('pending','confirmed','cancelled') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`id`, `user_id`, `schedule_id`, `seat_number`, `booking_reference`, `status`, `created_at`, `updated_at`) VALUES
(1, 5, 9, 2, '6OZK6V25', 'cancelled', '2025-05-03 15:29:52', '2025-05-03 16:14:52'),
(2, 7, 9, 22, 'M9JQ8XGU', 'confirmed', '2025-05-03 16:26:54', '2025-05-03 16:26:54'),
(3, 5, 8, 9, '9ZT4ADTZ', 'confirmed', '2025-05-03 16:49:35', '2025-05-03 16:49:35'),
(4, 7, 8, 10, 'UFRB7NU3', 'confirmed', '2025-05-03 17:12:01', '2025-05-03 17:12:01'),
(5, 5, 11, 3, 'IFF9J6LX', 'confirmed', '2025-05-07 10:06:57', '2025-05-07 10:06:57'),
(6, 5, 7, 20, 'ROUGC84L', 'confirmed', '2025-05-08 02:21:11', '2025-05-08 02:21:11'),
(7, 5, 8, 39, '3GOFCHIC', 'confirmed', '2025-05-08 11:22:14', '2025-05-08 11:22:14'),
(8, 5, 8, 18, 'Q9LWG9AL', 'confirmed', '2025-05-08 12:05:18', '2025-05-08 12:05:18'),
(9, 8, 7, 15, 'EJE1EOOC', 'confirmed', '2025-05-08 12:16:35', '2025-05-08 12:16:35'),
(10, 9, 7, 10, 'D9S7WVXN', 'confirmed', '2025-05-11 22:00:37', '2025-05-11 22:00:37'),
(11, 10, 7, 2, 'B5ET5J73', 'confirmed', '2025-05-12 11:07:00', '2025-05-12 11:07:00');

-- --------------------------------------------------------

--
-- Table structure for table `contact_messages`
--

DROP TABLE IF EXISTS `contact_messages`;
CREATE TABLE `contact_messages` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `subject` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `contact_messages`
--

INSERT INTO `contact_messages` (`id`, `name`, `email`, `subject`, `message`, `is_read`, `created_at`) VALUES
(1, 'Frank', 'frank@gmail.com', 'Car booking', 'From Eldoret to Nairobi', 0, '2025-05-03 13:53:41'),
(2, 'Fidelis', 'fideliswanjiru@gmail.com', 'vehicle delay', 'Today the vehicle came late and I did not like it!!', 0, '2025-05-03 16:31:58'),
(3, 'joseph', 'josejose@gmail.com', 'system speed', 'Your system is working very well and fast.', 0, '2025-05-08 10:48:46');

-- --------------------------------------------------------

--
-- Table structure for table `routes`
--

DROP TABLE IF EXISTS `routes`;
CREATE TABLE `routes` (
  `id` int(11) NOT NULL,
  `origin` varchar(100) NOT NULL,
  `destination` varchar(100) NOT NULL,
  `distance` decimal(10,2) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `routes`
--

INSERT INTO `routes` (`id`, `origin`, `destination`, `distance`, `duration`, `created_at`, `updated_at`) VALUES
(1, 'Eldoret', 'Nairobi', 215.40, 240, '2025-05-03 13:30:32', '2025-05-03 13:56:18'),
(2, 'Kisumu', 'Mombasa', 283.10, 300, '2025-05-03 13:30:32', '2025-05-03 13:56:39'),
(3, 'Eldoret', 'Mombasa', 3803.00, 780, '2025-05-03 13:30:32', '2025-05-03 14:30:16'),
(4, 'Busia', 'Kakamega', 235.60, 210, '2025-05-03 13:30:32', '2025-05-03 14:30:41'),
(5, 'Eldoret', 'Kisumu', 574.20, 680, '2025-05-03 13:30:32', '2025-05-03 14:31:06'),
(6, 'Eldoret', 'Kisii', 2039.80, 510, '2025-05-03 13:30:32', '2025-05-03 14:31:40'),
(7, 'Garissa', 'Turkana', 600.60, 600, '2025-05-03 16:11:17', '2025-05-03 16:11:17'),
(8, 'Nairobi ', 'Murang\'a', 120.00, 150, '2025-05-03 16:38:59', '2025-05-03 16:38:59'),
(9, 'Murang\'a', 'Nyeri', 60.00, 90, '2025-05-06 14:13:17', '2025-05-06 14:17:31'),
(10, 'thika', 'nairobi', 60.00, 60, '2025-05-11 22:07:54', '2025-05-11 22:07:54');

-- --------------------------------------------------------

--
-- Table structure for table `schedules`
--

DROP TABLE IF EXISTS `schedules`;
CREATE TABLE `schedules` (
  `id` int(11) NOT NULL,
  `route_id` int(11) NOT NULL,
  `vehicle_id` int(11) NOT NULL,
  `departure_time` datetime NOT NULL,
  `arrival_time` datetime NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `schedules`
--

INSERT INTO `schedules` (`id`, `route_id`, `vehicle_id`, `departure_time`, `arrival_time`, `price`, `created_at`, `updated_at`) VALUES
(7, 1, 1, '2025-06-01 05:00:00', '2025-06-01 09:00:00', 1300.00, '2025-05-03 15:14:06', '2025-05-06 14:18:36'),
(8, 2, 2, '2025-06-01 06:30:00', '2025-06-01 11:30:00', 2800.00, '2025-05-03 15:14:06', '2025-05-06 14:19:33'),
(9, 3, 3, '2025-06-01 04:15:00', '2025-06-01 10:15:00', 2500.00, '2025-05-03 15:14:06', '2025-05-06 14:18:06'),
(10, 4, 4, '2025-06-01 07:00:00', '2025-06-01 10:30:00', 600.00, '2025-05-03 15:14:06', '2025-05-06 14:19:50'),
(11, 5, 5, '2025-06-01 05:45:00', '2025-06-01 08:45:00', 500.00, '2025-05-03 15:14:06', '2025-05-06 14:19:13'),
(12, 6, 6, '2025-06-01 08:30:00', '2025-06-01 12:00:00', 1200.00, '2025-05-03 15:14:06', '2025-05-06 14:20:01'),
(13, 7, 7, '2025-05-04 16:12:00', '2025-05-05 16:12:00', 2000.00, '2025-05-03 16:13:27', '2025-05-06 14:18:19'),
(14, 9, 8, '2025-05-07 14:00:00', '2025-05-07 15:30:00', 200.00, '2025-05-06 14:16:55', '2025-05-06 14:17:16');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','passenger') NOT NULL DEFAULT 'passenger',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `created_at`, `updated_at`) VALUES
(2, 'Kelvin', 'kelvin@gmail.com', '$2b$10$3T9YviyMrSWAgjCEqcGxTub1gKjrLFWRZ2yHfYI07TLwGJJ6FfhWC', 'admin', '2025-05-03 13:57:22', '2025-05-03 14:25:14'),
(5, 'kelvin', 'kelvinkaharu@gmail.com', '$2b$10$A6jRL9EpzeFNPD9rF1G7.OosopwLrietGauluQf7f3PH65XMjlylS', 'passenger', '2025-05-03 14:35:33', '2025-05-03 14:35:33'),
(6, 'peter', 'peter@gmail.com', '$2b$10$dNA.Ri/0PBm7QZgZ.pyrUe7SnAaFwyGWVLPm8..vkD4UP9/QJfH3q', 'passenger', '2025-05-03 15:34:24', '2025-05-03 15:34:24'),
(7, 'Fidelis', 'fideliswanjiru@gmail.com', '$2b$10$r3Y/w5dIR5V3v6bPcyYNCukkKH/zrqs/G9k0fmYICZukQcI97Abxe', 'passenger', '2025-05-03 16:22:58', '2025-05-03 16:22:58'),
(8, 'evans', 'kimevans222@gmail.com', '$2b$10$e2DmtugArD1qWr5xXnIE5u0gUb6g22y1i1xIxp7K2SmhzQDLsrJZK', 'passenger', '2025-05-08 12:10:13', '2025-05-08 12:10:13'),
(9, 'esther', 'estherm@gmail.com', '$2b$10$WrQFJexoHm0oOH/Hqug2.e8b8YkIJsr1Zja4fRPooOP2Jdealy8G.', 'passenger', '2025-05-11 21:59:58', '2025-05-11 21:59:58'),
(10, 'kogo', 'kogo@gmail.com', '$2b$10$.JzfGu2jHEZNuW9piKdMmuyoLRPuh2XfZd.ajn9ymMf7ZISiaD/wq', 'passenger', '2025-05-12 11:04:22', '2025-05-12 11:04:22');

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

DROP TABLE IF EXISTS `vehicles`;
CREATE TABLE `vehicles` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `registration_number` varchar(20) NOT NULL,
  `capacity` int(11) NOT NULL,
  `route_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `image_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vehicles`
--

INSERT INTO `vehicles` (`id`, `name`, `registration_number`, `capacity`, `route_id`, `created_at`, `updated_at`, `image_url`) VALUES
(1, 'Express Bus 1', 'KCX 123V', 45, 1, '2025-05-03 13:30:33', '2025-05-08 12:54:39', 'https://cdn.pixabay.com/photo/2020/05/07/20/29/bus-5143052_640.jpg'),
(2, 'City Liner', 'KDC 567F', 60, 2, '2025-05-03 13:30:33', '2025-05-11 21:24:07', 'https://media.istockphoto.com/id/2189960954/photo/higer-coach-bus.jpg?s=612x612&w=0&k=20&c=jn_eMX6dhMWcEn9dlHWz4K6smu3SWK3GeXk9k5xvLdA='),
(3, 'Coastal Express', 'KDM 401A', 64, 3, '2025-05-03 13:30:33', '2025-05-11 21:27:28', 'https://media.istockphoto.com/id/1195980891/photo/bus-of-sombat-tour.jpg?s=612x612&w=0&k=20&c=lE7PwDZfS9Palww6U4iU8Wyk_bOeVwWrSWHwwhf9Gdg='),
(4, 'Sunshine Shuttle', 'KDN 345V', 20, 4, '2025-05-03 13:30:33', '2025-05-11 21:29:32', 'https://www.aeroconnectllc.com/img/uploads/product_image/162719909320-seater-Bus-Hire.jpg'),
(5, 'Northwest Transit', 'KDA 789V', 48, 5, '2025-05-03 13:30:33', '2025-05-11 21:37:54', 'https://www.luxuryarttransport.com/backend/public/uploads/buses/35-seater-bus-side.png'),
(6, 'Texas Cruiser', 'KDP 135S', 42, 6, '2025-05-03 13:30:33', '2025-05-11 21:33:40', 'https://sc04.alicdn.com/kf/HTB1y9OlX0fvK1RjSszhq6AcGFXad.jpg'),
(7, 'Matatu', 'KCB 030B', 14, 7, '2025-05-03 16:12:19', '2025-05-11 21:35:06', 'https://masharikishuttles.com/wp-content/uploads/2022/07/Mashariki-Shuttle-Vehicle-02.webp'),
(8, 'County Minibus', 'KDP 631E', 30, 9, '2025-05-06 14:14:07', '2025-05-11 21:36:14', 'https://image.made-in-china.com/2f0j00FyKiUvpWLjqG/30-Passenger-Mini-Bus-and-Electric-Mini-Bus-with-Mini-Bus-for-Tanzania.webp'),
(9, 'thika express', 'KDK 564D', 38, 10, '2025-05-11 22:08:43', '2025-05-11 22:13:40', 'https://s.alicdn.com/@sc04/kf/H44bed348967a4c6e869cd69b58738990X.jpg_300x300.jpg');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `booking_reference` (`booking_reference`),
  ADD UNIQUE KEY `schedule_id` (`schedule_id`,`seat_number`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `contact_messages`
--
ALTER TABLE `contact_messages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `routes`
--
ALTER TABLE `routes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `schedules`
--
ALTER TABLE `schedules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `route_id` (`route_id`),
  ADD KEY `vehicle_id` (`vehicle_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `registration_number` (`registration_number`),
  ADD KEY `route_id` (`route_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `contact_messages`
--
ALTER TABLE `contact_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `routes`
--
ALTER TABLE `routes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `schedules`
--
ALTER TABLE `schedules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`schedule_id`) REFERENCES `schedules` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `schedules`
--
ALTER TABLE `schedules`
  ADD CONSTRAINT `schedules_ibfk_1` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `schedules_ibfk_2` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD CONSTRAINT `vehicles_ibfk_1` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
