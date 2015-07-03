startpoint_dashboard_burndown = (queryKey) ->
  $("#Page_Title").append "<span class=\"underline\">" + decodeURIComponent(queryKey) + "</span>"
  targetURL = window.location.protocol + "//" + window.location.host + "/v1/daily_count?query_key=" + queryKey + "&format=json"

  $.getJSON targetURL, (json) ->
    #console.log json

    ###
    $.each json, (count, item) ->
      console.log item["query_key"]
      console.log item["DMS_count"]
      console.log item["query_date"]
      console.log "=========================="
    ###

    #testJSON = '[{"query_date":"2015-07-02-13-43","ttl_date":"2015-07-02T04:43:00.655Z","DMS_count":2,"query_key":"Public Queries/A&SD/InfoEyeTest/Info Eye IA Device Applications (active)","DMS_List":["DMS06355888","DMS06423265"]},{"query_date":"2015-07-02-13-42","ttl_date":"2015-07-02T04:42:00.649Z","DMS_count":2,"query_key":"TestQueryKey","DMS_List":["DMS06355888","DMS06423265"]},{"query_date":"2015-07-02-13-41","ttl_date":"2015-07-02T04:41:00.665Z","DMS_count":2,"query_key":"Public Queries/A&SD/InfoEyeTest/Info Eye IA Device Applications (active)","DMS_List":["DMS06355888","DMS06423265"]},{"query_date":"2015-07-02-13-40","ttl_date":"2015-07-02T04:40:00.667Z","DMS_count":2,"query_key":"Public Queries/A&SD/InfoEyeTest/Info Eye IA Device Applications (active)","DMS_List":["DMS06355888","DMS06423265"]},{"query_date":"2015-07-02-13-39","ttl_date":"2015-07-02T04:39:00.622Z","DMS_count":2,"query_key":"Public Queries/A&SD/InfoEyeTest/Info Eye IA Device Applications (active)","DMS_List":["DMS06355888","DMS06423265"]}]'
    testJSON = '[{"query_date":"2015-07-02-13-43", "DMS_count":2, "DMS_List":["DMS06355888","DMS06423265"]},{"query_date":"2015-07-02-13-41", "DMS_count":2, "DMS_List":["DMS06355888","DMS06423265"]}]'

    highChartObject = new HighChartObjects(testJSON)

    DMSChartDate = ["6/26", "6/27", "6/28", "6/29", "6/30", "7/1", "7/2"]
    DMSChartTotalItem = [22, 22, 22, 22, 22, 22, 22]
    DMSChartNewItem = [0,0,0,0,0,0,0]
    DMSChartFixedItem = [0,0,0,0,0,0,0]

    $('#chart_placeholder').highcharts
      chart: type: 'line'
      title: text: 'DMS burndown chart'
      xAxis: categories: DMSChartDate
      yAxis:
        min: 0
        title: text: '# of DMS'
      tooltip: shared: true
      navigation: buttonOptions: enabled: true
      exporting:
        enabled: true
        type: 'image/jpeg'
        scale: 2
      credits: enabled: false
      plotOptions: line:
        dataLabels: enabled: true
        enableMouseTracking: false
      series: [
        {
          yAxis: 0
          name: 'Total DMS #'
          data: DMSChartTotalItem
        }
        {
          yAxis: 0
          name: 'New DMS #'
          data: DMSChartNewItem
        }
        {
          yAxis: 0
          name: 'Fixed DMS #'
          data: DMSChartFixedItem
        }
      ]
    return

class HighChartObjects
  originalJSON = ""
  complimentaryJSONArray = []

  constructor: (json)->
    originalJSON = JSON.parse(json)
    expectedDuration = 1000*60   # 1 mins = 1000 * 60

    for item, count in originalJSON
      momentDate = moment(item["query_date"], "YYYY-MM-DD-hh-mm").utc()
      temp_moment = momentDate.subtract(5, "minutes").utc()
      console.log "==============================="
      console.log "1 : " + item["query_date"]
      console.log "2 : " + momentDate
      console.log momentDate
      console.log "3 : " + momentDate.format("YYYY-MM-DD-hh-mm")
      console.log "4 : " + momentDate.subtract(5, "minutes").utc()
      console.log "5 : " + momentDate.subtract(5, "minutes").utc().format("YYYY-MM-DD-hh-mm")

      ###
      if count !=  originalJSON.length - 1
        momentDateNext =  moment(originalJSON[count+1]["query_date"], "YYYY-MM-DD-hh-mm")

        # in the case there are missing data
        delta = Math.floor ((momentDate.diff(momentDateNext) / expectedDuration) - 1)
        if delta != 0
          i = 0
          while i < delta
            i++
            console.log "hoge"
            complimentaryJSON = JSON.parse(JSON.stringify(item));
            console.log item
            complimentaryJSON["query_date"] = momentDate.subtract(5, "minutes").format("YYYY-MM-DD-hh-mm")
            console.log complimentaryJSON
            console.log "==============================="

      ###
