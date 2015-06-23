express = require('express')
mongodb = require('mongodb')
file   = require('fs')
router = express.Router()
logger = require('./logger')

router.post '/', (req, res) ->
  filename = 'public/tag_date/test.json'
  console.log req.body
  file.writeFile filename, JSON.stringify(req.body), (err) ->
    if err
      throw err
    else
      console.log 'file write done! '
      res.set 'Content-Type': 'application/json; charset=utf-8'
      res.end JSON.stringify(req.body)
      return
  return



router.get '/', (req, res) ->
  filename = 'public/tag_date/test.json'
  file.readFile filename, 'utf8', (err, text) ->
    if err
      logger.error 'err to readFile'
      res.end 'Cannot find Tag date data'
      return
    else
      console.log text
      res.set 'Cache-Control': 'no-cache, max-age=0'
      res.render 'edit_tag_date'
      return
  return

module.exports = router