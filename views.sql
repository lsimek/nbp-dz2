-- pogled u trenutno stanje polaznika
CREATE OR REPLACE VIEW stanje_polaznika AS
SELECT
	p.oib AS oib,
	p.ime AS ime,
	p.prezime AS prezime,
	COALESCE(v.sati_voznje, 0) AS sati_voznje,
	COALESCE(i.prolaz_teorija, FALSE) AS prolaz_teorija,
	COALESCE(i.prolaz_pp, FALSE) AS prolaz_prva_pomoc,
	COALESCE(i.izlazaka_voznja, 0) AS izlazaka_voznja
FROM
	polaznik AS p

	LEFT JOIN (
		SELECT
			polaznik_oib,
			SUM(trajanje_min / 60) AS sati_voznje
		FROM voznja
		GROUP BY polaznik_oib
	) AS v ON p.oib = v.polaznik_oib

	LEFT JOIN (
		SELECT
			polaznik_oib, 
			BOOL_OR(vrsta = 'teorija' AND prolaz) AS prolaz_teorija,
			BOOL_OR(vrsta = 'prva pomoć' AND prolaz) AS prolaz_pp,
			BOOL_OR(vrsta = 'vožnja' AND prolaz) AS prolaz_voznja,
			SUM(CASE WHEN vrsta = 'vožnja' THEN 1 ELSE 0 END) AS izlazaka_voznja,
			SUM(dodatni_sati) AS dodatni_sati
		FROM ispit
		GROUP BY polaznik_oib
	) AS i ON i.polaznik_oib = p.oib

	WHERE prolaz_voznja = FALSE
		OR prolaz_voznja IS NULL;

-- funkcija za poredak instruktora
CREATE OR REPLACE FUNCTION poredak_instruktora(v_godina INT)
RETURNS TABLE (
	oib instruktor.oib%type,
	ime instruktor.ime%type,
	prezime instruktor.prezime%type,
	ukupno_sati BIGINT,
	razlika_od_prosjeka DECIMAL(10, 2) 
) AS $$
DECLARE
	v_ukupni_prosjek DECIMAL(10, 2);
BEGIN
	 SELECT 
		AVG(_ukupno_sati) INTO v_ukupni_prosjek
	FROM (
		SELECT SUM(trajanje_min / 60) AS _ukupno_sati
		FROM voznja
		WHERE EXTRACT(YEAR FROM datum_i_vrijeme) = v_godina 
		GROUP BY instruktor_oib
	);
	
	RETURN QUERY
	SELECT
		i.oib AS oib,
		i.ime AS ime,
		i.prezime AS prezime,
		v.ukupno_sati AS ukupno_sati,
		v.ukupno_sati - v_ukupni_prosjek AS razlika_od_prosjeka
	FROM
		instruktor AS i
		LEFT JOIN (
			SELECT
				instruktor_oib, 
				SUM(trajanje_min / 60) AS ukupno_sati
			FROM voznja
			WHERE EXTRACT(YEAR FROM datum_i_vrijeme) = v_godina
			GROUP BY instruktor_oib
		) AS v ON i.oib = v.instruktor_oib
	ORDER BY v.ukupno_sati DESC;
END;
$$LANGUAGE plpgsql;


