-- podaci za testiranje 

INSERT INTO instruktor(oib, ime, prezime, sifra_auto) VALUES
	('12345678901', 'Ivan', 'Horvat', 123),
	('23456789012', 'Petra', 'Kovač', 456),
	('34567890123', 'Luka', 'Novak', 789),
	('45678901234', 'Mia', 'Bosak', 101),
	('56789012345', 'Marko', 'Matić', 112);

INSERT INTO polaznik(oib, ime, prezime, ukupna_skolarina, ukupno_placeno) VALUES
	('11111111111', 'David', 'Kovačić', 3000.00, 1500.00),
	('22222222222', 'Ana', 'Babić', 2500.00, 900.50),
	('33333333333', 'Filip', 'Jurić', 4000.00, 1333.34),
	('44444444444', 'Sara', 'Šarić', 3000.00, 1000.00),
	('55555555555', 'Tomislav', 'Radić', 2000.00, 666.67),
	('66666666666', 'Lana', 'Galić', 3000.00, 1000.00),
	('77777777777', 'Ema', 'Bosnić', 2500.00, 1000.00),
	('88888888888', 'Luka', 'Petrović', 4000.00, 1900.00),
	('99999999999', 'Petra', 'Perić', 3500.00, 1166.67),
	('00000000000', 'Mateo', 'Marković', 2000.00, 666.67),
	('11122233344', 'Nika', 'Jurišić', 3200.00, 1066.67),
	('22233344455', 'Leon', 'Babić', 2700.00, 900.00),
	('33344455566', 'Mia', 'Matijević', 3800.00, 1266.67),
	('44455566677', 'Jakov', 'Horvat', 3300.00, 1100.00),
	('55566677788', 'Iva', 'Ivić', 2800.00, 1200.50),
	('66677788899', 'Dino', 'Kovačević', 3900.00, 1300.00),
	('77788899900', 'Marta', 'Šimić', 3400.00, 3400.00),
	('88899900011', 'Ivan', 'Tomić', 2900.00, 966.67),
	('99900011122', 'Lucija', 'Grgić', 3100.00, 1133.33),
	('00011122233', 'Matija', 'Blažević', 2600.00, 866.67);

-- pogreska u visini prve rate skolarine
INSERT INTO polaznik(oib, ime, prezime, ukupna_skolarina, ukupno_placeno) VALUES
	('11221122112', 'Grgur', 'Ninski', 3000.00, 700.00);

-- razliciti rasporedi voznji
INSERT INTO voznja(polaznik_oib, instruktor_oib, datum_i_vrijeme, trajanje_min) VALUES
	('11111111111', '12345678901', '2024-02-02', 35 * 60),

	('22222222222', '23456789012', '2024-02-03', 20 * 60),
	('22222222222', '34567890123', '2024-02-10', 20 * 60),

	('33333333333', '45678901234', '2024-03-01', 10 * 60),
	('33333333333', '45678901234', '2024-03-02', 10 * 60),

	('44444444444', '56789012345', '2024-03-10', 35 * 60),
	('44444444444', '56789012345', '2024-03-12', 35 * 60),
	('44444444444', '56789012345', '2024-04-02', 5 * 60),
	('44444444444', '56789012345', '2024-05-02', 5 * 60),

	('55555555555', '12345678901', '2025-01-02', 10 * 60),
	('55555555555', '12345678901', '2025-01-03', 20 * 60),
	('55555555555', '12345678901', '2025-01-04', 5 * 60);

-- nekoliko uspjesnih ispita iz teorije, prve pomoci i neuspjesnih iz voznje
INSERT INTO ispit(polaznik_oib, datum_i_vrijeme, vrsta, prolaz, dodatni_sati) VALUES
	('11111111111', '2024-01-02', 'teorija', TRUE, NULL),
	('11111111111', '2024-01-03', 'prva pomoć', FALSE, NULL),
	('11111111111', '2024-01-04', 'prva pomoć', TRUE, NULL),

	('22222222222', '2024-02-04', 'teorija', TRUE, NULL),

	('33333333333', '2024-03-03', 'teorija', TRUE, NULL),
	('33333333333', '2024-03-04', 'prva pomoć', TRUE, NULL),

	('44444444444', '2024-03-13', 'teorija', TRUE, NULL),
	('44444444444', '2024-03-14', 'prva pomoć', TRUE, NULL),
	('44444444444', '2024-03-15', 'vožnja', FALSE, 5),
	('44444444444', '2024-04-03', 'vožnja', FALSE, 10),
	
	('55555555555', '2024-12-01', 'teorija', TRUE, NULL),
	('55555555555', '2024-12-12', 'prva pomoć', FALSE, NULL);

-- moze li se evidentirati polozen ispit iz voznje
-- ok
INSERT INTO ispit(polaznik_oib, datum_i_vrijeme, vrsta, prolaz, dodatni_sati) VALUES
	('11111111111', '2024-02-05', 'vožnja', TRUE, NULL);

-- nije pristupljeno ispitu iz prve pomoci
INSERT INTO ispit(polaznik_oib, datum_i_vrijeme, vrsta, prolaz, dodatni_sati) VALUES
	('22222222222', '2024-02-11', 'vožnja', TRUE, NULL);

-- manje od 35 sati
INSERT INTO ispit(polaznik_oib, datum_i_vrijeme, vrsta, prolaz, dodatni_sati) VALUES
	('33333333333', '2024-03-06', 'vožnja', TRUE, NULL);

-- manji broj dodatnih sati od propisanih 
INSERT INTO ispit(polaznik_oib, datum_i_vrijeme, vrsta, prolaz, dodatni_sati) VALUES
	('44444444444', '2024-05-03', 'vožnja', TRUE, NULL);

-- polaznik je pristupio ispitu iz prve pomoci ali nije prosao
INSERT INTO ispit(polaznik_oib, datum_i_vrijeme, vrsta, prolaz, dodatni_sati) VALUES
	('55555555555', '2025-01-05', 'vožnja', TRUE, NULL);

-- pogled u trenutno stanje polaznika
SELECT * FROM stanje_polaznika;

-- poredak instruktora
SELECT * FROM poredak_instruktora(2024);


