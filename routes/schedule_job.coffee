express = require('express')
logger = require('./logger')
schedule = require('node-schedule')
mongo_query = require('./mongo_query')
promise = require("bluebird")
router = express.Router()

DB_name = 'posttest'
collectionDMSQuery   = 'dms_test'
collectionDailyCount = 'dms_daily_count'
dbInstance = ""
expireDuration = 5184000 ## sec, 60 days = 3600 * 24 * 60
seeAsValidRecordDuration = 43200000  # msec, 12h = 1000*60*60*12

mongo_query.open_db(DB_name).then((database) ->
  mongo_query.check_collection_exist database, collectionDailyCount)
.then((database) ->
  pipe = "{'ttl_date':1}, {expireAfterSeconds: " + expireDuration + "}"
  mongo_query.create_index(database, collectionDailyCount, pipe))
.catch (error) ->
  logger.error error


## currently invoked every day at 00:15 UTC (= 9:15 JST)
## if you want to execute job every 1 mins, just set to "*/1 * * * *"
j = schedule.scheduleJob('15 0 * * *', ->

  date_string = getDateString(new Date)
  logger.error "schedule job invoked : " + date_string

  mongo_query.open_db(DB_name).then((database) ->
    mongo_query.check_collection_exist database, collectionDMSQuery)
  .then((database) ->
    dbInstance = database
    query_pipe = [ { $group:
      _id: '$query_key'
      lastQueryDate: '$max': '$query_date'
      count: '$sum': 1 } ]
    mongo_query.query_list dbInstance, query_pipe, collectionDMSQuery)
  .then((result) ->
    output_array = []
    promise_array = []

    for count of result
      deltaDate = new Date - Date.parse(result[count]["lastQueryDate"])
      if deltaDate < seeAsValidRecordDuration
        output_array.push(result[count]['_id'])
      else
        logger.error "Schedule job see the record out of date : " + result[count]['_id']


    for query_key_item in output_array
      promise_array.push(mongo_query.dump_one(dbInstance, collectionDMSQuery, query_key_item, 1))
    promise.all(promise_array))
  .then((dataArray) ->
    promise_array = []
    for item in dataArray
      object_to_register = {"query_date": date_string, "ttl_date": new Date}
      DMS_id_array = []
      if item[0]["DMS_List"].length isnt 0
        object_to_register["DMS_count"] = item[0]["DMS_List"].length
        for dms_id in item[0]["DMS_List"]
          DMS_id_array.push (dms_id["DMS_ID"])
        DMS_id_array.sort (a, b) ->
          if a < b
            return -1
          else
            return 1
      else
        object_to_register["DMS_count"] = 0

      object_to_register["query_key"] = item[0]["query_key"]
      object_to_register["DMS_List"] = DMS_id_array
      #logger.error "query date : " + object_to_register["query_date"] + "registered key : " + object_to_register["query_key"]
      #logger.error "registered #   : " + object_to_register["DMS_count"]
      promise_array.push(mongo_query.post_item dbInstance, collectionDailyCount, object_to_register)
    promise.all(promise_array))
  .catch (error) ->
    logger.error error
  .finally () ->
    if (dbInstance)
      dbInstance.close()
    return
)

###
.then((result) ->
  mongo_query.dump_latest_items dbInstance, collectionDailyCount, 30)
.then((items) ->
  logger.error "==last 5 items==================="
  for item in items
    logger.error JSON.stringify(item["query_date"], null, "  ")
  logger.error "==last 5 items===================")
###


getDateString = (dateInfo) ->
  year = String(dateInfo.getFullYear())
  month = dateInfo.getMonth() + 1
  if (month < 10)
    month = '0' + month
  day =  dateInfo.getDate()
  if (day < 10)
    day = '0' + day

  return [year, month, day].join('-')

module.exports = router