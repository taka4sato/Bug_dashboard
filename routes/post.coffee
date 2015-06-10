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
Collection_name = 'dms_test'
router.post '/', (req, res) ->
  res.set 'Content-Type': 'charset=utf-8'
  mongo_query.open_db(DB_name).then((database) ->
    mongo_query.check_collection_exist database, Collection_name)
  .then((database) ->
    mongo_query.post_item database, Collection_name, req.body)

  ##.then((database) ->
  ##  mongo_query.dump_latest_items database, Collection_name, 5)
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