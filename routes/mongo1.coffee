express = require('express')
mongodb = require('mongodb')
promise = require('bluebird')
request = require('request')
logger = require('./logger')
router = express.Router()
###
  Test page.. no specific function
###

open_db = (database_name) ->
  new promise((resolve, reject) ->
    mongodb.MongoClient.connect 'mongodb://localhost:27017/' + database_name, (error, database) ->
      if error
        reject error
      else
        resolve database
      return
    return
  )

misc = ->
  p1 = new promise((resolve, reject) ->
    setTimeout resolve, 5000
    return
  )

  p1.then ->
    console.log '1 sec passed'
    return

  async_http = new promise((resolve, reject) ->
    request 'http://google.co.jp', (error, response, body) ->
      if !error and response.statusCode == 200
        # console.log(body);
        resolve response
      else
        reject response
      return
    return
  )

  async_http.then (response) ->
    console.log response.statusCode
    return

  DB_name = 'posttest'
  Collection_name = 'dms_test'

  mongodb.MongoClient.connect 'mongodb://localhost:27017/' + DB_name, (err, database) ->
    if err
      logger.error err
      res.end 'GET : connect fail to db : ' + DB_name
    else
      query_collection = database.collection(Collection_name)
      query_collection.find().limit(1).toArray (err, items) ->
        console.log JSON.stringify(items)
        return
    return
  return

misc3 = ->
  async_http1 = new promise((resolve, reject) ->
    request 'http://google.co.jp', (error, response, body) ->
      if !error and response.statusCode == 200
        resolve response
      else
        reject response
      return
    return
  )

  async_http2 = new promise((resolve, reject) ->
    request 'http://yahoo.co.jp', (error, response, body) ->
      if !error and response.statusCode == 200
        resolve response
      else
        reject response
      return
    return
  )

  just_wait1 = new promise((resolve, reject) ->
    console.log 'start waiting'
    setTimeout resolve, 5000
    return
  )

  async_http1.then((response) ->
    console.log 'http get to google'
    console.log response.statusCode
    just_wait1)
  .then(->
    console.log 'http get to yahoo'
    async_http2)
  .then((response) ->
    console.log response.statusCode
    return)
  .then ->
    res.end 'GET to /mongo1 '
    return
  return

router.get '/', (req, res) ->
  DB_name = 'posttest'
  Coll_name = 'dms_test'
  open_db = (database_name) ->
    new promise((resolve, reject) ->
      mongodb.MongoClient.connect 'mongodb://localhost:27017/' + database_name, (error, database) ->
        if error
          reject error
        else
          resolve database
        return
      return
    )
  dump_one_record = (database, collection_name) ->
    new promise((resolve, reject) ->
      collection = database.collection(collection_name)
      collection.find().limit(2).toArray (error, item) ->
        if !error
          resolve item
        else
          reject error
        return
      return
    )
  open_db(DB_name).then((database) ->
    dump_one_record database, Coll_name)
  .then((item) ->
    console.log JSON.stringify(item)
    res.end 'GET to mongo1'
    return)
  .catch (error) ->
    console.log error
    res.end 'GET to mongo1 failed, error'
    return
  return

router.get '/test', (req, res) ->
  get_http1 = new promise((resolve, reject) ->
    request 'http://google.co.jp', (error, response, body) ->
      if !error and response.statusCode == 200
        resolve response
      else
        reject response
      return
    return
  )

  get_http2 = new promise((resolve, reject) ->
    request 'http://yahoo.co.jp', (error, response, body) ->
      if !error and response.statusCode == 200
        resolve response
      else
        reject response
      return
    return
  )

  just_wait = new promise((resolve, reject) ->
    setTimeout resolve, 5000
    return
  )

  get_http1.then((response) ->
    console.log 'http get to google done! '
    console.log response.statusCode
    just_wait)
  .then(->
    console.log 'wait 5000msec done! '
    get_http2)
  .then((response) ->
    console.log 'http get to yahoo done!'
    console.log response.statusCode
    return)
  .then ->
    res.end 'Async function done'
    return
  console.log 'hogege'
  return

router.get '/test2', (req, res) ->
  get_http1 = new promise((resolve, reject) ->
    console.log 'start http get to google...'
    request 'http://google.co.jp/gege', (error, response) ->
      if !error and response.statusCode == 200
        resolve response
      else
        reject response
      return
    return
  )

  get_http1.then((response) ->
    console.log 'http get to google done! '
    console.log response.statusCode
    return)
  .catch (error) ->
    console.log 'http get failed! '
    console.log error.statusCode
    return
  return

module.exports = router
