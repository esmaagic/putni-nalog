CREATE  PROCEDURE `boravak_putnika`(in id int)
BEGIN
	declare brojac int;

	SELECT COUNT(*) INTO brojac 
    FROM registar_putnih_naloga 
    WHERE br_putnog_naloga = id;
    
    -- If the provided ID doesn't exist, handle the error
   	
    IF brojac = 0 and id is not null THEN
        -- Respond with an appropriate error message or action
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Putni nalog sa datim id-om nije pronadjen.';
        
    END IF;

	
	
	
	SELECT vp.br_putnog_naloga,z.zaposlenik_id,z.ime,z.prezime ,d.id as id_drzave,d.naziv_drzave,
		DATEDIFF(vp2.vrijeme_gr_prelaz, vp.vrijeme_gr_prelaz) AS vrijeme_boravka_dani
	FROM vrijeme_putovanja vp 
	LEFT JOIN registar_putnih_naloga rpn ON rpn.br_putnog_naloga = vp.br_putnog_naloga 
	LEFT JOIN 
		vrijeme_putovanja vp2 ON
		vp.pravac <> vp2.pravac AND vp.granicni_prelaz = vp2.granicni_prelaz and vp.br_putnog_naloga = vp2.br_putnog_naloga 
	left join zaposlenik z on z.zaposlenik_id = rpn.zaposlenik_id
	left join drzava d on d.id = rpn.mjesto_boravka 
	WHERE ((id is null) or (id is not null and rpn.br_putnog_naloga = id))AND 
	vp.pravac = 1 AND vp.granicni_prelaz = rpn.mjesto_boravka ;
END;

CREATE PROCEDURE `najposjecenije_drzave`()
begin
 SELECT d.naziv_drzave  ,count(redni_broj) posjecenost from vrijeme_putovanja vp 
 left join drzava d on d.id = vp.granicni_prelaz 
 group by granicni_prelaz 
order by posjecenost desc;
end;


CREATE  PROCEDURE `obracun_dnevnica_po_nalogu`(in putni_nalog int)
begin
	declare datum_pocetak datetime;
	declare datum_kraj datetime;
	declare vrijeme_prvo int;
	declare max_redni_br int;
	declare datum_cjenovnik_id int;


	SELECT COUNT(*) INTO max_redni_br 
    FROM vrijeme_putovanja vp 
    WHERE vp.br_putnog_naloga = putni_nalog;
    
    -- If the provided ID doesn't exist, handle the error
    IF max_redni_br = 0 THEN
        -- Respond with an appropriate error message or action
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Putni nalog sa datim id-om nije pronadjen.';
        
    END IF;



	
	SELECT datum_i_vrijeme_pocetka_putovanja into datum_pocetak  
		from registar_putnih_naloga  
			where br_putnog_naloga = putni_nalog;
	SELECT datum_i_vrijeme_kraja_putovanja into datum_kraj 
		from registar_putnih_naloga rpn 
			where rpn.br_putnog_naloga = putni_nalog ;
	select TIMESTAMPDIFF(HOUR,datum_pocetak,vrijeme_gr_prelaz  ) into vrijeme_prvo
		from vrijeme_putovanja vp 
			where br_putnog_naloga = putni_nalog and redni_broj = 1;
	
	SELECT  datum_cjenovnika_id into datum_cjenovnik_id from datum_cjenovnika dc 
		ORDER BY ABS(DATEDIFF(datum_pocetka_vazenja, '2023-02-17 12:00:00'))
			LIMIT 1;
	
		
	drop table if exists temp;
	create temporary table temp(
	drzava_id int,
	pravac int,
	vrijeme int
	);
	
	
	 insert into temp values(12,1, vrijeme_prvo );
	
	 insert into temp ()	
	select
	CASE 
		when pravac = 2 and redni_broj < max_redni_br THEN (
						SELECT granicni_prelaz from vrijeme_putovanja vp2 
								where br_putnog_naloga = putni_nalog and vp2.redni_broj = vp.redni_broj + 1)
		when pravac = 2 and redni_broj = max_redni_br THEN 12
		else vp.granicni_prelaz
	END
		as drzava_id,
		
		pravac, 
	CASE 
		when redni_broj = max_redni_br then
			TIMESTAMPDIFF(HOUR,  vrijeme_gr_prelaz,  datum_kraj)
		ELSE
			TIMESTAMPDIFF(HOUR,  vrijeme_gr_prelaz,
			(select vp2.vrijeme_gr_prelaz from vrijeme_putovanja vp2 where vp2.redni_broj = vp.redni_broj +1 and br_putnog_naloga =putni_nalog ))
	END as vrijeme
	from vrijeme_putovanja vp
	left join drzava d on d.id = vp.granicni_prelaz 
		where br_putnog_naloga = putni_nalog;
	
	 SELECT 
	 (select rpn.br_putnog_naloga from registar_putnih_naloga rpn where rpn.br_putnog_naloga=putni_nalog) as putni_nalog ,
    drzava_id,
    SUM(vrijeme) AS ukupno_vrijeme_sati,
    (floor(SUM(vrijeme / 24)) + 
        CASE 
            WHEN sum(vrijeme) % 24 >= 12 THEN 1 
            WHEN sum(vrijeme) % 24 >= 8 AND sum(vrijeme) % 24 < 12 THEN 0.5 
            ELSE 0 
        END ) as dnevnice,
            (select iznos_dnevnice_km from cjenovnik_dnevnice cd 
        where cd.datum_vazenja = datum_cjenovnik_id and cd.zemlja = drzava_id) as dnevnica_km ,
    (floor(SUM(vrijeme / 24)) + 
        CASE 
            WHEN sum(vrijeme) % 24 >= 12 THEN 1 
            WHEN sum(vrijeme) % 24 >= 8 AND sum(vrijeme) % 24 < 12 THEN 0.5 
            ELSE 0 
        END ) *
        (select iznos_dnevnice_km from cjenovnik_dnevnice cd 
        where datum_vazenja = datum_cjenovnik_id and zemlja = drzava_id) as ukupna_cijena_km
FROM temp
GROUP BY drzava_id;

end;

CREATE  PROCEDURE `putni_troskovi_po_valuti`(in id int)
begin
	declare brojac int;

	SELECT COUNT(*) INTO brojac 
    FROM registar_putnih_naloga 
    WHERE br_putnog_naloga = id;
    
	IF brojac = 0 and id is not null THEN
        -- Respond with an appropriate error message or action
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Putni nalog sa datim id-om nije pronadjen.';
    END IF;
   
	select br_putnog_naloga,sum(iznos) as iznos, v.naziv_valute  from putni_troskovi pt 
	left join valuta v on v.valuta_id = pt.valuta 
	where (id is null) or (id is not null and pt.br_putnog_naloga = id)
	group by br_putnog_naloga, valuta;
end;

CREATE PROCEDURE `svi_putni_nalozi_po_datumu`(in od_datuma date, in do_datuma date)
begin	
	SELECT 
	rpn.br_putnog_naloga,
	rpn.zaposlenik_id,
	z.ime ,z.prezime  , 
	rpn.datum_putnog_naloga,
	rpn.datum_i_vrijeme_pocetka_putovanja ,
	rpn.datum_i_vrijeme_kraja_putovanja,
	d.naziv_drzave as mjesto_boravka
from registar_putnih_naloga rpn 
left join zaposlenik z on z.zaposlenik_id = rpn.zaposlenik_id 
left join drzava d on d.id = rpn.mjesto_boravka 
WHERE (datum_i_vrijeme_pocetka_putovanja  BETWEEN od_datuma AND do_datuma)
    AND (datum_i_vrijeme_kraja_putovanja  BETWEEN od_datuma AND do_datuma);
end;

CREATE PROCEDURE `troskovi_putnog_naloga`(in id int)
BEGIN
	SELECT 
			pt.br_putnog_naloga ,z.zaposlenik_id, z.ime , z.prezime ,
			sum(
				pt.iznos * ifnull(
					(SELECT  kupovni_kurs  from kurs_valute kv 
						left join kursna_lista kl on kv.kursna_lista_id = kl.kursna_lista_id 
						where kl.datum_kursne_liste = pt.datum_troska AND 
						kv.oznaka_valute = (SELECT distinct v.naziv_valute  from putni_troskovi pt2
												left join valuta v on v.valuta_id = pt2.valuta 
												where pt2.valuta = pt.valuta)
						),1)
				) as suma
			from putni_troskovi pt 
			left join registar_putnih_naloga rpn on rpn.br_putnog_naloga = pt.br_putnog_naloga 
			left join zaposlenik z on z.zaposlenik_id = rpn.zaposlenik_id 
			where (id is null) or (id is not null and pt.br_putnog_naloga = id) 
			group by pt.br_putnog_naloga;
END;



CREATE PROCEDURE `ukupne_akontacije_po_valutama`(in od_datuma date, in do_datuma date)
begin
select sum(a.iznos) as iznos , a.valuta from akontacija a 
left join registar_putnih_naloga rpn on rpn.br_putnog_naloga = a.br_putnog_naloga 
WHERE (rpn.datum_i_vrijeme_pocetka_putovanja  BETWEEN od_datuma AND do_datuma)
    AND (rpn.datum_i_vrijeme_kraja_putovanja  BETWEEN od_datuma AND do_datuma)
group by a.valuta;
end;

CREATE  PROCEDURE `ukupno_naloga_zaposlenika_datum`(in od_datuma date, in do_datuma date)
begin	
	select rpn.zaposlenik_id ,z.ime,z.prezime , count(rpn.zaposlenik_id) as ukupno_naloga 
	from registar_putnih_naloga rpn
	left join zaposlenik z on z.zaposlenik_id = rpn.zaposlenik_id 
	WHERE (datum_i_vrijeme_pocetka_putovanja  BETWEEN od_datuma AND do_datuma)
    AND (datum_i_vrijeme_kraja_putovanja  BETWEEN od_datuma AND do_datuma)
   group by rpn.zaposlenik_id;
end;

CREATE  PROCEDURE `ukupno_vrijeme_na_putu_zaposlenika`(in od_datuma date, in do_datuma date)
begin
SELECT zaposlenik_id ,
sum(datediff(datum_i_vrijeme_kraja_putovanja, datum_i_vrijeme_pocetka_putovanja) ) 
as vrijeme_na_putu 
from registar_putnih_naloga rpn 
WHERE (datum_i_vrijeme_pocetka_putovanja  BETWEEN od_datuma AND do_datuma)
    AND (datum_i_vrijeme_kraja_putovanja  BETWEEN od_datuma AND do_datuma)
group by zaposlenik_id ;
end;


CREATE  PROCEDURE `unos_cjenovnika_dnevnica`(IN json_data JSON)
BEGIN
    DECLARE datum date;
    DECLARE podaci JSON;
    DECLARE array_length INT;
   	declare drzava JSON;
	declare cjenovnik_opis varchar(255);
	declare cjenovnik_napomena varchar(255);
	declare dnevnica_opis  varchar(255);
   	declare drzava_id int;
   	declare iznos int;
    DECLARE i INT DEFAULT 0;
    DECLARE datum_postoji int default 0;
   	declare id_datuma int;
   
   start transaction;

    SET datum = JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.datum'));
    SET podaci = JSON_EXTRACT(json_data, '$.podaci');
    SET array_length = JSON_LENGTH(podaci);
   
   	set cjenovnik_opis = JSON_EXTRACT(json_data, '$.cjenovnik_opis');
    set cjenovnik_napomena = JSON_EXTRACT(json_data, '$.cjenovnik_napomena');
   
   -- check datum and find id
   
   	select count(*) into datum_postoji from datum_cjenovnika dc where dc.datum_pocetka_vazenja=datum;
   
  	if datum_postoji=1 then
  		select datum_cjenovnika_id into id_datuma from datum_cjenovnika dc where datum_pocetka_vazenja = datum;
  	else 
  		SET @sql = CONCAT("INSERT INTO datum_cjenovnika (datum_pocetka_vazenja, opis, napomena) VALUES ('",
  			datum,"',", cjenovnik_opis, ",",cjenovnik_napomena ,");");
    	PREPARE izjava FROM @sql;
    	EXECUTE izjava;
    	DEALLOCATE PREPARE izjava;
    	SELECT LAST_INSERT_ID() INTO id_datuma;
    end if;
  		
   

    -- Loop through the array elements
    WHILE i < array_length DO
       
       	set drzava = JSON_EXTRACT(podaci, CONCAT('$[', i, '].drzava'));
       	select d.id into drzava_id from drzava d where d.naziv_drzave = drzava ;
       
       	
        set dnevnica_opis = JSON_EXTRACT(podaci, CONCAT('$[', i, '].dnevnica_opis'));

       	
       	set iznos = JSON_EXTRACT(podaci, CONCAT('$[', i, '].iznos'));
       
       	set iznos = cast(JSON_UNQUOTE(JSON_EXTRACT(podaci, CONCAT('$[', i, '].iznos')))  as SIGNED);
       -- unos podataka
       	SET @sql2 = CONCAT("INSERT INTO cjenovnik_dnevnice (datum_vazenja, zemlja, iznos_dnevnice_km,opis) VALUES (",
       						id_datuma, ",", drzava_id, ",", iznos, ",", dnevnica_opis, ");");
	    PREPARE izjava2 FROM @sql2;
	    EXECUTE izjava2;
   		DEALLOCATE PREPARE izjava2;
        SET i = i + 1;
    END WHILE;
   commit;
END;
