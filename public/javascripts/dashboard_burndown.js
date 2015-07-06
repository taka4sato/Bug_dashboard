var HighChartObjects, startpoint_dashboard_burndown;

startpoint_dashboard_burndown = function(queryKey) {
  var targetURL;
  $("#Page_Title").append("<span class=\"underline\">" + decodeURIComponent(queryKey) + "</span>");
  targetURL = window.location.protocol + "//" + window.location.host + "/v1/daily_count?query_key=" + queryKey + "&format=json";
  return $.getJSON(targetURL, function(json) {
    var highChartObject, testJSON;
    console.log(json);
    $.each(json, function(count, item) {
      console.log(item["query_key"]);
      console.log(item["DMS_count"]);
      console.log(item["query_date"]);
      return console.log("==========================");
    });
    testJSON = '[{"query_date":"2015-07-02", "DMS_count":2, "DMS_List":["DMS06355888", "DMS06423265"]},{"query_date":"2015-07-05", "DMS_count":3, "DMS_List":["DMS06355888", "DMS06423265", "DMS06423277"]},{"query_date":"2015-07-07", "DMS_count":3, "DMS_List":["DMS06355888", "DMS06423277"]}]';
    highChartObject = new HighChartObjects(testJSON);
    $('#chart_placeholder').highcharts({
      chart: {
        type: 'line'
      },
      title: {
        text: 'DMS burndown chart'
      },
      xAxis: {
        categories: highChartObject.chartDateArray
      },
      yAxis: {
        min: 0,
        title: {
          text: '# of DMS'
        }
      },
      tooltip: {
        shared: true
      },
      navigation: {
        buttonOptions: {
          enabled: true
        }
      },
      exporting: {
        enabled: true,
        type: 'image/jpeg',
        scale: 2
      },
      credits: {
        enabled: false
      },
      plotOptions: {
        line: {
          dataLabels: {
            enabled: true
          },
          enableMouseTracking: false
        }
      },
      series: [
        {
          yAxis: 0,
          name: 'Total DMS #',
          data: highChartObject.chartNumOfTotalDMSArray
        }, {
          yAxis: 0,
          name: 'New DMS #',
          data: highChartObject.chartNumOfNewDMSArray
        }, {
          yAxis: 0,
          name: 'Fixed DMS #',
          data: highChartObject.chartNumOfFixedDMSArray
        }
      ]
    });
  });
};

HighChartObjects = (function() {
  var expectedDuration, originalJSON, timezoneOffset, _compareDMSList, _complimentDate, _createChartElement;

  originalJSON = "";

  timezoneOffset = (new Date).getTimezoneOffset();

  expectedDuration = 1000 * 3600 * 24;

  HighChartObjects.prototype.chartDateArray = [];

  HighChartObjects.prototype.chartNumOfTotalDMSArray = [];

  HighChartObjects.prototype.chartNumOfNewDMSArray = [];

  HighChartObjects.prototype.chartNumOfFixedDMSArray = [];

  function HighChartObjects(json) {
    if ($.isEmptyObject(JSON.parse(json)) !== true) {
      originalJSON = JSON.parse(json);
      originalJSON = _complimentDate.call(this, originalJSON);
      _createChartElement.call(this, originalJSON);
      console.log(originalJSON);
      console.log("Date: " + this.chartDateArray);
      console.log("TTL#: " + this.chartNumOfTotalDMSArray);
      console.log("New#: " + this.chartNumOfNewDMSArray);
      console.log("Fix#: " + this.chartNumOfFixedDMSArray);
    } else {
      console.log("there is no data..");
    }
  }

  _createChartElement = function(originalJSON) {
    var count, item, numOfNewFixedItem, _i, _len, _results;
    _results = [];
    for (count = _i = 0, _len = originalJSON.length; _i < _len; count = ++_i) {
      item = originalJSON[count];
      this.chartDateArray.push(item["query_date"]);
      this.chartNumOfTotalDMSArray.push(item["DMS_List"].length);
      if (originalJSON.length === 1 || count === 0) {
        this.chartNumOfNewDMSArray.push(0);
        _results.push(this.chartNumOfFixedDMSArray.push(0));
      } else {
        numOfNewFixedItem = _compareDMSList.call(this, originalJSON[count - 1]["DMS_List"], originalJSON[count]["DMS_List"]);
        this.chartNumOfFixedDMSArray.push(numOfNewFixedItem[1]);
        _results.push(this.chartNumOfNewDMSArray.push(numOfNewFixedItem[0]));
      }
    }
    return _results;
  };

  _compareDMSList = function(originalList, targetList) {
    var item, numOfFixedItem, numOfNewItem, _i, _j, _len, _len1;
    numOfNewItem = 0;
    numOfFixedItem = 0;
    for (_i = 0, _len = originalList.length; _i < _len; _i++) {
      item = originalList[_i];
      if (targetList.indexOf(item) === -1) {
        numOfFixedItem++;
      }
    }
    for (_j = 0, _len1 = targetList.length; _j < _len1; _j++) {
      item = targetList[_j];
      if (originalList.indexOf(item) === -1) {
        numOfNewItem++;
      }
    }
    return [numOfNewItem, numOfFixedItem];
  };

  _complimentDate = function(originalJSON) {
    var complimentaryJSON, complimentaryJSONTemp, count, delta, i, item, momentDate, momentDateNext, _i, _j, _len, _len1;
    complimentaryJSON = [];
    for (count = _i = 0, _len = originalJSON.length; _i < _len; count = ++_i) {
      item = originalJSON[count];
      momentDate = moment(item["query_date"], "YYYY-MM-DD").utc().subtract(timezoneOffset, "m");
      if (count !== originalJSON.length - 1) {
        momentDateNext = moment(originalJSON[count + 1]["query_date"], "YYYY-MM-DD").utc().subtract(timezoneOffset, "m");
        delta = momentDateNext.diff(momentDate) / expectedDuration;
        if (delta !== 1) {
          i = 1;
          while (i < delta) {
            complimentaryJSONTemp = JSON.parse(JSON.stringify(item));
            complimentaryJSONTemp["query_date"] = momentDate.add(1, "d").format("YYYY-MM-DD");
            complimentaryJSON.push(complimentaryJSONTemp);
            i++;
          }
        }
      }
    }
    for (_j = 0, _len1 = complimentaryJSON.length; _j < _len1; _j++) {
      item = complimentaryJSON[_j];
      originalJSON.push(item);
    }
    originalJSON.sort(function(a, b) {
      if (a["query_date"] < b["query_date"]) {
        return -1;
      }
      if (a["query_date"] > b["query_date"]) {
        return 1;
      }
    });
    return originalJSON;
  };

  return HighChartObjects;

})();
