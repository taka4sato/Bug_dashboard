var startpoint_dashboard_burndown;

startpoint_dashboard_burndown = function(queryKey) {
  var targetURL;
  $("#Page_Title").append("<span class=\"underline\">" + decodeURIComponent(queryKey) + "</span>");
  targetURL = window.location.protocol + "//" + window.location.host + "/v1/daily_count?query_key=" + queryKey + "&format=json";
  return $.getJSON(targetURL, function(json) {
    var DMSChartDate, DMSChartFixedItem, DMSChartNewItem, DMSChartTotalItem;
    console.log(json);
    $.each(json, function(count, item) {
      console.log(item["query_key"]);
      console.log(item["DMS_count"]);
      console.log(item["query_date"]);
      return console.log("==========================");
    });
    DMSChartDate = ["6/26", "6/27", "6/28", "6/29", "6/30", "7/1", "7/2"];
    DMSChartTotalItem = [22, 22, 22, 22, 22, 22, 22];
    DMSChartNewItem = [0, 0, 0, 0, 0, 0, 0];
    DMSChartFixedItem = [0, 0, 0, 0, 0, 0, 0];
    $('#chart_placeholder').highcharts({
      chart: {
        type: 'line'
      },
      title: {
        text: 'DMS burndown chart'
      },
      xAxis: {
        categories: DMSChartDate
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
          data: DMSChartTotalItem
        }, {
          yAxis: 0,
          name: 'New DMS #',
          data: DMSChartNewItem
        }, {
          yAxis: 0,
          name: 'Fixed DMS #',
          data: DMSChartFixedItem
        }
      ]
    });
  });
};
