express = require('express')
mongodb = require('mongodb')
router = express.Router()
logger = require('./logger')
mongo_query = require('./mongo_query')

###
 Check the db's collection exist.
 If not exist return proper json to indicate collection not exist.
 If exist. return json.
###

DB_name = 'posttest'
Collection_name = 'dms_test'
router.get '/', (req, res) ->
  # case need to return json file
  if req.query.hasOwnProperty('query_key') and req.query.hasOwnProperty('format') and req.query['format'] is 'json'
    path = req.query['query_key']
    mongo_query.open_db(DB_name)
    .then((database) ->
      mongo_query.dump_one database, Collection_name, path, 1)
    .then((items) ->
      res.set 'Content-Type': 'application/json; charset=utf-8'
      res.set 'Cache-Control': 'no-cache, max-age=0'
      res.end JSON.stringify(items)
      return)
    .catch (error) ->
      logger.error error
      res.end 'Fail to connect to DB : ' + error
      return

  else if !req.query.hasOwnProperty('query_key')
    mongo_query.open_db(DB_name).then((database) ->
      mongo_query.dump_latest_items database, Collection_name, 10)
    .then((items) ->
      res.set 'Content-Type': 'application/json; charset=utf-8'
      res.set 'Cache-Control': 'no-cache, max-age=0'
      res.end JSON.stringify(items)
      return)
    .catch (error) ->
      logger.error error
      res.end 'Fail to connect to DB : ' + error
      return
  else
    path = req.query['query_key']
    res.set 'Cache-Control': 'no-cache, max-age=0'
    res.render 'query', title: encodeURIComponent(path)
    return

module.exports = router