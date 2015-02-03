express = require("express")
router = express.Router()

# GET home page.
router.get "/", (req, res) ->
  res.end "This is index page"

  return

module.exports = router