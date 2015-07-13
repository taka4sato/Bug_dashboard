express = require('express')
mongodb = require('mongodb')
moment  = require('moment')
router = express.Router()
logger = require('./logger')
mongo_query = require('./mongo_query')


DB_name = 'posttest'
Collection_name = 'dms_daily_count'
dbInstance = ''

router.get '/', (req, res) ->

  # case request has all of 'query_key', 'query_duration', 'format' params
  if req.query.query_key? and req.query.query_duration? and req.query.format? and req.query.format is 'json'
    duration = req.query['query_duration']
    path = req.query['query_key']

    mongo_query.open_db(DB_name)
    .then((database) ->
      dbInstance = database
      date_string =  moment().utc().subtract(duration, "d").format("YYYY-MM-DD")
      pipe = 'query_key': path
      'query_date': '$gte': date_string
      mongo_query.query_by_condition database, Collection_name, pipe)
    .then((items) ->
      #logger.error JSON.stringify(items, null, "  ")
      res.set 'Content-Type': 'application/json; charset=utf-8'
      res.set 'Cache-Control': 'no-cache, max-age=0'
      res.end JSON.stringify(items)
      return)
    .catch (error) ->
      logger.error error
      res.end 'Fail to connect to DB : ' + error
      return
    .finally () ->
      if (dbInstance)
        dbInstance.close()
      return

  # case request has both 'query_key' and 'format' params
  else if req.query.query_key? and req.query.format? and req.query.format is 'json'
    path = req.query['query_key']
    mongo_query.open_db(DB_name)
    .then((database) ->
      dbInstance = database
      mongo_query.dump_one database, Collection_name, path, 14)
    .then((items) ->
      res.set 'Content-Type': 'application/json; charset=utf-8'
      res.set 'Cache-Control': 'no-cache, max-age=0'
      res.end JSON.stringify(items)
      return)
    .catch (error) ->
      logger.error error
      res.end 'Fail to connect to DB : ' + error
      return
    .finally () ->
      if (dbInstance)
        dbInstance.close()
      return

  # case request does NOT have 'query_key' param
  else if !req.query.hasOwnProperty('query_key')
    mongo_query.open_db(DB_name)
    .then((database) ->
      dbInstance = database
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
    .finally () ->
      if (dbInstance)
        dbInstance.close()
      return

  # case request only has 'query_key' param
  else
    path = req.query['query_key']
    res.set 'Cache-Control': 'no-cache, max-age=0'
    res.render 'dms_daily_count', title: encodeURIComponent(path)


module.exports = router
