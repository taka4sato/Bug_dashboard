express = require('express')
mongodb = require('mongodb')
router = express.Router()
logger = require('./logger')
mongo_query = require('./mongo_query')


DB_name = 'posttest'
Collection_name = 'dms_daily_count'
router.get '/', (req, res) ->
  if req.query.hasOwnProperty('query_key') and req.query.hasOwnProperty('format') and req.query['format'] is 'json'
    path = req.query['query_key']
    mongo_query.open_db(DB_name)
    .then((database) ->
      mongo_query.dump_one database, Collection_name, path, 30)
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
      mongo_query.dump_latest_items database, Collection_name, 1)
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
    res.render 'dms_daily_count', title: encodeURIComponent(path)


module.exports = router
