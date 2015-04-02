var createTable, escapeHTML, startpoint_dashboard_query, timeAgoInWords;

startpoint_dashboard_query = function(queryKey) {
  var targetURL;
  $("#Page_Title").append("<span class=\"underline\">" + decodeURIComponent(queryKey) + "</span>");
  targetURL = window.location.protocol + "//" + window.location.host + "/v1/query?query_key=" + queryKey + "&format=json";
  console.log(targetURL);
  return $.getJSON(targetURL, function(json) {
    console.log(json);
    return createTable(json, queryKey);
  });
};

createTable = function(json, queryKey) {
  var delta_time, output_json;
  if (json.length !== 0 && json[0].hasOwnProperty("query_date")) {
    delta_time = timeAgoInWords(Date.parse(String(json[0].query_date).replace(/-/g, "/")));
    $("#DMS_update_time").append("(Query result as of <span class=\"underline\"><b>" + delta_time + "</b></span>)");
    if (json[0].DMS_count === 0) {
      return $("#footer_comment").append("<b>No DMS exists</b> for this query");
    } else {
      output_json = [];
      $.each(json[0].DMS_List, function(i, item) {
        var DMS_URL, DMS_title, temp_array;
        console.log(item);
        temp_array = [];
        DMS_URL = "<a href=\"http://ffs.sonyericsson.net/WebPages/Search.aspx?q=1___" + item["DMS_ID"] + "___issue\" TARGET=\"_blank\">" + item["DMS_ID"] + "</a>";
        DMS_title = escapeHTML(item["Title"]);
        if (item["Title"].length > 80) {
          DMS_title = DMS_title.substr(0, 120) + "...";
        }
        timeAgoInWords(Date.parse(item["Modified_date"].replace(/-/g, "/")));
        temp_array.push(DMS_URL);
        temp_array.push(DMS_title);
        temp_array.push(item["Component"]);
        temp_array.push(timeAgoInWords(Date.parse(item["Modified_date"].replace(/-/g, "/"))));
        temp_array.push(timeAgoInWords(Date.parse(item["Submit_date"].replace(/-/g, "/"))));
        return output_json.push(temp_array);
      });
      $("#table_placeholder").html("<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" class=\"display responsive\" id=\"DMS_Table\"></table>");
      return $("#DMS_Table").dataTable({
        data: output_json,
        pageLength: 50,
        autoWidth: false,
        columns: [
          {
            title: "DMS_ID",
            width: "20px"
          }, {
            title: "Title"
          }, {
            title: "Component",
            width: "80px"
          }, {
            title: "Last Modified",
            width: "60px"
          }, {
            title: "Submit Date",
            width: "60px"
          }
        ]
      });
    }
  } else {
    return $("#DMS_update_time").append("<b>Error!</b> Fail to load query result");
  }
};

escapeHTML = function(text) {
  var replacement;
  replacement = function(ch) {
    var characterReference;
    characterReference = {
      "\"": "&quot;",
      "&": "&amp;",
      "'": "&#39;",
      "<": "&lt;",
      ">": "&gt;"
    };
    return characterReference[ch];
  };
  return text.replace(/["&'<>]/g, replacement);
};

timeAgoInWords = function(date) {
  var dateTime, diff, e, now, str;
  try {
    now = Math.ceil(Number(new Date()) / 1000);
    dateTime = Math.ceil(Number(new Date(date)) / 1000);
    diff = now - dateTime;
    str = void 0;
    if (diff < 60 * 60) {
      str = String(Math.ceil(diff / 60.));
      return str + (str === "1" ? " minute" : " minutes") + " ago";
    } else if (diff < 60 * 60 * 24) {
      str = String(Math.ceil(diff / (60 * 60)));
      return str + (str === "1" ? " hour" : " hours") + " ago";
    } else if (diff < 60 * 60 * 24 * 31) {
      str = String(Math.ceil(diff / (60 * 60 * 24)));
      return str + (str === "1" ? " day" : " days") + " ago";
    } else if (diff < 60 * 60 * 24 * 365) {
      str = String(Math.ceil(diff / (60 * 60 * 24 * 31)));
      return str + (str === "1" ? " month" : " months") + " ago";
    } else {
      str = String(Math.ceil(diff / (60 * 60 * 24 * 365) - 1.0));
      return str + (str === "1" ? " year" : " years") + " ago";
    }
  } catch (_error) {
    e = _error;
    return "";
  }
};
