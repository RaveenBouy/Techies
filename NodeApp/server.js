const express = require('express')
const app = express()
const port = 80

app.get('/', (req,res) =>
{
    res.send(`${Math.floor(Math.random() * 9999999999999)}${Math.floor(Math.random() * 9999999999999)}${Math.floor(Math.random() * 9999999999999)}`)
})

app.listen(port, () =>
{
    console.log(`Server is listening on port:${port}`)
})