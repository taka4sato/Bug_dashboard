express = require("express")
path = require("path")
favicon = require("serve-favicon")
morgan = require("morgan")
cookieParser = require("cookie-parser")
bodyParser = require("body-parser")
logger = require("./routes/logger")
index  = require("./routes/index")
query  = require("./routes/query")
post   = require("./routes/post")
list   = require("./routes/list")
mongo1 = require("./routes/mongo1")

app = express()

# view engine setup
app.set "views", path.join(__dirname, "views")
app.set "view engine", "ejs"
app.set 'host_name', process.env.MONGO_HOST or 'localhost:27017'

# uncomment after placing your favicon in /public
app.use favicon(__dirname + '/public/favicon.ico')
morgan.format 'ltsv-format', 'time::date[iso]\t uri::url\t method::method\t status::status\t reqtime::response-time\t'
app.use morgan('ltsv-format')
app.use bodyParser.json({limit: '50mb'})
app.use bodyParser.urlencoded({ limit: '50mb', extended: false })
app.use cookieParser()
app.use express.static(path.join(__dirname, "public"))
app.use "/", index
app.use "/v1/query", query
app.use "/v1/post", post
app.use "/v1/list", list
app.use "/v1/mongo1", mongo1

# catch 404 and forward to error handler
app.use (req, res, next) ->
  err = new Error("Not Found")
  err.status = 404
  next err
  return


# error handlers

# development error handler
# will print stacktrace
if app.get("env") is "development"
  app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render "error",
      message: err.message
      error: err
    return


# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
  res.status err.status or 500
  res.render "error",
    message: err.message
    error: {}
  return

module.exports = app
