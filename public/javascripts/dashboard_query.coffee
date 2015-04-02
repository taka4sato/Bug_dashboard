startpoint_dashboard_query = (queryKey) ->
  $("#Page_Title").append "<span class=\"underline\">" + decodeURIComponent(queryKey) + "</span>"
  targetURL = window.location.protocol + "//" + window.location.host + "/v1/query?query_key=" + queryKey + "&format=json"
  console.log targetURL
  $.getJSON targetURL, (json) ->
    console.log json
    createTable json, queryKey

createTable = (json, queryKey) ->
  if json.length isnt 0 and json[0].hasOwnProperty("query_date")
    delta_time = timeAgoInWords(Date.parse(String(json[0].query_date).replace(/-/g, "/")))
    $("#DMS_update_time").append "(Query result as of <span class=\"underline\"><b>" + delta_time + "</b></span>)"
    if json[0].DMS_count is 0
      $("#footer_comment").append "<b>No DMS exists</b> for this query"
    else
      output_json = []
      $.each json[0].DMS_List, (i, item) ->
        console.log item
        temp_array = []
        DMS_URL = "<a href=\"http://ffs.sonyericsson.net/WebPages/Search.aspx?q=1___" + item["DMS_ID"] + "___issue\" TARGET=\"_blank\">" + item["DMS_ID"] + "</a>"
        DMS_title = escapeHTML(item["Title"])
        DMS_title = DMS_title.substr(0, 120) + "..."  if item["Title"].length > 80
        timeAgoInWords Date.parse(item["Modified_date"].replace(/-/g, "/"))
        temp_array.push DMS_URL
        temp_array.push DMS_title
        temp_array.push item["Component"]
        temp_array.push timeAgoInWords(Date.parse(item["Modified_date"].replace(/-/g, "/")))
        temp_array.push timeAgoInWords(Date.parse(item["Submit_date"].replace(/-/g, "/")))
        output_json.push temp_array

      $("#table_placeholder").html "<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" class=\"display responsive\" id=\"DMS_Table\"></table>"
      $("#DMS_Table").dataTable
        data: output_json
        pageLength: 50
        autoWidth: false
        columns: [
          title: "DMS_ID"
          width: "20px"
        ,
          title: "Title"
        ,
          title: "Component"
          width: "80px"
        ,
          title: "Last Modified"
          width: "60px"
        ,
          title: "Submit Date"
          width: "60px"
        ]

  else
    $("#DMS_update_time").append "<b>Error!</b> Fail to load query result"

escapeHTML = (text) ->
  replacement = (ch) ->
    characterReference =
      "\"": "&quot;"
      "&": "&amp;"
      "'": "&#39;"
      "<": "&lt;"
      ">": "&gt;"
    characterReference[ch]
  text.replace /["&'<>]/g, replacement

timeAgoInWords = (date) ->
  try
    now = Math.ceil(Number(new Date()) / 1000)
    dateTime = Math.ceil(Number(new Date(date)) / 1000)
    diff = now - dateTime
    str = undefined
    if diff < 60 * 60 # less than 1 hour
      str = String(Math.ceil(diff / (60)))
      return str + ((if str is "1" then " minute" else " minutes")) + " ago"
    else if diff < 60 * 60 * 24 # less than 1 day
      str = String(Math.ceil(diff / (60 * 60)))
      return str + ((if str is "1" then " hour" else " hours")) + " ago"
    else if diff < 60 * 60 * 24 * 31 # less than 1 month
      str = String(Math.ceil(diff / (60 * 60 * 24)))
      return str + ((if str is "1" then " day" else " days")) + " ago"
    else if diff < 60 * 60 * 24 * 365 # less than 1 year
      str = String(Math.ceil(diff / (60 * 60 * 24 * 31)))
      return str + ((if str is "1" then " month" else " months")) + " ago"
    else # more than 1 year
      str = String(Math.ceil(diff / (60 * 60 * 24 * 365) - 1.0))
      return str + ((if str is "1" then " year" else " years")) + " ago"
  catch e
    return ""