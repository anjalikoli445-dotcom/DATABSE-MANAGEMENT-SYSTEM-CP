-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: tripwise
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `destination`
--

DROP TABLE IF EXISTS `destination`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `destination` (
  `destination_id` int NOT NULL AUTO_INCREMENT,
  `destination_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `state` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'India',
  `description` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`destination_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `destination`
--

LOCK TABLES `destination` WRITE;
/*!40000 ALTER TABLE `destination` DISABLE KEYS */;
INSERT INTO `destination` VALUES (1,'Mumbai','Maharashtra','India','City of dreams, beaches and heritage'),(2,'Pune','Maharashtra','India','Cultural capital of Maharashtra'),(3,'Goa','Goa','India','Beaches, nightlife and Portuguese heritage'),(4,'Jaipur','Rajasthan','India','The Pink City with palaces and forts'),(5,'Agra','Uttar Pradesh','India','Home of the iconic Taj Mahal'),(6,'Srinagar','Jammu & Kashmir','India','Dal Lake, shikaras and Mughal gardens'),(7,'Alleppey','Kerala','India','Venice of the East - backwaters and houseboats'),(8,'Munnar','Kerala','India','Rolling tea gardens and misty hills'),(9,'Hampi','Karnataka','India','Ancient ruins of the Vijayanagara Empire'),(10,'Mysore','Karnataka','India','Royal palaces and rich heritage'),(11,'Udaipur','Rajasthan','India','City of Lakes and royal palaces'),(12,'Jaisalmer','Rajasthan','India','Golden City in the Thar Desert'),(13,'Ahmedabad','Gujarat','India','UNESCO Heritage City and Sabarmati Ashram'),(14,'Rann of Kutch','Gujarat','India','White salt desert and vibrant culture'),(15,'Amritsar','Punjab','India','Golden Temple and rich Sikh heritage'),(16,'Varanasi','Uttar Pradesh','India','Spiritual capital on the Ganges'),(17,'Leh','Ladakh','India','High-altitude desert and monasteries'),(18,'Shillong','Meghalaya','India','Scotland of the East'),(19,'Darjeeling','West Bengal','India','Tea gardens and Himalayan views'),(20,'Puri','Odisha','India','Jagannath Temple and golden beaches'),(21,'Rishikesh','Uttarakhand','India','Yoga capital and Ganges rafting'),(22,'Chennai','Tamil Nadu','India','Gateway to South India'),(23,'Madurai','Tamil Nadu','India','Temple city with rich Dravidian heritage'),(24,'Pondicherry','Puducherry','India','French colonial charm and beaches');
/*!40000 ALTER TABLE `destination` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expense`
--

DROP TABLE IF EXISTS `expense`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expense` (
  `expense_id` int NOT NULL AUTO_INCREMENT,
  `trip_id` int NOT NULL,
  `expense_type` enum('Transportation','Food','Entry Fee','Hotel','Other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`expense_id`),
  KEY `trip_id` (`trip_id`),
  CONSTRAINT `expense_ibfk_1` FOREIGN KEY (`trip_id`) REFERENCES `trip` (`trip_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expense`
--

LOCK TABLES `expense` WRITE;
/*!40000 ALTER TABLE `expense` DISABLE KEYS */;
INSERT INTO `expense` VALUES (1,1,'Entry Fee',0.00,'Auto-generated'),(2,1,'Transportation',0.00,'Auto-generated'),(3,2,'Entry Fee',100.00,'Auto-generated'),(4,2,'Transportation',0.00,'Auto-generated'),(5,3,'Entry Fee',50.00,'Auto-generated'),(6,3,'Transportation',0.00,'Auto-generated'),(7,4,'Entry Fee',0.00,'Auto-generated'),(8,4,'Transportation',0.00,'Auto-generated'),(9,5,'Entry Fee',0.00,'Auto-generated'),(10,5,'Transportation',350.00,'Auto-generated'),(11,6,'Entry Fee',0.00,'Auto-generated'),(12,6,'Transportation',750.00,'Auto-generated'),(13,7,'Entry Fee',0.00,'Auto-generated'),(14,7,'Transportation',180.00,'Auto-generated'),(15,8,'Entry Fee',0.00,'Auto-generated'),(16,8,'Transportation',350.00,'Auto-generated');
/*!40000 ALTER TABLE `expense` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_expense_after_delete` AFTER DELETE ON `expense` FOR EACH ROW BEGIN
    INSERT INTO EXPENSE_LOG (trip_id, deleted_amount)
    VALUES (OLD.trip_id, OLD.amount);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `expense_log`
--

DROP TABLE IF EXISTS `expense_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expense_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `trip_id` int DEFAULT NULL,
  `deleted_amount` decimal(10,2) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expense_log`
--

LOCK TABLES `expense_log` WRITE;
/*!40000 ALTER TABLE `expense_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `expense_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `itinerary`
--

DROP TABLE IF EXISTS `itinerary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `itinerary` (
  `itinerary_id` int NOT NULL AUTO_INCREMENT,
  `trip_id` int NOT NULL,
  `place_id` int DEFAULT NULL,
  `transport_id` int DEFAULT NULL,
  `arrival_time` time DEFAULT NULL,
  `departure_time` time DEFAULT NULL,
  `travel_cost` decimal(10,2) DEFAULT '0.00',
  PRIMARY KEY (`itinerary_id`),
  KEY `trip_id` (`trip_id`),
  KEY `place_id` (`place_id`),
  KEY `transport_id` (`transport_id`),
  CONSTRAINT `itinerary_ibfk_1` FOREIGN KEY (`trip_id`) REFERENCES `trip` (`trip_id`) ON DELETE CASCADE,
  CONSTRAINT `itinerary_ibfk_2` FOREIGN KEY (`place_id`) REFERENCES `place` (`place_id`) ON DELETE SET NULL,
  CONSTRAINT `itinerary_ibfk_3` FOREIGN KEY (`transport_id`) REFERENCES `transport` (`transport_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `itinerary`
--

LOCK TABLES `itinerary` WRITE;
/*!40000 ALTER TABLE `itinerary` DISABLE KEYS */;
INSERT INTO `itinerary` VALUES (1,1,9,NULL,'09:00:00','12:00:00',0.00),(2,2,11,NULL,'09:00:00','12:00:00',0.00),(3,3,9,NULL,'09:00:00','12:00:00',0.00),(4,3,10,NULL,'12:00:00','13:30:00',0.00),(5,4,2,NULL,'09:00:00','10:30:00',0.00),(6,5,2,NULL,'09:00:00','10:30:00',0.00),(7,5,3,5,'11:10:00','13:10:00',350.00),(8,6,2,NULL,'09:00:00','10:30:00',0.00),(9,6,3,5,'11:10:00','13:10:00',350.00),(10,6,4,5,'14:00:00','15:30:00',400.00),(11,7,2,NULL,'09:00:00','10:30:00',0.00),(12,7,1,5,'10:45:00','11:45:00',180.00),(13,7,3,NULL,'11:45:00','13:45:00',0.00),(14,8,2,NULL,'09:00:00','10:30:00',0.00),(15,8,3,5,'11:10:00','13:10:00',350.00);
/*!40000 ALTER TABLE `itinerary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `place`
--

DROP TABLE IF EXISTS `place`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `place` (
  `place_id` int NOT NULL AUTO_INCREMENT,
  `destination_id` int NOT NULL,
  `place_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `rating` decimal(2,1) DEFAULT '0.0',
  `entry_fee` decimal(10,2) DEFAULT '0.00',
  `visit_duration` int DEFAULT '60',
  PRIMARY KEY (`place_id`),
  KEY `destination_id` (`destination_id`),
  CONSTRAINT `place_ibfk_1` FOREIGN KEY (`destination_id`) REFERENCES `destination` (`destination_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `place`
--

LOCK TABLES `place` WRITE;
/*!40000 ALTER TABLE `place` DISABLE KEYS */;
INSERT INTO `place` VALUES (1,1,'Gateway of India','Monument',NULL,4.6,0.00,60),(2,1,'Marine Drive','Beach',NULL,4.7,0.00,90),(3,1,'Juhu Beach','Beach',NULL,4.3,0.00,120),(4,1,'Colaba Causeway','Market',NULL,4.2,0.00,90),(5,1,'Elephanta Caves','Heritage',NULL,4.5,40.00,180),(6,2,'Shaniwar Wada','Fort',NULL,4.4,25.00,90),(7,2,'Aga Khan Palace','Heritage',NULL,4.5,20.00,75),(8,2,'Dagdusheth Ganpati','Temple',NULL,4.8,0.00,45),(9,3,'Baga Beach','Beach',NULL,4.6,0.00,180),(10,3,'Fort Aguada','Fort',NULL,4.4,50.00,90),(11,4,'Amber Fort','Fort',NULL,4.7,100.00,180),(12,4,'Hawa Mahal','Monument',NULL,4.5,50.00,60),(13,4,'City Palace','Palace',NULL,4.6,200.00,120);
/*!40000 ALTER TABLE `place` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `route`
--

DROP TABLE IF EXISTS `route`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `route` (
  `route_id` int NOT NULL AUTO_INCREMENT,
  `source_place_id` int NOT NULL,
  `destination_place_id` int NOT NULL,
  `transport_id` int NOT NULL,
  `distance` decimal(6,2) DEFAULT NULL,
  `travel_time` int DEFAULT NULL,
  `estimated_cost` decimal(10,2) DEFAULT NULL,
  `comfort_level` enum('Low','Medium','High') COLLATE utf8mb4_unicode_ci DEFAULT 'Medium',
  PRIMARY KEY (`route_id`),
  KEY `source_place_id` (`source_place_id`),
  KEY `destination_place_id` (`destination_place_id`),
  KEY `transport_id` (`transport_id`),
  CONSTRAINT `route_ibfk_1` FOREIGN KEY (`source_place_id`) REFERENCES `place` (`place_id`) ON DELETE CASCADE,
  CONSTRAINT `route_ibfk_2` FOREIGN KEY (`destination_place_id`) REFERENCES `place` (`place_id`) ON DELETE CASCADE,
  CONSTRAINT `route_ibfk_3` FOREIGN KEY (`transport_id`) REFERENCES `transport` (`transport_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `route`
--

LOCK TABLES `route` WRITE;
/*!40000 ALTER TABLE `route` DISABLE KEYS */;
INSERT INTO `route` VALUES (1,1,2,3,5.00,25,20.00,'Low'),(2,1,2,5,5.00,15,180.00,'High'),(3,1,2,2,5.00,20,100.00,'Medium'),(4,2,3,5,18.00,40,350.00,'High'),(5,2,3,2,18.00,55,220.00,'Medium'),(6,3,4,5,20.00,50,400.00,'High'),(7,1,5,5,12.00,30,250.00,'High'),(8,1,5,3,12.00,45,40.00,'Low');
/*!40000 ALTER TABLE `route` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `selected_place`
--

DROP TABLE IF EXISTS `selected_place`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `selected_place` (
  `trip_id` int NOT NULL,
  `place_id` int NOT NULL,
  `visit_order` int NOT NULL,
  `planned_duration` int DEFAULT NULL,
  PRIMARY KEY (`trip_id`,`place_id`),
  KEY `place_id` (`place_id`),
  CONSTRAINT `selected_place_ibfk_1` FOREIGN KEY (`trip_id`) REFERENCES `trip` (`trip_id`) ON DELETE CASCADE,
  CONSTRAINT `selected_place_ibfk_2` FOREIGN KEY (`place_id`) REFERENCES `place` (`place_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `selected_place`
--

LOCK TABLES `selected_place` WRITE;
/*!40000 ALTER TABLE `selected_place` DISABLE KEYS */;
INSERT INTO `selected_place` VALUES (1,9,1,180),(2,11,1,180),(3,9,1,180),(3,10,2,90),(4,2,1,90),(5,2,1,90),(5,3,2,120),(6,2,1,90),(6,3,2,120),(6,4,3,90),(7,1,2,60),(7,2,1,90),(7,3,3,120),(8,2,1,90),(8,3,2,120);
/*!40000 ALTER TABLE `selected_place` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stay_and_food`
--

DROP TABLE IF EXISTS `stay_and_food`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stay_and_food` (
  `id` int NOT NULL AUTO_INCREMENT,
  `destination_id` int NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('Hotel','Restaurant','Lodge','Sweet Shop') COLLATE utf8mb4_unicode_ci NOT NULL,
  `rating` decimal(2,1) DEFAULT '4.0',
  `price_range` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `destination_id` (`destination_id`),
  CONSTRAINT `stay_and_food_ibfk_1` FOREIGN KEY (`destination_id`) REFERENCES `destination` (`destination_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stay_and_food`
--

LOCK TABLES `stay_and_food` WRITE;
/*!40000 ALTER TABLE `stay_and_food` DISABLE KEYS */;
INSERT INTO `stay_and_food` VALUES (1,1,'The Taj Mahal Palace','Hotel',4.9,'₹20,000+','Luxury heritage hotel'),(2,1,'Residency Hotel Fort','Hotel',4.3,'₹5,000 - ₹8,000','Moderate, near Gateway'),(3,1,'Bandra Backpackers','Lodge',4.1,'₹800 - ₹1,200','Budget hostel'),(4,1,'Leopold Cafe','Restaurant',4.5,'₹1,200 for two','Moderate famous cafe'),(5,1,'Bademiya','Restaurant',4.3,'₹400 for two','Budget street food'),(6,1,'Bombay Sweet Shop','Sweet Shop',4.6,'₹150 - ₹500','Famous sweets'),(7,2,'Conrad Pune','Hotel',4.8,'₹12,000+','Luxury 5-star'),(8,2,'Lemon Tree Premier','Hotel',4.3,'₹5,000 - ₹7,000','Moderate, City Center'),(9,2,'Zostel Pune','Lodge',4.2,'₹600 - ₹1,000','Budget backpacker'),(10,2,'Shabree','Restaurant',4.5,'₹800 for two','Authentic Maharashtrian thali'),(11,2,'German Bakery','Restaurant',4.4,'₹600 for two','Budget cafe'),(12,3,'Taj Fort Aguada','Hotel',4.8,'₹15,000+','Luxury beach resort'),(13,3,'Lemon Tree Amarante','Hotel',4.4,'₹6,000 - ₹9,000','Moderate resort'),(14,3,'Zostel Goa','Lodge',4.3,'₹700 - ₹1,200','Budget beachside hostel'),(15,3,'Britto\'s','Restaurant',4.4,'₹1,500 for two','Moderate Goan seafood'),(16,3,'Infantaria','Restaurant',4.2,'₹1,000 for two','Budget breakfast'),(17,4,'Rambagh Palace','Hotel',4.9,'₹35,000+','Luxury royal palace'),(18,4,'Alsisar Haveli','Hotel',4.6,'₹6,000 - ₹10,000','Moderate heritage hotel'),(19,4,'Zostel Jaipur','Lodge',4.2,'₹500 - ₹900','Budget hostel'),(20,4,'Spice Court','Restaurant',4.5,'₹1,000 for two','Moderate Rajasthani food'),(21,4,'Rawat Mishthan Bhandar','Sweet Shop',4.6,'₹100 - ₹300','Famous Pyaz Kachori'),(22,5,'The Oberoi Amarvilas','Hotel',4.9,'₹76,000+','Luxury with Taj view'),(23,5,'Fairfield by Marriott','Hotel',4.5,'₹6,000 - ₹9,000','Moderate 4-star'),(24,5,'Hotel Orange','Hotel',3.8,'₹5,000+','Budget stay'),(25,5,'Esphahan','Restaurant',4.8,'₹5,000 for two','Luxury fine dining'),(26,5,'Pinch of Spice','Restaurant',4.5,'₹800 for two','Moderate Mughlai'),(27,5,'Local Thali Joint','Restaurant',4.1,'₹350 per head','Budget unlimited thali'),(28,6,'The Lalit Grand Palace','Hotel',4.8,'₹15,000+','Luxury heritage palace'),(29,6,'Hotel Heevan','Hotel',4.4,'₹6,000 - ₹9,000','Moderate Dal Lake view'),(30,6,'Houseboat Group','Lodge',4.3,'₹2,000 - ₹4,000','Budget houseboat'),(31,6,'Ahdoos','Restaurant',4.5,'₹800 for two','Moderate Kashmiri Wazwan'),(32,6,'Mughal Darbar','Restaurant',4.2,'₹600 for two','Budget Kashmiri food'),(33,7,'Kumarakom Lake Resort','Hotel',4.9,'₹25,000+','Luxury backwater resort'),(34,7,'Punnamada Resort','Hotel',4.5,'₹8,000 - ₹12,000','Moderate backwater stay'),(35,7,'Zostel Alleppey','Lodge',4.2,'₹600 - ₹1,000','Budget hostel'),(36,7,'Thaff Restaurant','Restaurant',4.4,'₹800 for two','Famous Kerala seafood'),(37,8,'Tea County Resort','Hotel',4.7,'₹12,000+','Luxury tea garden view'),(38,8,'Munnar Inn','Hotel',4.3,'₹4,000 - ₹6,000','Moderate town stay'),(39,8,'Zostel Munnar','Lodge',4.2,'₹500 - ₹900','Budget hostel'),(40,8,'Saravana Bhavan','Restaurant',4.4,'₹400 for two','Budget South Indian'),(41,9,'Clarks Inn Hampi','Hotel',4.3,'₹5,000 - ₹8,000','Moderate modern stay'),(42,9,'Gopi Guest House','Lodge',4.4,'₹1,000 - ₹2,000','Budget riverside guesthouse'),(43,9,'Mango Tree','Restaurant',4.5,'₹600 for two','Famous budget multi-cuisine'),(44,10,'Radisson Blu Plaza','Hotel',4.7,'₹9,000+','Luxury 5-star'),(45,10,'Hotel Dasaprakash','Hotel',4.3,'₹3,000 - ₹5,000','Moderate heritage'),(46,10,'Zostel Mysore','Lodge',4.1,'₹500 - ₹900','Budget hostel'),(47,10,'Mylari','Restaurant',4.6,'₹200 for two','World famous budget dosa'),(48,11,'Taj Lake Palace','Hotel',4.9,'₹40,000+','Luxury floating palace'),(49,11,'Hotel Lakend','Hotel',4.4,'₹6,000 - ₹9,000','Moderate lake view'),(50,11,'Zostel Udaipur','Lodge',4.3,'₹500 - ₹1,000','Budget hostel'),(51,11,'Ambrai','Restaurant',4.6,'₹1,500 for two','Royal dining view'),(52,12,'Suryagarh','Hotel',4.9,'₹25,000+','Luxury desert fort'),(53,12,'Hotel Tokyo Palace','Hotel',4.4,'₹3,000 - ₹5,000','Moderate budget-friendly'),(54,12,'Gaji\'s','Restaurant',4.6,'₹800 for two','Famous rooftop views'),(55,13,'ITC Narmada','Hotel',4.8,'₹12,000+','Luxury 5-star'),(56,13,'Lemon Tree Premier','Hotel',4.4,'₹5,000 - ₹8,000','Moderate business hotel'),(57,13,'Agashiye','Restaurant',4.7,'₹1,200 for two','Famous Gujarati Thali'),(58,13,'Manek Chowk Street','Restaurant',4.5,'₹300 for two','Budget street food'),(59,14,'Tent City','Hotel',4.6,'₹8,000 - ₹15,000','Luxury tents during Rann Utsav'),(60,14,'Kutch Safari Lodge','Hotel',4.3,'₹4,000 - ₹6,000','Moderate eco-resort'),(61,14,'Local Dhabas','Restaurant',4.2,'₹200 for two','Budget Kutchi food'),(62,15,'Hyatt Amritsar','Hotel',4.7,'₹8,000+','Luxury 5-star'),(63,15,'Hotel City Park','Hotel',4.3,'₹3,000 - ₹5,000','Moderate near Golden Temple'),(64,15,'Kesar Da Dhaba','Restaurant',4.6,'₹400 for two','Famous budget Punjabi food'),(65,15,'Beera Chicken House','Restaurant',4.5,'₹600 for two','Famous local chicken'),(66,16,'BrijRama Palace','Hotel',4.9,'₹20,000+','Luxury heritage on Ghats'),(67,16,'Hotel Alka','Hotel',4.2,'₹2,500 - ₹4,000','Moderate river view'),(68,16,'Stops Hostel','Lodge',4.3,'₹500 - ₹900','Budget hostel'),(69,16,'Blue Lassi Shop','Sweet Shop',4.7,'₹100 - ₹200','World famous Lassi'),(70,17,'The Grand Dragon','Hotel',4.8,'₹12,000+','Luxury 5-star'),(71,17,'Hotel Ladakh Palace','Hotel',4.3,'₹4,000 - ₹6,000','Moderate traditional stay'),(72,17,'Zostel Leh','Lodge',4.4,'₹600 - ₹1,000','Budget backpacker'),(73,18,'Vivanta Shillong','Hotel',4.7,'₹9,000+','Luxury 5-star'),(74,18,'Hotel Polo Towers','Hotel',4.4,'₹4,000 - ₹6,000','Moderate city center'),(75,18,'Jiva Grill','Restaurant',4.3,'₹800 for two','Famous local food'),(76,19,'Mayfair Darjeeling','Hotel',4.8,'₹10,000+','Luxury colonial heritage'),(77,19,'Summit Swiss Heritage','Hotel',4.3,'₹5,000 - ₹7,000','Moderate mountain view'),(78,19,'Glenary\'s','Restaurant',4.6,'₹800 for two','Famous bakery & cafe'),(79,20,'Mayfair Waves','Hotel',4.7,'₹8,000+','Luxury beach resort'),(80,20,'Hotel Holiday Resort','Hotel',4.2,'₹3,000 - ₹5,000','Moderate near beach'),(81,20,'Anand Bazar Street Food','Restaurant',4.4,'₹200 for two','Budget local Mahaprasad'),(82,21,'Taj Rishikesh','Hotel',4.8,'₹18,000+','Luxury riverside resort'),(83,21,'Zostel Rishikesh','Lodge',4.3,'₹500 - ₹900','Budget riverside hostel'),(84,21,'Chotiwala','Restaurant',4.5,'₹400 for two','Famous iconic vegetarian thali'),(85,22,'ITC Grand Chola','Hotel',4.9,'₹15,000+','Luxury grand hotel'),(86,22,'The Residency Towers','Hotel',4.4,'₹6,000 - ₹9,000','Moderate city hotel'),(87,22,'Murugan Idli Shop','Restaurant',4.6,'₹300 for two','World famous budget idlis'),(88,23,'Heritage Madurai','Hotel',4.8,'₹8,000+','Luxury heritage resort'),(89,23,'Hotel Park Plaza','Hotel',4.2,'₹3,000 - ₹5,000','Moderate near temple'),(90,23,'Murugan Idli Shop','Restaurant',4.6,'₹300 for two','Famous budget food'),(91,24,'Palais de Mahe','Hotel',4.8,'₹12,000+','Luxury French colonial'),(92,24,'Villa Krish','Hotel',4.5,'₹5,000 - ₹8,000','Moderate heritage hotel'),(93,24,'Cafe des Arts','Restaurant',4.4,'₹800 for two','Famous French cafe');
/*!40000 ALTER TABLE `stay_and_food` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transport`
--

DROP TABLE IF EXISTS `transport`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transport` (
  `transport_id` int NOT NULL AUTO_INCREMENT,
  `transport_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `comfort_level` enum('Low','Medium','High') COLLATE utf8mb4_unicode_ci DEFAULT 'Medium',
  PRIMARY KEY (`transport_id`),
  UNIQUE KEY `transport_type` (`transport_type`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transport`
--

LOCK TABLES `transport` WRITE;
/*!40000 ALTER TABLE `transport` DISABLE KEYS */;
INSERT INTO `transport` VALUES (1,'Walking','Low'),(2,'Auto','Medium'),(3,'Bus','Low'),(4,'Metro','Medium'),(5,'Cab','High'),(6,'Train','Medium');
/*!40000 ALTER TABLE `transport` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trip`
--

DROP TABLE IF EXISTS `trip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trip` (
  `trip_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `destination_id` int NOT NULL,
  `start_location` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `travel_style` enum('Budget','Moderate','Luxury') COLLATE utf8mb4_unicode_ci NOT NULL,
  `trip_date` date DEFAULT NULL,
  `total_cost` decimal(12,2) DEFAULT '0.00',
  `total_time` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`trip_id`),
  KEY `user_id` (`user_id`),
  KEY `destination_id` (`destination_id`),
  CONSTRAINT `trip_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `trip_ibfk_2` FOREIGN KEY (`destination_id`) REFERENCES `destination` (`destination_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trip`
--

LOCK TABLES `trip` WRITE;
/*!40000 ALTER TABLE `trip` DISABLE KEYS */;
INSERT INTO `trip` VALUES (1,6,3,'pune','Luxury','2026-10-05',0.00,180,'2026-10-05 07:52:36'),(2,6,4,'pune','Budget','2026-10-05',100.00,180,'2026-10-05 11:01:15'),(3,6,3,'mumbai','Budget','2026-10-05',50.00,270,'2026-10-05 15:25:02'),(4,6,1,'pune','Moderate','2026-10-05',0.00,90,'2026-10-05 15:28:51'),(5,6,1,'pune','Moderate','2026-10-05',350.00,250,'2026-10-05 15:59:43'),(6,6,1,'pune','Moderate','2026-10-05',750.00,390,'2026-10-05 16:06:11'),(7,6,1,'pune','Moderate','2026-10-06',180.00,285,'2026-10-06 06:54:02'),(8,6,1,'pune','Moderate','2026-10-06',350.00,250,'2026-10-06 07:49:47');
/*!40000 ALTER TABLE `trip` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `preferred_mode` enum('Budget','Moderate','Luxury') COLLATE utf8mb4_unicode_ci DEFAULT 'Moderate',
  `role` enum('user','admin') COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'Admin','admin@tripwise.com','9999999999','PASTE_ADMIN_HASH_HERE','Luxury','admin','2026-10-04 14:58:17'),(2,'Anushka','anushka@example.com','9876543210','PASTE_USER_HASH_HERE','Budget','user','2026-10-04 14:58:17'),(5,'anjali koli','anjali.1251030423@vit.edu','07385179849','scrypt:32768:8:1$DvFdKLmUQipkyqs0$68bb4668dd2e563ba4bf74685ff0adeecf1729b20228ae87a5a626bbb9d6d8741453dd7e3905946fb360a77b10d47a719ee1d8aecc6eb43f700553e59e38f061','Moderate','user','2026-10-04 15:58:47'),(6,'anjali koli','anjalikoli445@gmail.com','07385179849','scrypt:32768:8:1$2GR7apr9TJyhWrEI$6bbba6ce010001a53b1afe8922876ff95701146965ef1cf0149841c997aa90a91f1bc3df67445e38da41b2cbf0600cab158e250d67bd9a4b0fb9a49a65b21a7f','Moderate','user','2026-10-05 07:51:52'),(7,'mahananda','mahananda123@gmail.com','7066398489','scrypt:32768:8:1$RnBHV2WMKuWl84VQ$dc36314ca01282fe06ec35b6b28e3a8dea328381d058a1e1395cc4512b651bd10d5039d67edbea6fa79535c1b49e1f4bd0758a5cf2fee281b308a9145e96e45b','Budget','user','2026-10-05 15:34:32');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_popular_places`
--

DROP TABLE IF EXISTS `vw_popular_places`;
/*!50001 DROP VIEW IF EXISTS `vw_popular_places`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_popular_places` AS SELECT 
 1 AS `place_id`,
 1 AS `place_name`,
 1 AS `destination_name`,
 1 AS `selection_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_user_trip_summary`
--

DROP TABLE IF EXISTS `vw_user_trip_summary`;
/*!50001 DROP VIEW IF EXISTS `vw_user_trip_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_user_trip_summary` AS SELECT 
 1 AS `trip_id`,
 1 AS `user_name`,
 1 AS `destination_name`,
 1 AS `travel_style`,
 1 AS `total_cost`,
 1 AS `total_time`,
 1 AS `trip_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_popular_places`
--

/*!50001 DROP VIEW IF EXISTS `vw_popular_places`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_popular_places` AS select `p`.`place_id` AS `place_id`,`p`.`place_name` AS `place_name`,`d`.`destination_name` AS `destination_name`,count(`sp`.`trip_id`) AS `selection_count` from ((`place` `p` join `destination` `d` on((`p`.`destination_id` = `d`.`destination_id`))) left join `selected_place` `sp` on((`p`.`place_id` = `sp`.`place_id`))) group by `p`.`place_id`,`p`.`place_name`,`d`.`destination_name` order by `selection_count` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_user_trip_summary`
--

/*!50001 DROP VIEW IF EXISTS `vw_user_trip_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_user_trip_summary` AS select `t`.`trip_id` AS `trip_id`,`u`.`name` AS `user_name`,`d`.`destination_name` AS `destination_name`,`t`.`travel_style` AS `travel_style`,`t`.`total_cost` AS `total_cost`,`t`.`total_time` AS `total_time`,`t`.`trip_date` AS `trip_date` from ((`trip` `t` join `user` `u` on((`t`.`user_id` = `u`.`user_id`))) join `destination` `d` on((`t`.`destination_id` = `d`.`destination_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-15 12:37:07
