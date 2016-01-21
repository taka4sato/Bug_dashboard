startpoint_dashboard_query = (queryKey) ->
  $("#Page_Title").append "<span class=\"underline\">" + decodeURIComponent(queryKey) + "</span>"
  targetURL = window.location.protocol + "//" + window.location.host + "/v1/query?query_key=" + queryKey + "&format=json"

  $.getJSON targetURL, (json) ->
    targetURL_tagInfo = window.location.protocol + "//" + window.location.host + "/tag_date/tag_info.json"
    $.getJSON targetURL_tagInfo, (tag_date_info) ->
      createTable json, tag_date_info


createTable = (json, tag_date_info) ->
  if json.length isnt 0 and json[0].hasOwnProperty("query_date")
    delta_time = timeAgoInWords(Date.parse(String(json[0].query_date).replace(/-/g, "/") + " GMT+0000"), 1)
    $("#DMS_update_time").append "(Query result as of <span class=\"underline\"><b>" + delta_time + "</b></span>)"
    $("#return_to_list_URL").append "<a href='" + window.location.protocol + "//" + window.location.host + "/v1/list'> back to Query List </a>"


    if json[0].DMS_count is 0
      $("#footer_comment").append "<b>No DMS exists</b> for this query"
    else

      console.log json
      console.log json[0]["query_key"]

      #$.each json[0]["DMS_List"], (i, item) ->
        #console.log item["DMS_ID"]
        #console.log item["Modified_date"]
        #console.log "=========================="

      $("#table_placeholder").html "<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" class=\"display responsive\" id=\"DMS_Table\"></table>"
      dms_Table = $("#DMS_Table").DataTable
        data: json[0].DMS_List
        pageLength: 100
        autoWidth: false
        bStateSave: true
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
          data : "State"
          title: "State"
          width: "60px"
        ,
          data : "IssueType"
          title: "Type"
          width: "60px"
        ,
          data : "DamageLevel"
          title: "DM"
          width: "60px"
        ,
          data: null
          title: "Tag"
          width: "5px"
          orderable: false
          defaultContent: ''
        ,
          data: null
          title: "Earliest Deadline"
          width: "5px"
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
          targets: [0]   # for DMS ID
          render: (data, type, row) ->
            return "<a href=\"http://ffs.sonyericsson.net/WebPages/Search.aspx?q=1___" + data + "___issue\" TARGET=\"_blank\">" + data + "</a>"
        },{
          targets: [1]   # for Title
          render: (data, type, row) ->
            return optimezeTitleLength(data)
        },{
          targets: [6]   # for has Tag
          render: (data, type, row, meta) ->
            if type == "display"
              return countTag(data, meta)
        },{
          targets: [7]   # for earliest tag deadline
          render: (data, type, row, meta) ->
            if type == "sort"
              return sortEarliestTagDeadline(data, tag_date_info)
            else
              return showEarliestTagDeadline(data, tag_date_info)
        },{
          targets: [8,9] # Submit/last modified date
          render: (data, type, row) ->
            if type == "sort"
              return Date.parse(data.replace(/-/g, "/") + " GMT+0000")
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
          row.child(addDetailTagInfo(row.data(), tag_date_info)).show()
          tr.addClass 'shown'


      $("#DMS_Table_filter").prepend "<span><button type='button' id='covlis_button' class='btn btn-default'>show hide column</button></span>"

      colvis = new ($.fn.dataTable.ColVis)(dms_Table,
        exclude: [0, 1]
        bCssPosition: true)

      $('#covlis_button').on 'click', (e) ->
        e.preventDefault()
        pos = {}
        target = $(this)
        pos.x = target.offset().left
        pos.y = target.offset().top + target.outerHeight()
        $(colvis.dom.collection).css
          position: 'absolute'
          left: pos.x
          top: pos.y
        colvis._fnCollectionShow()

      $("#DMS_Table_filter").prepend "<span><button type='button' id='burndown_button' class='btn btn-default'>show Burndown Chart</button></span>"
      $('#burndown_button').on 'click', (e) ->
        dashboard_URL = window.location.protocol + "//" + window.location.host + "/v1/daily_count?query_key=" + encodeURIComponent(json[0]["query_key"])
        location.href = dashboard_URL


  else
    $("#DMS_update_time").append "<b>Error!</b> Fail to load query result"


calculateEarliestTagDeadline = (tag_info, tag_date_info) ->
  if $.isEmptyObject(tag_info["Tag_info"])    # no tag
    return ""
  else
    isASAPExist = false
    tagDeadlineDateArray = []
    $.each tag_info["Tag_info"], (i, tagInfoItem) ->
      #console.log tagInfoItem["Tag"]
      #console.log tagInfoItem["DeliveryBranch"]

      if tagInfoItem["Tag"] == "Fix ASAP"
        isASAPExist = true
        return false
      else
        $.each tag_date_info["Tag_item"], (i, itemDateItem) ->
          if itemDateItem["Tag_branch"] == tagInfoItem["DeliveryBranch"] and itemDateItem["Tag_name"] == tagInfoItem["Tag"]
            tagDeadlineDateArray.push(itemDateItem["Tag_deadline"])

    if  isASAPExist == true
      return "ASAP"
    else if tagDeadlineDateArray.length == 0
      return ""
    else
      tagDeadlineDateArray.sort (a, b) ->
        if a < b
          return -1
        else
          return 1
      return tagDeadlineDateArray[0]

sortEarliestTagDeadline = (tag_info, tag_date_info) ->
  earliestDeadline = calculateEarliestTagDeadline(tag_info, tag_date_info)
  if earliestDeadline == "ASAP"
    return "0"
  else if earliestDeadline == ""
    return "9"

  else
    return earliestDeadline

showEarliestTagDeadline = (tag_info, tag_date_info) ->
  #console.log  tag_info
  earliestDeadline = calculateEarliestTagDeadline(tag_info, tag_date_info)
  if earliestDeadline == "ASAP"
    return '<font color="red"><b>ASAP</b></font>'
  else
    return  earliestDeadline


countTag = (tag_info, meta_info) ->
  if $.isEmptyObject(tag_info["Tag_info"])    # no tag
    return ""
  else                                        # if any tag
    count = 0
    $.each tag_info["Tag_info"], (i, item) ->
      count = i
    count = count + 1
    if count == 1
      return "<div class='details-control'><img border='0' src='../images/empty.gif'> </img></div>"
    else
      return "<div class='details-control'><img border='0' src='../images/empty.gif'>" + count + "</img></div>"


addDetailTagInfo = (tag_info, tag_date_info) ->

  tag_string = ""
  $.each tag_info["Tag_info"], (i, item_tag_info) ->
    if item_tag_info["Tag"] == "Fix ASAP"
      tag_string += "<tr><td>" + item_tag_info["DeliveryBranch"] + "</td><td>" + item_tag_info["Tag"] + "</td><td bgcolor='#FF0000'>ASAP</td></tr>"

    else
      tag_deadline = ""
      $.each tag_date_info["Tag_item"], (i, item_date_info) ->
        if item_date_info["Tag_branch"] == item_tag_info["DeliveryBranch"] and item_date_info["Tag_name"] == item_tag_info["Tag"]
          tag_deadline = item_date_info["Tag_deadline"]
      tag_string += "<tr><td>" + item_tag_info["DeliveryBranch"] + "</td><td>" + item_tag_info["Tag"] + "</td><td>" + tag_deadline + "</td></tr>"

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
  timeDiff =  timeDelta(Date.parse(text_string.replace(/-/g, "/") + " GMT+0000"))
  timeString = timeAgoInWords(Date.parse(text_string.replace(/-/g, "/") + " GMT+0000"), 0)
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