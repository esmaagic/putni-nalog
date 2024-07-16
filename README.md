### Sistem vodjenja evidencije putnih naloga 

Sistem putnih naloga je dizajniran za upravljanje putovanjima zaposlenika unutar organizacije. Omogućava evidentiranje, praćenje i analizu putnih naloga, troškova, dnevnica i vremena provedenog na putu. Sistem se sastoji od više tabela koje međusobno komuniciraju kako bi pružile cjelovitu sliku o putnim aktivnostima zaposlenika.

## SQL-DDL folder
   
   Sadrzi sql komande za kreiranje svih potrebnih MySql tabela i procedura.
   
   Sadrzi slozenije procedure kao sto su:
   
   - boravak_putnika
      - Procedura vraća broj dana koje je putnik proveo u određenoj destinaciji. Ako ID putnog naloga ne postoji, procedura vraća grešku.
   - obracun_dnevnica_po_nalogu
      - Procedura izračunava dnevnice za svaku državu za određeni putni nalog.
   - putni_troskovi_po_valuti
      - Procedura izračunava ukupne putne troškove po valutama za određeni putni nalog.
   - troskovi_putnog_naloga
      - Procedura izračunava ukupne putne troškove u markama za određeni putni nalog.
   - ukupne_akontacije_po_valutama
      - Procedura vraća ukupne akontacije po valutama unutar određenog vremenskog perioda.
   - ukupno_naloga_zaposlenika_datum
      - Procedura vraća ukupan broj putnih naloga po zaposleniku unutar određenog vremenskog perioda.
   - ukupno_vrijeme_na_putu_zaposlenika
      - Procedura izračunava ukupno vrijeme provedeno na putu po zaposleniku unutar određenog vremenskog perioda.




   
##  api folder
   api - Node.js/express
   Sadrzi rute za interakciju sa bazom podataka
   
   
