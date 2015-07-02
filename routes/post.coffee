express = require('express')
mongodb = require('mongodb')
router = express.Router()
logger = require('./logger')
mongo_query = require('./mongo_query')
### POST API I/F.

 For this endpoint (/v1/post), "POST" works with "Content-Type" set to "application/json"
 http://localhost/v1/post
 http://ec2-54-64-81-68.ap-northeast-1.compute.amazonaws.com/v1/post

 For this endpoint (/v1/post), "GET" also works and dump the 5 items of "dms_test" collection
 http://localhost/v1/post
 http://ec2-54-64-81-68.ap-northeast-1.compute.amazonaws.com/v1/post
###
DB_name = 'posttest'
collectionDMSQuery = 'dms_test'

## test for expire, just set to 1hour
#expireDuration = 535680 ## sec, 31 days = 3600 * 24 * 31
expireDuration = 3600 ## sec, 31 days = 3600 * 24 * 31

router.post '/', (req, res) ->
  res.set 'Content-Type': 'charset=utf-8'
  mongo_query.open_db(DB_name).then((database) ->
    mongo_query.check_collection_exist database, collectionDMSQuery)
  .then((database) ->
    pipe = "{'ttl_date':1}, {expireAfterSeconds: " + expireDuration + "}"
    mongo_query.create_index(database, collectionDMSQuery, pipe))
  .then((database) ->
    logger.error "================old================="
    logger.error req.body
    logger.error "================old================="
    req.body["ttl_date"] = new Date
    logger.error "================new================="
    logger.error req.body
    logger.error "================new================="
    mongo_query.post_item database, collectionDMSQuery, req.body)

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
  return

module.exports = router