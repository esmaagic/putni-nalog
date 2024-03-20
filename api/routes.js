const express = require('express');
const {
    obracunDnevnicaPoNalogu, 
    unosPutniTrosak, 
    unosPutniNalog, 
    unosVrijemePutovanja, 
    unosCjenovnikaDnevnica,
    troskoviPutnogNaloga,
    troskoviPoValuti,
    boravakPutnika,
    sviZaposlenici,
    jedanZaposlenik} 
                = require('./controllers')
const router = express.Router();

router.post('/putniTrosak', unosPutniTrosak)

router.post('/putniNalog', unosPutniNalog)

router.post('/vrijemePutovanja', unosVrijemePutovanja)

router.post('/cjenovnikDnevnica', unosCjenovnikaDnevnica)

router.get('/zaposlenik', sviZaposlenici)

router.get('/zaposlenik/:id', jedanZaposlenik)

router.get('/obracunDnevnica/:id', obracunDnevnicaPoNalogu)

router.get('/troskoviPutnogNaloga/:id', troskoviPutnogNaloga)

router.get('/troskoviPoValuti/:id', troskoviPoValuti)

router.get('/boravakPutnika/:id', boravakPutnika)

module.exports = router