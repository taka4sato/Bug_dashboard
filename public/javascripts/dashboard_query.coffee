startpoint_dashboard_query = (queryKey) ->
  $("#Page_Title").append "<span class=\"underline\">" + decodeURIComponent(queryKey) + "</span>"
  targetURL = window.location.protocol + "//" + window.location.host + "/v1/query?query_key=" + queryKey + "&format=json"
  console.log targetURL
  $.getJSON targetURL, (json) ->
    ## console.log json
    createTable json, queryKey

createTable = (json, queryKey) ->
  if json.length isnt 0 and json[0].hasOwnProperty("query_date")
    delta_time = timeAgoInWords(Date.parse(String(json[0].query_date).replace(/-/g, "/")), 1)
    $("#DMS_update_time").append "(Query result as of <span class=\"underline\"><b>" + delta_time + "</b></span>)"
    if json[0].DMS_count is 0
      $("#footer_comment").append "<b>No DMS exists</b> for this query"
    else
    ##$.each json[0].DMS_List, (i, item) ->
    ##  console.log item

      $("#table_placeholder").html "<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" class=\"display responsive\" id=\"DMS_Table\"></table>"
      dms_Table = $("#DMS_Table").DataTable
        data: json[0].DMS_List
        pageLength: 100
        autoWidth: false
        order: [[4, "desc"]]
        columns: [
          data : "DMS_ID"
          title: "DMS_ID"
          width: "20px"
        ,
          data : "Title"
          title: "Title"
        ,
          data : "Component"
          title: "Component"
          width: "80px"
        ,
          data: null
          title: "Tag"
          width: "5px"
          #className: 'details-control'
          orderable: false
          defaultContent: ''
        ,
          data : "Modified_date"
          title: "Last Modified"
          width: "80px"
        ,
          data : "Submit_date"
          title: "Submit Date"
          width: "80px"
        ]
        columnDefs: [{
          targets: [0]
          render: (data, type, row) ->
            return "<a href=\"http://ffs.sonyericsson.net/WebPages/Search.aspx?q=1___" + data + "___issue\" TARGET=\"_blank\">" + data + "</a>"
        },{
          targets: [1]
          render: (data, type, row) ->
            return optimezeTitleLength(data)
        },{
          targets: [3]
          render: (data, type, row, meta) ->
            if type == "display"
              return countTag(data, meta)
        },{
          targets: [4,5]
          render: (data, type, row) ->
            if type == "sort"
              return Date.parse(data.replace(/-/g, "/"))
            else
              return highlightDate(data)
        }]

      $('#DMS_Table tbody').on 'click', 'div.details-control', ->
        tr = $(this).closest('tr')
        row = dms_Table.row(tr)

        if row.child.isShown()  # This row is already open - will close it
          row.child.hide()
          tr.removeClass 'shown'
        else                    # Will open this row
          row.child(addDetailTagInfo(row.data())).show()
          tr.addClass 'shown'

  else
    $("#DMS_update_time").append "<b>Error!</b> Fail to load query result"

countTag = (tag_info, meta_info) ->
  #console.log "------------"
  #console.log tag_info["Tag_info"]
  #console.log tag_info
  #console.log meta_info
  if $.isEmptyObject(tag_info["Tag_info"])    # no tag
    #console.log "------------"
    return ""
  else                                        # if any tag
    #console.log tag_info["Tag_info"][0]
    #console.log "------------"
    count = 0
    $.each tag_info["Tag_info"], (i, item) ->
      count = i
    count = count + 1
    return "<div class='details-control'><img border='0' src='../images/empty.gif'>" + count + "</img></div>"


addDetailTagInfo = (tag_info) ->
  console.log(tag_info["Tag_info"])
  tag_string = ""
  $.each tag_info["Tag_info"], (i, item) ->
    console.log item
    console.log item["Tag"]
    console.log item["DeliveryBranch"]
    tag_string += "<tr><td>" + item["DeliveryBranch"] + "</td><td>" + item["Tag"] + "</td><td>" + "TBD" + "</td></tr>"

  return '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
    '<tr><td>Tag Branch:</td><td>Tag Target</td><td>Deadline</td></tr>'+
    tag_string +
    '</table>'

optimezeTitleLength = (text_string) ->
    escapted_Title = escapeHTML(text_string)
    if text_string.length > 80
      return escapted_Title.substr(0, 120) + "..."
    else
      return  escapted_Title

highlightDate = (text_string) ->
  timeDiff =  timeDelta(Date.parse(text_string.replace(/-/g, "/")))
  timeString = timeAgoInWords(Date.parse(text_string.replace(/-/g, "/")), 0)
  if timeDiff < 60 * 60 * 24 # less than 1 day
    return '<font color="red"><b>' + timeString + '</b></font>'
  else if timeDiff < 60 * 60 * 24 * 3 # less than 3 days
    return '<font color="purple"><b>' + timeString + '</b></font>'
  else if timeDiff < 60 * 60 * 24 * 31 # less than 31 days
    return '<font color="blue"><b>' + timeString + '</b></font>'
  else
    return timeString

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

timeDelta = (date) ->
  try
    now = Math.ceil(Number(new Date().getTime()) / 1000)
    dateTime = Math.ceil(Number(new Date(date)) / 1000)
    return (now - dateTime)
  catch e
    return ""

timeAgoInWords = (date, flag) ->
  try
    diff = timeDelta(date)
    str = undefined

    if diff < 60 * 60 # less than 1 hour
      str = String(Math.floor(diff / (60)))
      return ((if flag is 1 then str + " minutes ago" else "< 1h"))

    else if diff < 60 * 60 * 24 # less than 1 day
      str = String(Math.floor(diff / (60 * 60)))
      return ((if flag is 1 then str + ((if str is "1" then " hour" else " hours")) + " ago" else "< 24h"))

    else if diff < 60 * 60 * 24 * 31 # less than 1 month
      str = String(Math.floor(diff / (60 * 60 * 24)))
      return str + ((if str is "1" then " day" else " days")) + " ago"

    else if diff < 60 * 60 * 24 * 365 # less than 1 year
      str = String(Math.floor(diff / (60 * 60 * 24 * 31)))
      return str + ((if str is "1" then " month" else " months")) + " ago"

    else # more than 1 year
      str = String(Math.floor(diff / (60 * 60 * 24 * 365)))
      return str + ((if str is "1" then " year" else " years")) + " ago"

  catch e
    return ""