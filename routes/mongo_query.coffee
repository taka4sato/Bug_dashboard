promise = require("bluebird")
mongodb = require("mongodb")

###
 Common function related to mongo DB.
###

mongo_url = process.env.MONGO_HOST or 'localhost:27017'
exports.open_db = (database_name) ->
  new promise((resolve, reject) ->
    options = server: socketOptions: connectTimeoutMS: 1000
    mongodb.MongoClient.connect 'mongodb://' + mongo_url + '/' + database_name, options, (error, database) ->
      if !error
        resolve database
      else
        reject error
      return
    return
  )

exports.dump_one = (database, Coll_name, path, count) ->
  new promise((resolve, reject) ->
    collection = database.collection(Coll_name)
    collection.find(query_key: path).sort(query_date: -1).limit(count).toArray (error, items) ->
      unless error
        resolve items
      else
        reject error
      return
    return
  )

exports.query_by_condition = (database, Coll_name, query_pipe) ->
  new promise((resolve, reject) ->
    collection = database.collection(Coll_name)
    collection.find(query_pipe).toArray (error, items) ->
      unless error
        resolve items
      else
        reject error
      return
    return
  )

exports.create_index = (database, Coll_name, pipe) ->
  new promise((resolve, reject) ->
    collection = database.collection(Coll_name)
    collection.ensureIndex pipe, (error, items) ->
      unless error
        resolve items
      else
        reject error
      return
    return
  )



## Dump latest records, sorted by "query_date"

exports.dump_latest_items = (database, Coll_name, count) ->
  new promise((resolve, reject) ->
    collection = database.collection(Coll_name)
    collection.find().sort(query_date: -1).limit(count).toArray (error, items) ->
      unless error
        resolve items
      else
        reject error
      return
    return
  )

exports.check_collection_exist = (database, Collection_name) ->
  new promise((resolve, reject) ->
    database.collectionNames Collection_name, (error, items) ->
      if not error and items.length is 1
        resolve database
      else unless error
        reject "no record found for collection : " + Collection_name
      else
        reject error
      return
    return
  )

## Mongo query with mongo aggregation by "pipe"
exports.query_list = (database, pipe, Collection_name) ->
  new promise((resolve, reject) ->
    query_collection = database.collection(Collection_name)
    query_collection.aggregate pipe, (error, result) ->
      unless error
        resolve result
      else
        reject error
      return
    return
  )


## POST a item
exports.post_item = (database, Collection_name, item) ->
  new promise((resolve, reject) ->
    query_collection = database.collection(Collection_name)
    query_collection.insert item, (error) ->
      unless error
        resolve database
      else
        reject error
      return
    return
  )
