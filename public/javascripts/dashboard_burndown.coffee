startpoint_dashboard_burndown = (queryKey) ->
  $("#Page_Title").append "<span class=\"underline\">" + decodeURIComponent(queryKey) + "</span>"
  targetURL = window.location.protocol + "//" + window.location.host + "/v1/daily_count?query_key=" + queryKey + "&format=json"

  $.getJSON targetURL, (json) ->
    console.log json

    $.each json, (count, item) ->
      console.log item["query_key"]
      console.log item["DMS_count"]
      console.log item["query_date"]
      console.log "=========================="
