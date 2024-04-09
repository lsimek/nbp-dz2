-- preostala pravila integriteta ostvarit cemo pomocu rutina i okidaca

-- prije ispita iz voznje, mora se poloziti teoriju i prvu pomoc
CREATE OR REPLACE FUNCTION provjera_tpp() RETURNS TRIGGER AS $$
BEGIN
	IF NEW.vrsta = 'vožnja'
	AND (
		NOT EXISTS (
			SELECT 1 FROM ispit
			WHERE ispit.polaznik_oib = NEW.polaznik_oib
				AND ispit.prolaz = TRUE
				AND ispit.vrsta = 'teorija'
		)
		OR NOT EXISTS (
			SELECT 1 FROM ispit
			WHERE ispit.polaznik_oib = NEW.polaznik_oib
				AND ispit.prolaz = TRUE
				AND ispit.vrsta = 'prva pomoć'
		)
	)
	THEN 
		RAISE EXCEPTION 'Prije polaganja ispita iz vožnje, potrebno je položiti teoriju i prvu pomoć.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER okidac_provjera_tpp BEFORE INSERT ON ispit
FOR EACH ROW EXECUTE FUNCTION provjera_tpp();


-- prije ispita iz voznje, potreban je odredjen broj sati voznje  (35 ili neki drugi propisan nakon pada)
-- taj ukupni broj sati trazimo u vremenskom rasponu od zadnjeg pada ako pad postoji

-- pomocna funkcija vraca datum zadnjeg pada i broj potrebnih sati
CREATE OR REPLACE FUNCTION zadnji_pad(v_polaznik_oib polaznik.oib%type)
RETURNS TABLE (
	v_datum ispit.datum_i_vrijeme%type,
	V_broj_sati ispit.dodatni_sati%type
) AS $$
BEGIN
	RETURN QUERY
	SELECT 
		datum_i_vrijeme,
		dodatni_sati
	FROM ispit
	WHERE
		polaznik_oib = v_polaznik_oib
		AND vrsta = 'vožnja'
		AND prolaz = FALSE
	ORDER BY datum_i_vrijeme DESC
	LIMIT 1;
END;
$$LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION provjera_sati_voznje() RETURNS TRIGGER AS $$
DECLARE
	broj_sati ispit.dodatni_sati%type;
	datum ispit.datum_i_vrijeme%type;
BEGIN
	IF NEW.vrsta = 'vožnja'
	THEN
		SELECT v_datum, v_broj_sati INTO datum, broj_sati
		FROM zadnji_pad(NEW.polaznik_oib);

		IF datum IS NULL
		THEN
			datum := '1999-12-31';
			broj_sati := 35;
		END IF;

		IF (
			SELECT SUM(trajanje_min / 60)
			FROM voznja
			WHERE
				polaznik_oib = NEW.polaznik_oib
				AND datum_i_vrijeme > datum
		) < broj_sati

		THEN
			RAISE EXCEPTION 'Nije evidentiran potreban broj sati vožnje (%) potreban prije polaganja.', broj_sati;
		END IF;
	END IF;
	RETURN NEW;
END;
$$LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER okidac_provjera_sati_voznje
BEFORE INSERT ON ispit
FOR EACH ROW EXECUTE FUNCTION provjera_sati_voznje();


