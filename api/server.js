const express  = require('express')
const app = express()
const router = require('./routes')

app.use(express.urlencoded({extended:false}))
app.use(express.json())

app.use('/api', router)

app.listen('3000',()=> console.log('server is running'))
