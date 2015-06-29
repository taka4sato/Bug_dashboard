express = require('express')
logger = require('./logger')
schedule = require('node-schedule')
mongodb = require('mongodb')
mongo_query = require('./mongo_query')
promise = require("bluebird")
router = express.Router()

DB_name = 'posttest'
Collection_name = 'dms_test'
db_instance = ""


## currently every 1 hour (when xx:30, it is invoked)
j = schedule.scheduleJob('30 * * * *', ->
  date1 = new Date
  date_string1 = date1.getFullYear() + '-' + String(date1.getMonth() + 1) + '-' + date1.getDate() + '-' + date1.getHours()
  logger.error "schedule job invoked : " + date_string1

  mongo_query.open_db(DB_name).then((database) ->
    mongo_query.check_collection_exist database, Collection_name)
  .then((database) ->
    db_instance = database
    query_pipe = [ { $group:
      _id: '$query_key'
      lastQueryDate: '$max': '$query_date'
      count: '$sum': 1 } ]
    mongo_query.query_list db_instance, query_pipe, Collection_name)
  .then((result) ->
    output_array = []
    promise_array = []

    #たぶん、ここで、lastQueryDateを見て、 dms_daily_countに登録するかの判定が必要
    for count of result
      output_array.push(result[count]['_id'])
    for query_key_item in output_array
      promise_array.push(mongo_query.dump_one(db_instance, Collection_name, query_key_item, 1))
    promise.all(promise_array))
  .then((dataArray) ->
    date = new Date

    #getHoursを2桁にする必要有り

    year = String(date.getFullYear())
    month = date.getMonth() + 1
    if (month < 10)
      month = '0' + month
    day =  date.getDate()
    if (day < 10)
      day = '0' + day
    hour =  date.getHours()
    if (hour < 10)
      hour = '0' + hour

    date_string = [year, month, day, hour].join('-')
    #logger.error date_string

    promise_array = []
    for item in dataArray
      object_to_register = {"query_date": date_string}
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
      logger.error "registerd key : " + object_to_register["query_key"]
      logger.error "registerd #   : " + object_to_register["DMS_count"]
      promise_array.push(mongo_query.post_item db_instance, "dms_daily_count", object_to_register)
      promise.all(promise_array))

  .catch (error) ->
    logger.error error
)

module.exports = router