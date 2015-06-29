var startpoint_dashboard_burndown;

startpoint_dashboard_burndown = function(queryKey) {
  var targetURL;
  $("#Page_Title").append("<span class=\"underline\">" + decodeURIComponent(queryKey) + "</span>");
  targetURL = window.location.protocol + "//" + window.location.host + "/v1/daily_count?query_key=" + queryKey + "&format=json";
  return $.getJSON(targetURL, function(json) {
    console.log(json);
    return $.each(json, function(count, item) {
      console.log(item["query_key"]);
      console.log(item["DMS_count"]);
      console.log(item["query_date"]);
      return console.log("==========================");
    });
  });
};
