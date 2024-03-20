

CREATE TABLE `datum_cjenovnika` (
  `datum_cjenovnika_id` int NOT NULL AUTO_INCREMENT,
  `datum_pocetka_vazenja` date NOT NULL,
  `opis` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bs_0900_ai_ci DEFAULT NULL,
  `napomena` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bs_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`datum_cjenovnika_id`),
  UNIQUE KEY `datum_pocetka_vazenja` (`datum_pocetka_vazenja`)
) 

  
CREATE TABLE `kursna_lista` (
  `kursna_lista_id` int NOT NULL AUTO_INCREMENT,
  `datum_kursne_liste` date NOT NULL,
  `godina` int NOT NULL,
  PRIMARY KEY (`kursna_lista_id`)
)



CREATE TABLE `pravac_putovanja` (
  `id` int NOT NULL AUTO_INCREMENT,
  `naziv` varchar(50) COLLATE utf8mb4_bs_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) 


CREATE TABLE `smjer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `naziv` varchar(50) COLLATE utf8mb4_bs_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
)



CREATE TABLE `valuta` (
  `valuta_id` int NOT NULL AUTO_INCREMENT,
  `naziv_valute` varchar(50) COLLATE utf8mb4_bs_0900_ai_ci NOT NULL,
  PRIMARY KEY (`valuta_id`)
)

  
CREATE TABLE `vrste_troskova` (
  `vrste_troskova_id` int NOT NULL AUTO_INCREMENT,
  `naziv` varchar(100) COLLATE utf8mb4_bs_0900_ai_ci NOT NULL,
  PRIMARY KEY (`vrste_troskova_id`)
) 


CREATE TABLE `zaposlenik` (
  `zaposlenik_id` int NOT NULL AUTO_INCREMENT,
  `ime` varchar(50) COLLATE utf8mb4_bs_0900_ai_ci NOT NULL,
  `prezime` varchar(50) COLLATE utf8mb4_bs_0900_ai_ci NOT NULL,
  `jmbg` varchar(13) COLLATE utf8mb4_bs_0900_ai_ci NOT NULL,
  PRIMARY KEY (`zaposlenik_id`),
  UNIQUE KEY `jmbg` (`jmbg`)
) 
  

CREATE TABLE `drzava` (
  `id` int NOT NULL AUTO_INCREMENT,
  `naziv_drzave` varchar(50) COLLATE utf8mb4_bs_0900_ai_ci NOT NULL,
  `valuta` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_valuta` (`valuta`),
  CONSTRAINT `fk_valuta` FOREIGN KEY (`valuta`) REFERENCES `valuta` (`valuta_id`)
) 



CREATE TABLE `kurs_valute` (
  `kursna_lista_id` int NOT NULL AUTO_INCREMENT,
  `oznaka_valute` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_bs_0900_ai_ci NOT NULL,
  `kod_valute` int NOT NULL,
  `jedinica` int NOT NULL,
  `kupovni_kurs` decimal(15,6) DEFAULT NULL,
  `srednji_kurs` decimal(15,6) DEFAULT NULL,
  `prodajni_kurs` decimal(15,6) DEFAULT NULL,
  PRIMARY KEY (`kursna_lista_id`,`oznaka_valute`),
  CONSTRAINT `kurs_valute_FK` FOREIGN KEY (`kursna_lista_id`) REFERENCES `kursna_lista` (`kursna_lista_id`)
) 


CREATE TABLE `registar_putnih_naloga` (
  `br_putnog_naloga` int NOT NULL AUTO_INCREMENT,
  `datum_putnog_naloga` date NOT NULL,
  `relacija_opisno` varchar(250) COLLATE utf8mb4_bs_0900_ai_ci NOT NULL,
  `nacin_putovanja` varchar(50) COLLATE utf8mb4_bs_0900_ai_ci DEFAULT NULL,
  `svrha_putovanja` varchar(50) COLLATE utf8mb4_bs_0900_ai_ci DEFAULT NULL,
  `datum_i_vrijeme_pocetka_putovanja` datetime DEFAULT NULL,
  `datum_i_vrijeme_kraja_putovanja` datetime DEFAULT NULL,
  `zaposlenik_id` int NOT NULL,
  `mjesto_boravka` int DEFAULT NULL,
  PRIMARY KEY (`br_putnog_naloga`),
  KEY `mjesto_boravka` (`mjesto_boravka`),
  KEY `registar_putnih_naloga_FK` (`zaposlenik_id`),
  CONSTRAINT `registar_putnih_naloga_FK` FOREIGN KEY (`zaposlenik_id`) REFERENCES `zaposlenik` (`zaposlenik_id`),
  CONSTRAINT `registar_putnih_naloga_ibfk_1` FOREIGN KEY (`mjesto_boravka`) REFERENCES `drzava` (`id`)
) 



CREATE TABLE `vrijeme_putovanja` (
  `redni_broj` int NOT NULL,
  `br_putnog_naloga` int NOT NULL,
  `pravac` int NOT NULL,
  `granicni_prelaz` int NOT NULL,
  `vrijeme_gr_prelaz` datetime DEFAULT NULL,
  PRIMARY KEY (`br_putnog_naloga`,`redni_broj`),
  KEY `pravac` (`pravac`),
  KEY `granicni_prelaz` (`granicni_prelaz`),
  CONSTRAINT `vrijeme_putovanja_ibfk_1` FOREIGN KEY (`pravac`) REFERENCES `pravac_putovanja` (`id`),
  CONSTRAINT `vrijeme_putovanja_ibfk_2` FOREIGN KEY (`granicni_prelaz`) REFERENCES `drzava` (`id`)
) 



CREATE TABLE `akontacija` (
  `akontacija_id` int NOT NULL AUTO_INCREMENT,
  `br_putnog_naloga` int NOT NULL,
  `valuta` int NOT NULL,
  `iznos` decimal(10,2) NOT NULL,
  PRIMARY KEY (`akontacija_id`),
  KEY `fk_br_putnog_naloga_ref_rpn` (`br_putnog_naloga`),
  KEY `fk_valuta_ref_valuta` (`valuta`),
  CONSTRAINT `fk_br_putnog_naloga_ref_rpn` FOREIGN KEY (`br_putnog_naloga`) REFERENCES `registar_putnih_naloga` (`br_putnog_naloga`),
  CONSTRAINT `fk_valuta_ref_valuta` FOREIGN KEY (`valuta`) REFERENCES `valuta` (`valuta_id`)
) 



CREATE TABLE `cjenovnik_dnevnice` (
  `datum_vazenja` int NOT NULL,
  `zemlja` int NOT NULL,
  `opis` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bs_0900_ai_ci DEFAULT NULL,
  `iznos_dnevnice_km` double(10,2) NOT NULL,
  PRIMARY KEY (`datum_vazenja`,`zemlja`),
  KEY `fk_zemlja_ref_drzava` (`zemlja`),
  CONSTRAINT `cjenovnik_dnevnice_ibfk_1` FOREIGN KEY (`datum_vazenja`) REFERENCES `datum_cjenovnika` (`datum_cjenovnika_id`),
  CONSTRAINT `fk_zemlja_ref_drzava` FOREIGN KEY (`zemlja`) REFERENCES `drzava` (`id`)
) 



CREATE TABLE `putni_troskovi` (
  `putni_troskovi_id` int NOT NULL AUTO_INCREMENT,
  `br_putnog_naloga` int NOT NULL,
  `vrsta_troska` int NOT NULL,
  `iznos` decimal(10,2) NOT NULL,
  `valuta` int NOT NULL,
  `iznos_oporezivo` decimal(10,2) DEFAULT NULL,
  `iznos_neoporezivo` decimal(10,2) DEFAULT NULL,
  `pdv` int DEFAULT NULL,
  `datum_troska` date DEFAULT NULL,
  PRIMARY KEY (`putni_troskovi_id`),
  KEY `br_putnog_naloga` (`br_putnog_naloga`),
  KEY `putni_troskovi_ibfk_2` (`vrsta_troska`),
  KEY `putni_troskovi_ibfk_3` (`valuta`),
  CONSTRAINT `putni_troskovi_ibfk_1` FOREIGN KEY (`br_putnog_naloga`) REFERENCES `registar_putnih_naloga` (`br_putnog_naloga`),
  CONSTRAINT `putni_troskovi_ibfk_2` FOREIGN KEY (`vrsta_troska`) REFERENCES `vrste_troskova` (`vrste_troskova_id`),
  CONSTRAINT `putni_troskovi_ibfk_3` FOREIGN KEY (`valuta`) REFERENCES `valuta` (`valuta_id`)
) 
