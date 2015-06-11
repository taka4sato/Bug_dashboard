var createTable, escapeHTML, highlightDate, startpoint_dashboard_query, timeAgoInWords, timeDelta;

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
    delta_time = timeAgoInWords(Date.parse(String(json[0].query_date).replace(/-/g, "/")), 1);
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
        temp_array.push(DMS_URL);
        temp_array.push(DMS_title);
        temp_array.push(item["Component"]);
        temp_array.push(item["Modified_date"]);
        temp_array.push(item["Submit_date"]);
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
        ],
        columnDefs: [
          {
            targets: 3,
            render: function(data, type, row) {
              return highlightDate(data);
            }
          }, {
            targets: 4,
            render: function(data, type, row) {
              return highlightDate(data);
            }
          }
        ]
      });
    }
  } else {
    return $("#DMS_update_time").append("<b>Error!</b> Fail to load query result");
  }
};

highlightDate = function(text_string) {
  var timeDiff, timeString;
  timeDiff = timeDelta(Date.parse(text_string.replace(/-/g, "/")));
  timeString = timeAgoInWords(Date.parse(text_string.replace(/-/g, "/")), 0);
  if (timeDiff < 60 * 60 * 24 * 31 * 3) {
    return '<font color="#ff0000"><b>' + timeString + '</b></font>';
  } else {
    return timeString;
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

timeDelta = function(date) {
  var dateTime, e, now;
  try {
    now = Math.ceil(Number(new Date().getTime()) / 1000);
    dateTime = Math.ceil(Number(new Date(date)) / 1000);
    return now - dateTime;
  } catch (_error) {
    e = _error;
    return "";
  }
};

timeAgoInWords = function(date, flag) {
  var diff, e, str;
  try {
    diff = timeDelta(date);
    str = void 0;
    if (diff < 60 * 60) {
      str = String(Math.floor(diff / 60.));
      return (flag === 1 ? str + " minutes ago" : "less than one hour");
    } else if (diff < 60 * 60 * 24) {
      str = String(Math.floor(diff / (60 * 60)));
      return (flag === 1 ? str + (str === "1" ? " hour" : " hours") + " ago" : "less than one day");
    } else if (diff < 60 * 60 * 24 * 31) {
      str = String(Math.floor(diff / (60 * 60 * 24)));
      return str + (str === "1" ? " day" : " days") + " ago";
    } else if (diff < 60 * 60 * 24 * 365) {
      str = String(Math.floor(diff / (60 * 60 * 24 * 31)));
      return str + (str === "1" ? " month" : " months") + " ago";
    } else {
      str = String(Math.floor(diff / (60 * 60 * 24 * 365) - 1.0));
      return str + (str === "1" ? " year" : " years") + " ago";
    }
  } catch (_error) {
    e = _error;
    return "";
  }
};
