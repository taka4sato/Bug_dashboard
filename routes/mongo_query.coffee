promise = require("bluebird")
mongodb = require("mongodb")

###
 Common function related to mongo DB.
###

exports.open_db = (database_name) ->
  new promise((resolve, reject) ->
    mongodb.MongoClient.connect "mongodb://localhost:27017/" + database_name, (error, database) ->
      unless error
        resolve database
      else
        reject error
      return
    return
  )

exports.dump_one = (database, Coll_name, path) ->
  new promise((resolve, reject) ->
    collection = database.collection(Coll_name)
    collection.find(query_key: path).sort(query_date: -1).limit(1).toArray (error, items) ->
      unless error
        resolve items
      else
        reject error
      return
    return
  )

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
