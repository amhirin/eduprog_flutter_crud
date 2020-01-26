CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_password` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'md5',
  `user_full_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_request` datetime DEFAULT NULL,
  `user_session` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
