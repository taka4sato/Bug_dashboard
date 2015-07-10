var HighChartObjects, startpoint_dashboard_burndown;

startpoint_dashboard_burndown = function(queryKey, chartDuration) {
  var targetURL;
  $("#Page_Title").append("<span class=\"underline\">" + decodeURIComponent(queryKey) + "</span>");
  targetURL = window.location.protocol + "//" + window.location.host + "/v1/daily_count?query_key=" + queryKey + "&format=json&query_duration=" + chartDuration;
  return $.getJSON(targetURL, function(json) {
    var highChartObject;
    console.log(json);
    highChartObject = new HighChartObjects(json);
    $('#chart_placeholder').highcharts({
      chart: {
        type: 'column'
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
        },
        stackLabels: {
          enabled: true,
          style: {
            fontWeight: 'bold',
            color: Highcharts.theme && Highcharts.theme.textColor || 'black'
          }
        }
      },
      legend: {
        align: 'right',
        x: -30,
        verticalAlign: 'top',
        y: 25,
        floating: true,
        backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
        borderColor: '#CCC',
        borderWidth: 1,
        shadow: false
      },
      navigation: {
        buttonOptions: {
          enabled: true
        }
      },
      credits: {
        enabled: false
      },
      plotOptions: {
        column: {
          stacking: 'normal',
          dataLabels: {
            enabled: true
          },
          enableMouseTracking: false
        }
      },
      series: [
        {
          name: 'Remaining DMS #',
          data: highChartObject.chartNumOfTotalDMS_NewDMSArray,
          stack: 'ActiveIssues'
        }, {
          name: 'New DMS #',
          data: highChartObject.chartNumOfNewDMSArray,
          stack: 'ActiveIssues'
        }, {
          name: 'Fixed or Transferred DMS #',
          data: highChartObject.chartNumOfFixedDMSArray,
          stack: 'InactiveIssues'
        }
      ]
    });
  });
};

HighChartObjects = (function() {
  var expectedDuration, originalJSON, timezoneOffset, _compareDMSList, _complimentDate, _createChartElement, _removeDuplicateItems;

  originalJSON = "";

  timezoneOffset = (new Date).getTimezoneOffset();

  expectedDuration = 1000 * 3600 * 24;

  HighChartObjects.prototype.chartDateArray = [];

  HighChartObjects.prototype.chartNumOfTotalDMSArray = [];

  HighChartObjects.prototype.chartNumOfNewDMSArray = [];

  HighChartObjects.prototype.chartNumOfFixedDMSArray = [];

  HighChartObjects.prototype.chartNumOfTotalDMS_NewDMSArray = [];

  function HighChartObjects(json) {
    if ($.isEmptyObject(json) !== true) {
      originalJSON = json;
      originalJSON = _removeDuplicateItems.call(this, originalJSON);
      originalJSON = _complimentDate.call(this, originalJSON);
      _createChartElement.call(this, originalJSON);
    } else {
      console.log("there is no data..");
    }
    return;
  }

  _removeDuplicateItems = function(originalJSON) {
    var count, duplicateRemovedJSON, item, _i, _len;
    duplicateRemovedJSON = [];
    originalJSON.sort(function(a, b) {
      if (a["query_date"] < b["query_date"]) {
        return -1;
      }
      if (a["query_date"] > b["query_date"]) {
        return 1;
      }
    });
    for (count = _i = 0, _len = originalJSON.length; _i < _len; count = ++_i) {
      item = originalJSON[count];
      if (count !== originalJSON.length - 1) {
        if (originalJSON[count]["query_date"] !== originalJSON[count + 1]["query_date"]) {
          duplicateRemovedJSON.push(item);
        }
      } else {
        duplicateRemovedJSON.push(item);
      }
    }
    return duplicateRemovedJSON;
  };

  _createChartElement = function(originalJSON) {
    var TotalMinusNewDMS, count, item, numOfNewFixedItem, _i, _j, _len, _len1, _ref, _results;
    for (count = _i = 0, _len = originalJSON.length; _i < _len; count = ++_i) {
      item = originalJSON[count];
      this.chartDateArray.push(item["query_date"]);
      this.chartNumOfTotalDMSArray.push(item["DMS_List"].length);
      if (originalJSON.length === 1 || count === 0) {
        this.chartNumOfNewDMSArray.push(0);
        this.chartNumOfFixedDMSArray.push(0);
      } else {
        numOfNewFixedItem = _compareDMSList.call(this, originalJSON[count - 1]["DMS_List"], originalJSON[count]["DMS_List"]);
        this.chartNumOfFixedDMSArray.push(numOfNewFixedItem[1]);
        this.chartNumOfNewDMSArray.push(numOfNewFixedItem[0]);
      }
    }
    _ref = this.chartNumOfTotalDMSArray;
    _results = [];
    for (count = _j = 0, _len1 = _ref.length; _j < _len1; count = ++_j) {
      item = _ref[count];
      TotalMinusNewDMS = this.chartNumOfTotalDMSArray[count] - this.chartNumOfNewDMSArray[count];
      _results.push(this.chartNumOfTotalDMS_NewDMSArray.push(TotalMinusNewDMS));
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
