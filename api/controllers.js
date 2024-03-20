const pool = require('./database')

//post controllers
exports.unosPutniTrosak = async (req,res) =>{
    const {brPutnogNaloga, vrstaTroska, iznos, valuta, iznosOporezivo,
                                  iznosNeoporezivo, pdv, datumTroska} = req.body

    try{

        const [result] = await pool.query(`insert into putni_troskovi (br_putnog_naloga, vrsta_troska, iznos, valuta, iznos_oporezivo, iznos_neoporezivo, pdv,datum_troska)
        values (?,?,?,?,?,?,?,?)`, [brPutnogNaloga, vrstaTroska, iznos, valuta, iznosOporezivo,
            iznosNeoporezivo, pdv, datumTroska])   
        res.status(201).json({mssg:"unos uspjesan!", result})    
    }catch (error){
        console.log(error)
        res.status(500).send("Internal Server Error");
    }
}

exports.unosPutniNalog = async(req,res) =>{

    const {datum_putnog_naloga, relacija_opisno, nacin_putovanja, svrha_putovanja,
         datum_i_vrijeme_pocetka_putovanja, datum_i_vrijeme_kraja_putovanja,zaposlenik_id,
          mjesto_boravka} = req.body

    try{

        const [result] = await pool.query(`insert into registar_putnih_naloga (datum_putnog_naloga, relacija_opisno, nacin_putovanja, svrha_putovanja, datum_i_vrijeme_pocetka_putovanja, datum_i_vrijeme_kraja_putovanja,zaposlenik_id, mjesto_boravka)
        values (?,?,?,?,?,?,?,?)`, [datum_putnog_naloga, relacija_opisno, nacin_putovanja, svrha_putovanja, datum_i_vrijeme_pocetka_putovanja, datum_i_vrijeme_kraja_putovanja,zaposlenik_id, mjesto_boravka])   
        
        res.status(201).json({mssg:"unos uspjesan!", result})    

    }catch (error){
        console.log(error)
        res.status(500).send("Internal Server Error");
    }
}

exports.unosVrijemePutovanja = async(req,res) =>{

    const {redni_broj, br_putnog_naloga, pravac, granicni_prelaz, vrijeme_gr_prelaz} = req.body

    try{

        const [result] = await pool.query(`insert into vrijeme_putovanja (redni_broj, br_putnog_naloga, pravac, granicni_prelaz, vrijeme_gr_prelaz)
        values (?,?,?,?,?)`, [redni_broj, br_putnog_naloga, pravac, granicni_prelaz, vrijeme_gr_prelaz])   
        
        res.status(201).json({mssg:"unos uspjesan!", result})    

    }catch (error){
        console.log(error)
        res.status(500).send("Internal Server Error");
    }
}

exports.unosCjenovnikaDnevnica = async (req,res) =>{
    /*
    primjer unosa:
    {
    "datum": "2023-02-22",
    "cjenovnik_opis":"opis cjenovnika",
    "cjenovnik_napomena":"napomena cjenovnika",
    "podaci": [
        { "drzava": "Svicarska", "iznos": 100, "dnevnica_opis": "opis dnevnice" },
        { "drzava": "Slovenija", "iznos": 75, "dnevnica_opis": ""  },
        ]   
    }   
    */
    const podaci = req.body
    try{
        const [result] = await pool.query(`call unos_cjenovnika_dnevnica(?)`, [JSON.stringify(podaci)])
        res.status(201).json(result)

    }catch (error){
        console.log(error)
        if(error.sqlState === '23000'){
            res.status(404).send("Duplicate entry");
        }else {
            res.status(500).send("Internal Server Error");
        }
        
    }
}
//get controllers

exports.sviZaposlenici = async(req,res)=>{
    try{
        const [result] = await pool.query("SELECT * FROM zaposlenik")

        console.log(result)
    res.send(result)

    }catch (err){
        console.log(err)
        res.status(500).send("Internal Server Error");
    }
    
}

exports.jedanZaposlenik = async(req,res)=>{
    const {id} = req.params 
    try{
        const [result] = await pool.query(`SELECT * FROM zaposlenik where zaposlenik_id = ?`, [id])
        console.log(result)
        if (result.length === 0){
            res.status(404).send("Zaposlenik sa datim id-om nije pronadjen.");
        }else{
            res.status(200).json(result);
        }
    }catch (err){
        res.status(500).send("Internal Server Error");
    }

    
    
}

//obracun dnevnica po drzavi za dati putni nalog
exports.obracunDnevnicaPoNalogu = async(req,res)=>{
    const  id  = req.params.id
    try {
            const [result] = await pool.query(`CALL obracun_dnevnica_po_nalogu(?)`, [id]);
        
        console.log(result[0]);
        res.status(200).json(result[0]);
    } catch (error) {
        console.error(error);
        if(error.sqlState === '45000'){
            res.status(404).send(error.sqlMessage);
        }else {
            res.status(500).send("Internal Server Error");
        }
        
    }
}

//obracun svih putnih troskova u BAM za putni nalog
exports.troskoviPutnogNaloga = async (req,res) =>{
    const  id  = req.params.id
    try {
        let result;
        if (id === "null") {
            [result] = await pool.query(`CALL troskovi_putnog_naloga(null)`);
        } else {       
            [result] = await pool.query(`CALL troskovi_putnog_naloga(?)`, [id]);
        }
        
        console.log(result[0]);
        res.status(200).json(result[0]);
    } catch (error) {
        console.error(error);
        if(error.sqlState === '45000'){
            res.status(404).send(error.sqlMessage);
        }else {
            res.status(500).send("Internal Server Error");
        }
        
    }
}

//ukupni troskovi putnog naloga po valuti
exports.troskoviPoValuti = async (req,res) =>{
    const  {id}  = req.params
    try {
        const [result] = await pool.query(`CALL putni_troskovi_po_valuti(?)`, [id]);
        
        console.log(result[0]);
        res.status(200).json(result[0]);
    } catch (error) {
        console.error(error);
        if(error.sqlState === '45000'){
            res.status(404).send(error.sqlMessage);
        }else {
            res.status(500).send("Internal Server Error");
        }
        
    }
}

//boravak putnika u danima u odredisnoj zemlji
exports.boravakPutnika = async (req,res) =>{
    const  {id}  = req.params
    try {
        let result;
        if (id === "null") {
            [result] = await pool.query(`CALL boravak_putnika(null)`);
        } else {       
            [result] = await pool.query(`CALL boravak_putnika(?)`, [id]);
        }

        
        console.log(result[0]);
        res.status(200).json(result[0]);
    } catch (error) {
        console.error(error);
        if(error.sqlState === '45000'){
            res.status(404).send(error.sqlMessage);
        }else {
            res.status(500).send("Internal Server Error");
        }
        
    }
}

