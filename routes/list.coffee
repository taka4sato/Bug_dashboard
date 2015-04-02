express = require('express')
mongodb = require('mongodb')
router = express.Router()
logger = require('./logger')
mongo_query = require('./mongo_query')

###
 Check the db's collection exist.
 If exist, create(aggregate) new collection lists up list of "query_key", and return # of record.
###

DB_name = 'posttest'
Collection_name = 'dms_test'
router.get '/', (req, res) ->
  mongo_query.open_db(DB_name).then((database) ->
    mongo_query.check_collection_exist database, Collection_name)
  .then((database) ->
    query_pipe = [ { $group:
      _id: '$query_key'
      count: '$sum': 1 } ]
    mongo_query.query_list database, query_pipe, Collection_name)
  .then((result) ->
    output = []
    for count of result
      target_URL = req.protocol + '://' + req.get('host') + '/v1/query?query_key=' + encodeURIComponent(result[count]['_id'])
      output.push 'query_key': result[count]['_id'], 'num': result[count]['count'], 'URL': target_URL
    logger.debug output
    if req.query.hasOwnProperty('format') and req.query['format'] is 'json'
      res.set 'Content-Type': 'application/json; charset=utf-8'
      res.set 'Cache-Control': 'no-cache, max-age=0'
      res.end JSON.stringify(output)
      return
    else
      res.set 'Cache-Control': 'no-cache, max-age=0'
      res.render 'list'
      return)
  .catch (error) ->
    logger.error error
    res.end 'Fail to list queries : ' + error
    return
  return

module.exports = router
