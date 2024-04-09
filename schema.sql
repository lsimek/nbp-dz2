-- stvaranje baze i shema
DROP DATABASE autoskola;
CREATE DATABASE autoskola;
\c autoskola;

-- tablica `instruktor` sadrzi podatke o instruktoru
-- `sifra_auto` je neka identifikacijka oznaka instruktorovog auta (ovdje INT, moze biti i registracijska oznaka)
-- instruktor i auto su u 1:1 odnosu pa bismo i druge podatke o autu naveli u ovoj tablici
CREATE TABLE IF NOT EXISTS instruktor (
	oib CHAR(11) PRIMARY KEY,
	ime VARCHAR(20) NOT NULL,
	prezime VARCHAR(20) NOT NULL,
	sifra_auto INT UNIQUE NOT NULL
);

-- tablica `polaznik` evidentira i podatke o placanju 
-- u ovoj implementaciji ukupni placeni iznos uvijek mora pokrivati 1/3 ukupne skolarine, uklj. kad se polaznik upisuje u tablicu
CREATE TABLE IF NOT EXISTS polaznik (
	oib CHAR(11) PRIMARY KEY,
	ime VARCHAR(20) NOT NULL,
	prezime VARCHAR(20) NOT NULL,
	ukupna_skolarina DECIMAL(10, 2),
	ukupno_placeno DECIMAL(10, 2),

	CHECK (ukupna_skolarina >= 0),
	CHECK (ukupno_placeno >= ukupna_skolarina / 3),
	CHECK (ukupno_placeno <= ukupna_skolarina)
);

-- tablica `ispit`
-- izmedju ostalog, u slucaju pada na ispitu iz voznje, odredjuju se dodatni sati potrebni prije sljedeceg izlaska
CREATE TABLE IF NOT EXISTS ispit (
	id SERIAL PRIMARY KEY,
	polaznik_oib CHAR(11) REFERENCES polaznik(oib),
	datum_i_vrijeme TIMESTAMP NOT NULL,
	vrsta VARCHAR(10) NOT NULL,
	prolaz BOOLEAN NOT NULL,
	dodatni_sati INT,
	
	CHECK (datum_i_vrijeme > '2024-01-01'),
	CHECK (vrsta IN ('vožnja', 'teorija', 'prva pomoć')),
	CHECK (dodatni_sati IS NULL or dodatni_sati >= 0)
);

-- tablica `voznja` evidentira sve voznje
-- trajanje voznje ne mora biti cijeli broj sati, zato se ovdje za lakse koristenje evidentira u minutama
CREATE TABLE IF NOT EXISTS voznja (
	id SERIAL PRIMARY KEY,
	polaznik_oib CHAR(11) REFERENCES polaznik(oib),
	instruktor_oib CHAR(11) REFERENCES instruktor(oib),
	datum_i_vrijeme TIMESTAMP NOT NULL,
	trajanje_min INT,

	CHECK (datum_i_vrijeme > '2024-01-01'),
	CHECK (trajanje_min > 0)
);


