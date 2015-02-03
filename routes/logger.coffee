log4js = require("log4js")

if process.env.NODE_ENV is "production"
  log4js.configure "./config/logger_prod.json"

else
  log4js.configure "./config/logger_dev.json"

logger = log4js.getLogger("debug")

module.exports = logger