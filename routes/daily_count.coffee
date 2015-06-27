express = require('express')
mongodb = require('mongodb')
router = express.Router()
logger = require('./logger')
mongo_query = require('./mongo_query')


DB_name = 'posttest'
Collection_name = 'dms_daily_count'
router.get '/', (req, res) ->
  mongo_query.open_db(DB_name).then((database) ->
    mongo_query.check_collection_exist database, Collection_name)
  .then((database) ->
    mongo_query.dump_latest_items database, Collection_name, 10)
  .then((result) ->
    logger.debug result
    res.set 'Content-Type': 'application/json; charset=utf-8'
    res.set 'Cache-Control': 'no-cache, max-age=0'
    res.end JSON.stringify(result))
  .catch (error) ->
    logger.error error
    res.end 'Fail to list queries for daily count: ' + error
    return
  return

module.exports = router
