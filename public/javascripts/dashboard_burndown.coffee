startpoint_dashboard_burndown = (queryKey, chartDuration) ->
  $("#Page_Title").append "<span class=\"underline\">" + decodeURIComponent(queryKey) + "</span>"
  targetURL = window.location.protocol + "//" + window.location.host + "/v1/daily_count?query_key=" + queryKey + "&format=json&query_duration=" + chartDuration

  $.getJSON targetURL, (json) ->
    console.log json

    #$.each json, (count, item) ->
    #  console.log item["query_key"]
    #  console.log item["DMS_count"]
    #  console.log "=========================="

    #testJSON = '[{"query_date":"2015-07-02", "DMS_count":2, "DMS_List":["DMS06355888", "DMS06423265"]},{"query_date":"2015-07-02", "DMS_count":2, "DMS_List":["DMS06355888", "DMS06423265"]},{"query_date":"2015-07-05", "DMS_count":3, "DMS_List":["DMS06355888", "DMS06423265", "DMS06423277"]},{"query_date":"2015-07-07", "DMS_count":3, "DMS_List":["DMS06355888", "DMS06423277"]},{"query_date":"2015-07-07", "DMS_count":3, "DMS_List":["DMS06355888", "DMS06423277"]}]'
    highChartObject = new HighChartObjects(json)

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
      originalJSON = _removeDuplicateItems.call @, originalJSON
      originalJSON = _complimentDate.call @, originalJSON
      _createChartElement.call @, originalJSON

      #console.log originalJSON
      #console.log "Date: #{@chartDateArray}"
      #console.log "TTL#: #{@chartNumOfTotalDMSArray}"
      #console.log "New#: #{@chartNumOfNewDMSArray}"
      #console.log "Fix#: #{@chartNumOfFixedDMSArray}"
    else
      console.log "there is no data.."

  ## @private class
  _removeDuplicateItems = (originalJSON)->
    duplicateRemovedJSON = []
    originalJSON.sort (a,b) ->
      if a["query_date"] < b["query_date"]
        return -1
      if a["query_date"] > b["query_date"]
        return 1

    for item, count in originalJSON
      if count !=  originalJSON.length - 1
        if originalJSON[count]["query_date"] != originalJSON[count+1]["query_date"]
          duplicateRemovedJSON.push(item)
      else
        duplicateRemovedJSON.push(item)
    return duplicateRemovedJSON

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
