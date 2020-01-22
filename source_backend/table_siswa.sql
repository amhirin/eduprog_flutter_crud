CREATE TABLE `siswa` (
`id` int(11) NOT NULL AUTO_INCREMENT,
`nama` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`alamat` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`jk` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
`status` int(11) NOT NULL DEFAULT '1' COMMENT '0 = tidak aktif, 1 = aktif',
PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;