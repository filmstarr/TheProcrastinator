-- phpMyAdmin SQL Dump
-- version 2.11.9.5
-- http://www.phpmyadmin.net
--
-- Host: mysql19.streamline.net
-- Generation Time: May 23, 2011 at 09:21 AM
-- Server version: 5.0.77
-- PHP Version: 5.1.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `filmstarr1`
--

-- --------------------------------------------------------

--
-- Table structure for table `answers`
--

CREATE TABLE IF NOT EXISTS `answers` (
  `id` bigint(20) NOT NULL auto_increment,
  `question_id` bigint(20) NOT NULL,
  `udid` char(40) collate latin1_bin NOT NULL,
  `answer` tinyint(1) default NULL,
  `hidden` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `question_id` (`question_id`,`udid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 COLLATE=latin1_bin AUTO_INCREMENT=1194 ;

-- --------------------------------------------------------

--
-- Table structure for table `questions`
--

CREATE TABLE IF NOT EXISTS `questions` (
  `id` bigint(20) NOT NULL auto_increment,
  `udid` char(40) collate latin1_bin NOT NULL,
  `date_asked` datetime NOT NULL,
  `question` mediumtext collate latin1_bin NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `udid` (`udid`,`date_asked`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 COLLATE=latin1_bin AUTO_INCREMENT=459 ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `answers`
--
ALTER TABLE `answers`
  ADD CONSTRAINT `answers_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;