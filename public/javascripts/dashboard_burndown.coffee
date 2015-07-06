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

    #testJSON = '[{"query_date":"2015-07-02-13-43","ttl_date":"2015-07-02T04:43:00.655Z","DMS_count":2,"query_key":"Public Queries/A&SD/InfoEyeTest/Info Eye IA Device Applications (active)","DMS_List":["DMS06355888","DMS06423265"]},{"query_date":"2015-07-02-13-42","ttl_date":"2015-07-02T04:42:00.649Z","DMS_count":2,"query_key":"TestQueryKey","DMS_List":["DMS06355888","DMS06423265"]},{"query_date":"2015-07-02-13-41","ttl_date":"2015-07-02T04:41:00.665Z","DMS_count":2,"query_key":"Public Queries/A&SD/InfoEyeTest/Info Eye IA Device Applications (active)","DMS_List":["DMS06355888","DMS06423265"]},{"query_date":"2015-07-02-13-40","ttl_date":"2015-07-02T04:40:00.667Z","DMS_count":2,"query_key":"Public Queries/A&SD/InfoEyeTest/Info Eye IA Device Applications (active)","DMS_List":["DMS06355888","DMS06423265"]},{"query_date":"2015-07-02-13-39","ttl_date":"2015-07-02T04:39:00.622Z","DMS_count":2,"query_key":"Public Queries/A&SD/InfoEyeTest/Info Eye IA Device Applications (active)","DMS_List":["DMS06355888","DMS06423265"]}]'
    #testJSON = '[{"query_date":"2015-07-02", "DMS_count":2, "DMS_List":["DMS06355888","DMS06423265"]},{"query_date":"2015-07-05", "DMS_count":2, "DMS_List":["DMS06355888","DMS06423265"]}]'
    #testJSON = '[{"query_date":"2015-07-02", "DMS_count":2, "DMS_List":["DMS06355888", "DMS06423265"]},{"query_date":"2015-07-05", "DMS_count":3, "DMS_List":["DMS06355888", "DMS06423265", "DMS06423277"]},{"query_date":"2015-07-07", "DMS_count":3, "DMS_List":["DMS06355888", "DMS06423265", "DMS06423277"]}]'
    testJSON = '[{"query_date":"2015-07-02", "DMS_count":2, "DMS_List":["DMS06355888", "DMS06423265"]},{"query_date":"2015-07-05", "DMS_count":3, "DMS_List":["DMS06355888", "DMS06423265", "DMS06423277"]},{"query_date":"2015-07-07", "DMS_count":3, "DMS_List":["DMS06355888", "DMS06423277"]}]'
    #testJSON = '[]'
    highChartObject = new HighChartObjects(testJSON)

    $('#chart_placeholder').highcharts
      chart: type: 'line'
      title: text: 'DMS burndown chart'
      xAxis: categories: highChartObject.chartDateArray
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
          data: highChartObject.chartNumOfTotalDMSArray
        }
        {
          yAxis: 0
          name: 'New DMS #'
          data: highChartObject.chartNumOfNewDMSArray
        }
        {
          yAxis: 0
          name: 'Fixed DMS #'
          data: highChartObject.chartNumOfFixedDMSArray
        }
      ]
    return

class HighChartObjects
  originalJSON = ""
  timezoneOffset = (new Date).getTimezoneOffset()
  expectedDuration = 1000*3600*24   # 1 day = 1000 msec * 3600 * 24
  chartDateArray: []
  chartNumOfTotalDMSArray: []
  chartNumOfNewDMSArray  : []
  chartNumOfFixedDMSArray: []

  constructor: (json)->
    if $.isEmptyObject(JSON.parse(json)) != true
      originalJSON = JSON.parse(json)
      originalJSON = _complimentDate.call @, originalJSON
      _createChartElement.call @, originalJSON

      console.log originalJSON
      console.log "Date: #{@chartDateArray}"
      console.log "TTL#: #{@chartNumOfTotalDMSArray}"
      console.log "New#: #{@chartNumOfNewDMSArray}"
      console.log "Fix#: #{@chartNumOfFixedDMSArray}"
    else
      console.log "there is no data.."

  ## @private class
  _createChartElement = (originalJSON)->
    for item, count in originalJSON
      @chartDateArray.push(item["query_date"])
      @chartNumOfTotalDMSArray.push(item["DMS_List"].length)

      if originalJSON.length == 1 or count == 0
        @chartNumOfNewDMSArray.push(0)
        @chartNumOfFixedDMSArray.push(0)

      else
        numOfNewFixedItem = _compareDMSList.call(@, originalJSON[count-1]["DMS_List"], originalJSON[count]["DMS_List"])
        @chartNumOfFixedDMSArray.push (numOfNewFixedItem[1])
        @chartNumOfNewDMSArray.push(numOfNewFixedItem[0])

  ## @private class
  _compareDMSList = (originalList, targetList)->
    numOfNewItem   = 0
    numOfFixedItem = 0

    for item in originalList
      if targetList.indexOf(item) == -1
        numOfFixedItem++

    for item in targetList
      if originalList.indexOf(item) == -1
        numOfNewItem++

    return [numOfNewItem, numOfFixedItem]

  ## @private class
  _complimentDate = (originalJSON)->
    complimentaryJSON = []

    for item, count in originalJSON
      momentDate = moment(item["query_date"], "YYYY-MM-DD").utc().subtract(timezoneOffset, "m")

      if count !=  originalJSON.length - 1
        momentDateNext =  moment(originalJSON[count+1]["query_date"], "YYYY-MM-DD").utc().subtract(timezoneOffset, "m")

        # in the case there are missing data
        delta = momentDateNext.diff(momentDate) / expectedDuration
        #console.log "delta = " + delta
        if delta != 1
          i = 1
          while i < delta
            complimentaryJSONTemp = JSON.parse(JSON.stringify(item))
            complimentaryJSONTemp["query_date"] = momentDate.add(1, "d").format("YYYY-MM-DD")
            complimentaryJSON.push (complimentaryJSONTemp)
            i++

    for item  in complimentaryJSON
      originalJSON.push(item)

    originalJSON.sort (a,b) ->
      if a["query_date"] < b["query_date"]
        return -1
      if a["query_date"] > b["query_date"]
        return 1

    return originalJSON
