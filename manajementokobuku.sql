-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 24, 2024 at 11:14 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `manajementokobuku`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `tampilkan_buku` ()   BEGIN
    SELECT * FROM Buku;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_harga` (IN `buku_id` INT, IN `harga_baru` DECIMAL(10,2))   BEGIN
    UPDATE Buku SET harga = harga_baru WHERE id_buku = buku_id;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `harga_total` (`id_pesanan` INT, `diskon` DECIMAL(10,2)) RETURNS DECIMAL(10,2)  BEGIN
    DECLARE total DECIMAL(10, 2);
    SELECT SUM(b.harga * dp.jumlah) - diskon INTO total
    FROM Detail_Pesanan dp
    JOIN Buku b ON dp.id_buku = b.id_buku
    WHERE dp.id_pesanan = id_pesanan;
    RETURN total;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `jumlah_buku` () RETURNS INT(11)  BEGIN
    DECLARE jumlah INT;
    SELECT COUNT(*) INTO jumlah FROM Buku;
    RETURN jumlah;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `buku`
--

CREATE TABLE `buku` (
  `id_buku` int(11) NOT NULL,
  `judul` varchar(100) DEFAULT NULL,
  `harga` decimal(10,2) DEFAULT NULL,
  `stok` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `buku`
--

INSERT INTO `buku` (`id_buku`, `judul`, `harga`, `stok`) VALUES
(1, 'Bumi Manusia', 106000.00, 13),
(2, 'Laskar Pelangi', 76000.00, 11),
(3, 'Daun Yang Jatuh Tak Pernah Membenci Angin', 69000.00, 15),
(4, 'Cantik itu Luka', 105000.00, 15),
(5, 'Rumah Kaca', 67000.00, 12),
(6, 'Jejak Langkah', 65000.00, 15);

--
-- Triggers `buku`
--
DELIMITER $$
CREATE TRIGGER `sebelum_delete_buku` BEFORE DELETE ON `buku` FOR EACH ROW BEGIN
    INSERT INTO Log_Trigger (trigger_event, event_time, old_data)
    VALUES ('BEFORE DELETE ON Buku', NOW(), CONCAT('OLD.id_buku: ', OLD.id_buku));
    DELETE FROM Detail_Pesanan WHERE id_buku = OLD.id_buku;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `sebelum_update_buku` BEFORE UPDATE ON `buku` FOR EACH ROW BEGIN
    INSERT INTO Log_Trigger (trigger_event, event_time, old_data, new_data)
    VALUES ('BEFORE UPDATE ON Buku', NOW(), CONCAT('OLD.harga: ', OLD.harga), CONCAT('NEW.harga: ', NEW.harga));
    IF NEW.harga < 0 THEN
        SET NEW.harga = OLD.harga;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `buku_kategori`
--

CREATE TABLE `buku_kategori` (
  `id_buku` int(11) NOT NULL,
  `id_kategori` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `buku_kategori`
--

INSERT INTO `buku_kategori` (`id_buku`, `id_kategori`) VALUES
(1, 1),
(1, 5),
(2, 1),
(3, 1),
(4, 1),
(5, 1);

-- --------------------------------------------------------

--
-- Table structure for table `detail_pelanggan`
--

CREATE TABLE `detail_pelanggan` (
  `id_pelanggan` int(11) NOT NULL,
  `informasi_tambahan` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detail_pelanggan`
--

INSERT INTO `detail_pelanggan` (`id_pelanggan`, `informasi_tambahan`) VALUES
(1, 'Pelanggan baru'),
(2, 'Pelanggan baru'),
(3, 'Pelanggan baru'),
(4, 'Pelanggan baru'),
(5, 'Pelanggan baru');

-- --------------------------------------------------------

--
-- Table structure for table `detail_pesanan`
--

CREATE TABLE `detail_pesanan` (
  `id_detail` int(11) NOT NULL,
  `id_pesanan` int(11) DEFAULT NULL,
  `id_buku` int(11) DEFAULT NULL,
  `jumlah` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detail_pesanan`
--

INSERT INTO `detail_pesanan` (`id_detail`, `id_pesanan`, `id_buku`, `jumlah`) VALUES
(1, 1, 5, 5),
(2, 2, 1, 6),
(3, 3, 4, 3),
(4, 4, 2, 4),
(6, 3, 2, 3),
(7, 4, 2, 3);

--
-- Triggers `detail_pesanan`
--
DELIMITER $$
CREATE TRIGGER `sesudah_insert_detail` AFTER INSERT ON `detail_pesanan` FOR EACH ROW BEGIN
    INSERT INTO Log_Trigger (trigger_event, event_time, new_data)
    VALUES ('AFTER INSERT ON Detail_Pesanan', NOW(), CONCAT('NEW.id_buku: ', NEW.id_buku, ', NEW.jumlah: ', NEW.jumlah));
    UPDATE Buku SET stok = stok - NEW.jumlah WHERE id_buku = NEW.id_buku;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `sesudah_update_detail` AFTER UPDATE ON `detail_pesanan` FOR EACH ROW BEGIN
    INSERT INTO Log_Trigger (trigger_event, event_time, old_data, new_data)
    VALUES ('AFTER UPDATE ON Detail_Pesanan', NOW(), CONCAT('OLD.jumlah: ', OLD.jumlah), CONCAT('NEW.jumlah: ', NEW.jumlah));
    UPDATE Buku SET stok = stok - NEW.jumlah + OLD.jumlah WHERE id_buku = NEW.id_buku;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `kategori`
--

CREATE TABLE `kategori` (
  `id_kategori` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kategori`
--

INSERT INTO `kategori` (`id_kategori`, `nama`) VALUES
(1, 'Fiksi'),
(2, 'Non-Fiksi'),
(3, 'Sains'),
(5, 'Sejarah'),
(4, 'Teknologi');

-- --------------------------------------------------------

--
-- Table structure for table `log_trigger`
--

CREATE TABLE `log_trigger` (
  `id_log` int(11) NOT NULL,
  `trigger_event` varchar(100) DEFAULT NULL,
  `event_time` datetime DEFAULT NULL,
  `old_data` text DEFAULT NULL,
  `new_data` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_trigger`
--

INSERT INTO `log_trigger` (`id_log`, `trigger_event`, `event_time`, `old_data`, `new_data`) VALUES
(1, 'BEFORE INSERT ON Pesanan', '2024-07-19 18:42:54', NULL, 'NEW.tanggal_pesanan: 2024-06-30'),
(2, 'AFTER INSERT ON Detail_Pesanan', '2024-07-19 18:43:17', NULL, 'NEW.id_buku: 1, NEW.jumlah: 2'),
(3, 'BEFORE UPDATE ON Buku', '2024-07-19 18:43:41', 'OLD.harga: 150000.00', 'NEW.harga: 108000.00'),
(4, 'AFTER UPDATE ON Detail_Pesanan', '2024-07-19 18:44:00', 'OLD.jumlah: 3', 'NEW.jumlah: 3'),
(5, 'BEFORE UPDATE ON Buku', '2024-07-19 18:44:00', 'OLD.harga: 69000.00', 'NEW.harga: 69000.00'),
(6, 'BEFORE UPDATE ON Buku', '2024-07-19 18:51:10', 'OLD.harga: 66000.00', 'NEW.harga: 67000.00'),
(7, 'AFTER INSERT ON Detail_Pesanan', '2024-07-19 18:51:45', NULL, 'NEW.id_buku: 2, NEW.jumlah: 3'),
(8, 'BEFORE UPDATE ON Buku', '2024-07-19 18:51:45', 'OLD.harga: 76000.00', 'NEW.harga: 76000.00'),
(9, 'AFTER UPDATE ON Detail_Pesanan', '2024-07-19 18:52:03', 'OLD.jumlah: 2', 'NEW.jumlah: 3'),
(10, 'BEFORE UPDATE ON Buku', '2024-07-19 18:52:03', 'OLD.harga: 76000.00', 'NEW.harga: 76000.00'),
(11, 'AFTER DELETE ON Pesanan', '2024-07-19 18:55:24', 'OLD.id_pesanan: 5', NULL),
(12, 'BEFORE UPDATE ON Buku', '2024-07-19 19:40:39', 'OLD.harga: 108000.00', 'NEW.harga: 108000.00'),
(13, 'BEFORE UPDATE ON Buku', '2024-07-19 19:41:14', 'OLD.harga: 108000.00', 'NEW.harga: 106000.00');

-- --------------------------------------------------------

--
-- Table structure for table `pelanggan`
--

CREATE TABLE `pelanggan` (
  `id_pelanggan` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `alamat` varchar(200) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pelanggan`
--

INSERT INTO `pelanggan` (`id_pelanggan`, `nama`, `alamat`, `email`) VALUES
(1, 'alex', 'Boyolali', 'dini@mail.com'),
(2, 'Sela', 'Lampung', 'sela@mail.com'),
(3, 'Windi', 'Sragen', 'windi@mail.com'),
(4, 'Notla', 'Sragen', 'notla@mail.com'),
(5, 'Tyo', 'Jepara', 'tyo@mail.com');

-- --------------------------------------------------------

--
-- Table structure for table `pengarang`
--

CREATE TABLE `pengarang` (
  `id_pengarang` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pengarang`
--

INSERT INTO `pengarang` (`id_pengarang`, `nama`) VALUES
(1, 'Pramoedya Ananta Toer'),
(2, 'Andrea Hirata'),
(3, 'Tere Liye'),
(4, 'Eka Kurniawan'),
(5, 'Dee Lestari');

-- --------------------------------------------------------

--
-- Table structure for table `pesanan`
--

CREATE TABLE `pesanan` (
  `id_pesanan` int(11) NOT NULL,
  `id_pelanggan` int(11) DEFAULT NULL,
  `tanggal_pesanan` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pesanan`
--

INSERT INTO `pesanan` (`id_pesanan`, `id_pelanggan`, `tanggal_pesanan`) VALUES
(1, 1, '2024-06-24'),
(2, 2, '2024-06-25'),
(3, 3, '2024-06-26'),
(4, 4, '2024-06-27'),
(6, 1, '2024-07-19');

--
-- Triggers `pesanan`
--
DELIMITER $$
CREATE TRIGGER `sebelum_insert_pesanan` BEFORE INSERT ON `pesanan` FOR EACH ROW BEGIN
    INSERT INTO Log_Trigger (trigger_event, event_time, new_data)
    VALUES ('BEFORE INSERT ON Pesanan', NOW(), CONCAT('NEW.tanggal_pesanan: ', NEW.tanggal_pesanan));
    SET NEW.tanggal_pesanan = CURDATE();
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `sesudah_delete_pesanan` AFTER DELETE ON `pesanan` FOR EACH ROW BEGIN
    INSERT INTO Log_Trigger (trigger_event, event_time, old_data)
    VALUES ('AFTER DELETE ON Pesanan', NOW(), CONCAT('OLD.id_pesanan: ', OLD.id_pesanan));
    DELETE FROM Detail_Pesanan WHERE id_pesanan = OLD.id_pesanan;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_buku`
-- (See below for the actual view)
--
CREATE TABLE `v_buku` (
`id_buku` int(11)
,`judul` varchar(100)
,`harga` decimal(10,2)
,`stok` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_detail_pesanan`
-- (See below for the actual view)
--
CREATE TABLE `v_detail_pesanan` (
`id_detail` int(11)
,`id_pesanan` int(11)
,`id_buku` int(11)
,`jumlah` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_pelanggan_pesanan`
-- (See below for the actual view)
--
CREATE TABLE `v_pelanggan_pesanan` (
`id_pelanggan` int(11)
,`nama` varchar(100)
,`id_pesanan` int(11)
,`tanggal_pesanan` date
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_pesanan`
-- (See below for the actual view)
--
CREATE TABLE `v_pesanan` (
`id_pesanan` int(11)
,`id_pelanggan` int(11)
,`tanggal_pesanan` date
);

-- --------------------------------------------------------

--
-- Structure for view `v_buku`
--
DROP TABLE IF EXISTS `v_buku`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_buku`  AS SELECT `buku`.`id_buku` AS `id_buku`, `buku`.`judul` AS `judul`, `buku`.`harga` AS `harga`, `buku`.`stok` AS `stok` FROM `buku` WHERE `buku`.`stok` > 13 ;

-- --------------------------------------------------------

--
-- Structure for view `v_detail_pesanan`
--
DROP TABLE IF EXISTS `v_detail_pesanan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_detail_pesanan`  AS SELECT `detail_pesanan`.`id_detail` AS `id_detail`, `detail_pesanan`.`id_pesanan` AS `id_pesanan`, `detail_pesanan`.`id_buku` AS `id_buku`, `detail_pesanan`.`jumlah` AS `jumlah` FROM `detail_pesanan` ;

-- --------------------------------------------------------

--
-- Structure for view `v_pelanggan_pesanan`
--
DROP TABLE IF EXISTS `v_pelanggan_pesanan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_pelanggan_pesanan`  AS SELECT `c`.`id_pelanggan` AS `id_pelanggan`, `c`.`nama` AS `nama`, `p`.`id_pesanan` AS `id_pesanan`, `p`.`tanggal_pesanan` AS `tanggal_pesanan` FROM (`pelanggan` `c` join `v_pesanan` `p` on(`c`.`id_pelanggan` = `p`.`id_pelanggan`))WITH CASCADED CHECK OPTION  ;

-- --------------------------------------------------------

--
-- Structure for view `v_pesanan`
--
DROP TABLE IF EXISTS `v_pesanan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_pesanan`  AS SELECT `pesanan`.`id_pesanan` AS `id_pesanan`, `pesanan`.`id_pelanggan` AS `id_pelanggan`, `pesanan`.`tanggal_pesanan` AS `tanggal_pesanan` FROM `pesanan` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `buku`
--
ALTER TABLE `buku`
  ADD PRIMARY KEY (`id_buku`),
  ADD KEY `idx_judul` (`judul`),
  ADD KEY `idx_harga_stok` (`harga`,`stok`);

--
-- Indexes for table `buku_kategori`
--
ALTER TABLE `buku_kategori`
  ADD PRIMARY KEY (`id_buku`,`id_kategori`),
  ADD KEY `id_kategori` (`id_kategori`);

--
-- Indexes for table `detail_pelanggan`
--
ALTER TABLE `detail_pelanggan`
  ADD PRIMARY KEY (`id_pelanggan`);

--
-- Indexes for table `detail_pesanan`
--
ALTER TABLE `detail_pesanan`
  ADD PRIMARY KEY (`id_detail`),
  ADD KEY `id_buku` (`id_buku`),
  ADD KEY `detail_pesanan_ibfk_1` (`id_pesanan`);

--
-- Indexes for table `kategori`
--
ALTER TABLE `kategori`
  ADD PRIMARY KEY (`id_kategori`),
  ADD KEY `idx_nama_kategori` (`nama`);

--
-- Indexes for table `log_trigger`
--
ALTER TABLE `log_trigger`
  ADD PRIMARY KEY (`id_log`);

--
-- Indexes for table `pelanggan`
--
ALTER TABLE `pelanggan`
  ADD PRIMARY KEY (`id_pelanggan`);

--
-- Indexes for table `pengarang`
--
ALTER TABLE `pengarang`
  ADD PRIMARY KEY (`id_pengarang`);

--
-- Indexes for table `pesanan`
--
ALTER TABLE `pesanan`
  ADD PRIMARY KEY (`id_pesanan`),
  ADD KEY `id_pelanggan` (`id_pelanggan`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `log_trigger`
--
ALTER TABLE `log_trigger`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `buku_kategori`
--
ALTER TABLE `buku_kategori`
  ADD CONSTRAINT `buku_kategori_ibfk_1` FOREIGN KEY (`id_buku`) REFERENCES `buku` (`id_buku`),
  ADD CONSTRAINT `buku_kategori_ibfk_2` FOREIGN KEY (`id_kategori`) REFERENCES `kategori` (`id_kategori`);

--
-- Constraints for table `detail_pelanggan`
--
ALTER TABLE `detail_pelanggan`
  ADD CONSTRAINT `detail_pelanggan_ibfk_1` FOREIGN KEY (`id_pelanggan`) REFERENCES `pelanggan` (`id_pelanggan`);

--
-- Constraints for table `detail_pesanan`
--
ALTER TABLE `detail_pesanan`
  ADD CONSTRAINT `detail_pesanan_ibfk_1` FOREIGN KEY (`id_pesanan`) REFERENCES `pesanan` (`id_pesanan`) ON DELETE CASCADE,
  ADD CONSTRAINT `detail_pesanan_ibfk_2` FOREIGN KEY (`id_buku`) REFERENCES `buku` (`id_buku`);

--
-- Constraints for table `pesanan`
--
ALTER TABLE `pesanan`
  ADD CONSTRAINT `pesanan_ibfk_1` FOREIGN KEY (`id_pelanggan`) REFERENCES `pelanggan` (`id_pelanggan`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
