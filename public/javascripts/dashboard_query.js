var addDetailTagInfo, countTag, createTable, escapeHTML, highlightDate, optimezeTitleLength, startpoint_dashboard_query, timeAgoInWords, timeDelta;

startpoint_dashboard_query = function(queryKey) {
  var targetURL;
  $("#Page_Title").append("<span class=\"underline\">" + decodeURIComponent(queryKey) + "</span>");
  targetURL = window.location.protocol + "//" + window.location.host + "/v1/query?query_key=" + queryKey + "&format=json";
  console.log(targetURL);
  return $.getJSON(targetURL, function(json) {
    return createTable(json, queryKey);
  });
};

createTable = function(json, queryKey) {
  var delta_time, dms_Table;
  if (json.length !== 0 && json[0].hasOwnProperty("query_date")) {
    delta_time = timeAgoInWords(Date.parse(String(json[0].query_date).replace(/-/g, "/")), 1);
    $("#DMS_update_time").append("(Query result as of <span class=\"underline\"><b>" + delta_time + "</b></span>)");
    if (json[0].DMS_count === 0) {
      return $("#footer_comment").append("<b>No DMS exists</b> for this query");
    } else {
      $("#table_placeholder").html("<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" class=\"display responsive\" id=\"DMS_Table\"></table>");
      dms_Table = $("#DMS_Table").DataTable({
        data: json[0].DMS_List,
        pageLength: 100,
        autoWidth: false,
        order: [[4, "desc"]],
        columns: [
          {
            data: "DMS_ID",
            title: "DMS_ID",
            width: "20px"
          }, {
            data: "Title",
            title: "Title"
          }, {
            data: "Component",
            title: "Component",
            width: "80px"
          }, {
            data: null,
            title: "Tag",
            width: "5px",
            orderable: false,
            defaultContent: ''
          }, {
            data: "Modified_date",
            title: "Last Modified",
            width: "80px"
          }, {
            data: "Submit_date",
            title: "Submit Date",
            width: "80px"
          }
        ],
        columnDefs: [
          {
            targets: [0],
            render: function(data, type, row) {
              return "<a href=\"http://ffs.sonyericsson.net/WebPages/Search.aspx?q=1___" + data + "___issue\" TARGET=\"_blank\">" + data + "</a>";
            }
          }, {
            targets: [1],
            render: function(data, type, row) {
              return optimezeTitleLength(data);
            }
          }, {
            targets: [3],
            render: function(data, type, row, meta) {
              if (type === "display") {
                return countTag(data, meta);
              }
            }
          }, {
            targets: [4, 5],
            render: function(data, type, row) {
              if (type === "sort") {
                return Date.parse(data.replace(/-/g, "/"));
              } else {
                return highlightDate(data);
              }
            }
          }
        ]
      });
      return $('#DMS_Table tbody').on('click', 'div.details-control', function() {
        var row, tr;
        tr = $(this).closest('tr');
        row = dms_Table.row(tr);
        if (row.child.isShown()) {
          row.child.hide();
          return tr.removeClass('shown');
        } else {
          row.child(addDetailTagInfo(row.data())).show();
          return tr.addClass('shown');
        }
      });
    }
  } else {
    return $("#DMS_update_time").append("<b>Error!</b> Fail to load query result");
  }
};

countTag = function(tag_info, meta_info) {
  console.log("------------");
  console.log(tag_info);
  console.log(meta_info);
  if ($.isEmptyObject(tag_info["Tag_info"])) {
    console.log("------------");
    return "";
  } else {
    console.log(tag_info["Tag_info"][0]);
    console.log("------------");
    return "<div class='details-control'><img border='0' src='../images/empty.gif'> </img></div>";
  }
};

addDetailTagInfo = function(row_data) {
  console.log(row_data);
  return '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">' + '<tr>' + '<td>Full name:</td>' + '<td>' + row_data.Project + '</td>' + '</tr>' + '<tr>' + '<td>Extension number:</td>' + '<td>' + row_data.State + '</td>' + '</tr>' + '<tr>' + '<td>Extra info:</td>' + '<td>And any further details here (images etc)...</td>' + '</tr>' + '</table>';
};

optimezeTitleLength = function(text_string) {
  var escapted_Title;
  escapted_Title = escapeHTML(text_string);
  if (text_string.length > 80) {
    return escapted_Title.substr(0, 120) + "...";
  } else {
    return escapted_Title;
  }
};

highlightDate = function(text_string) {
  var timeDiff, timeString;
  timeDiff = timeDelta(Date.parse(text_string.replace(/-/g, "/")));
  timeString = timeAgoInWords(Date.parse(text_string.replace(/-/g, "/")), 0);
  if (timeDiff < 60 * 60 * 24) {
    return '<font color="red"><b>' + timeString + '</b></font>';
  } else if (timeDiff < 60 * 60 * 24 * 3) {
    return '<font color="purple"><b>' + timeString + '</b></font>';
  } else if (timeDiff < 60 * 60 * 24 * 31) {
    return '<font color="blue"><b>' + timeString + '</b></font>';
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
      return (flag === 1 ? str + " minutes ago" : "< 1h");
    } else if (diff < 60 * 60 * 24) {
      str = String(Math.floor(diff / (60 * 60)));
      return (flag === 1 ? str + (str === "1" ? " hour" : " hours") + " ago" : "< 24h");
    } else if (diff < 60 * 60 * 24 * 31) {
      str = String(Math.floor(diff / (60 * 60 * 24)));
      return str + (str === "1" ? " day" : " days") + " ago";
    } else if (diff < 60 * 60 * 24 * 365) {
      str = String(Math.floor(diff / (60 * 60 * 24 * 31)));
      return str + (str === "1" ? " month" : " months") + " ago";
    } else {
      str = String(Math.floor(diff / (60 * 60 * 24 * 365)));
      return str + (str === "1" ? " year" : " years") + " ago";
    }
  } catch (_error) {
    e = _error;
    return "";
  }
};
