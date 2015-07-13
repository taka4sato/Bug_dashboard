express = require('express')
mongodb = require('mongodb')
router = express.Router()
logger = require('./logger')
mongo_query = require('./mongo_query')

DB_name = 'posttest'
collectionDMSQuery = 'dms_test'
dbInstance = ''

expireDuration = 5184000 ## sec, 60 days = 3600 * 24 * 60
#expireDuration = 3600   ## sec, 1 hour

router.post '/', (req, res) ->
  res.set 'Content-Type': 'charset=utf-8'
  mongo_query.open_db(DB_name).then((database) ->
    mongo_query.check_collection_exist database, collectionDMSQuery)
  .then((database) ->
    dbInstance = database
    pipe = "{'ttl_date':1}, {expireAfterSeconds: " + expireDuration + "}"
    mongo_query.create_index(dbInstance, collectionDMSQuery, pipe))
  .then(() ->
    req.body["ttl_date"] = new Date
    mongo_query.post_item dbInstance, collectionDMSQuery, req.body)

  ##.then((database) ->
  ##  mongo_query.dump_latest_items database, collectionDMSQuery, 5)
  ## .then((items) ->
  .then(() ->

    res.set 'Content-Type': 'application/json; charset=utf-8'
    res.set 'Cache-Control': 'max-age=0'
    logger.debug 'POST insert done successfully'
    if req.body.hasOwnProperty("query_key") and req.body.hasOwnProperty("DMS_count")
      logger.debug 'DMS item num = ' + req.body.DMS_count + '  Query key = ' + req.body.query_key

    res.end JSON.stringify(req.body)
    return)
  .catch (error) ->
    logger.error error
    res.end 'Fail to POST queries : ' + error
    return
  .finally () ->
    if (dbInstance)
      dbInstance.close()
    return
  return

module.exports = router