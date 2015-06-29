var addDetailTagInfo, countTag, createTable, escapeHTML, highlightDate, optimezeTitleLength, startpoint_dashboard_query, timeAgoInWords, timeDelta;

startpoint_dashboard_query = function(queryKey) {
  var targetURL;
  $("#Page_Title").append("<span class=\"underline\">" + decodeURIComponent(queryKey) + "</span>");
  targetURL = window.location.protocol + "//" + window.location.host + "/v1/query?query_key=" + queryKey + "&format=json";
  return $.getJSON(targetURL, function(json) {
    var targetURL_tagInfo;
    targetURL_tagInfo = window.location.protocol + "//" + window.location.host + "/tag_date/tag_info.json";
    return $.getJSON(targetURL_tagInfo, function(tag_date_info) {
      return createTable(json, tag_date_info);
    });
  });
};

createTable = function(json, tag_date_info) {
  var colvis, delta_time, dms_Table;
  if (json.length !== 0 && json[0].hasOwnProperty("query_date")) {
    delta_time = timeAgoInWords(Date.parse(String(json[0].query_date).replace(/-/g, "/")), 1);
    $("#DMS_update_time").append("(Query result as of <span class=\"underline\"><b>" + delta_time + "</b></span>)");
    $("#return_to_list_URL").append("<a href='" + window.location.protocol + "//" + window.location.host + "/v1/list'> back to Query List </a>");
    if (json[0].DMS_count === 0) {
      return $("#footer_comment").append("<b>No DMS exists</b> for this query");
    } else {
      console.log(json);
      console.log(json[0]["query_key"]);
      $.each(json[0].DMS_List, function(i, item) {});
      $("#table_placeholder").html("<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" class=\"display responsive\" id=\"DMS_Table\"></table>");
      dms_Table = $("#DMS_Table").DataTable({
        data: json[0].DMS_List,
        pageLength: 100,
        autoWidth: false,
        bStateSave: true,
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
            data: "State",
            title: "State",
            width: "60px"
          }, {
            data: "IssueType",
            title: "Type",
            width: "60px"
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
            targets: [5],
            render: function(data, type, row, meta) {
              if (type === "display") {
                return countTag(data, meta);
              }
            }
          }, {
            targets: [6, 7],
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
      $('#DMS_Table tbody').on('click', 'div.details-control', function() {
        var row, tr;
        tr = $(this).closest('tr');
        row = dms_Table.row(tr);
        if (row.child.isShown()) {
          row.child.hide();
          return tr.removeClass('shown');
        } else {
          row.child(addDetailTagInfo(row.data(), tag_date_info)).show();
          return tr.addClass('shown');
        }
      });
      $("#DMS_Table_filter").prepend("<span><button type='button' id='covlis_button' class='btn btn-default'>show hide column</button></span>");
      colvis = new $.fn.dataTable.ColVis(dms_Table, {
        exclude: [0, 1],
        bCssPosition: true
      });
      $('#covlis_button').on('click', function(e) {
        var pos, target;
        e.preventDefault();
        pos = {};
        target = $(this);
        pos.x = target.offset().left;
        pos.y = target.offset().top + target.outerHeight();
        $(colvis.dom.collection).css({
          position: 'absolute',
          left: pos.x,
          top: pos.y
        });
        return colvis._fnCollectionShow();
      });
      $("#DMS_Table_filter").prepend("<span><button type='button' id='burndown_button' class='btn btn-default'>show Burndown Chart</button></span>");
      return $('#burndown_button').on('click', function(e) {
        var dashboard_URL;
        dashboard_URL = window.location.protocol + "//" + window.location.host + "/v1/daily_count?query_key=" + encodeURIComponent(json[0]["query_key"]);
        return location.href = dashboard_URL;
      });
    }
  } else {
    return $("#DMS_update_time").append("<b>Error!</b> Fail to load query result");
  }
};

countTag = function(tag_info, meta_info) {
  var count;
  if ($.isEmptyObject(tag_info["Tag_info"])) {
    return "";
  } else {
    count = 0;
    $.each(tag_info["Tag_info"], function(i, item) {
      return count = i;
    });
    count = count + 1;
    if (count === 1) {
      return "<div class='details-control'><img border='0' src='../images/empty.gif'> </img></div>";
    } else {
      return "<div class='details-control'><img border='0' src='../images/empty.gif'>" + count + "</img></div>";
    }
  }
};

addDetailTagInfo = function(tag_info, tag_date_info) {
  var tag_string;
  tag_string = "";
  $.each(tag_info["Tag_info"], function(i, item_tag_info) {
    var tag_deadline;
    console.log(item_tag_info);
    if (item_tag_info["Tag"] === "Fix ASAP") {
      console.log;
      return tag_string += "<tr><td>" + item_tag_info["DeliveryBranch"] + "</td><td>" + item_tag_info["Tag"] + "</td><td bgcolor='#FF0000'>ASAP</td></tr>";
    } else {
      tag_deadline = "";
      $.each(tag_date_info["Tag_item"], function(i, item_date_info) {
        if (item_date_info["Tag_branch"] === item_tag_info["DeliveryBranch"] && item_date_info["Tag_name"] === item_tag_info["Tag"]) {
          return tag_deadline = item_date_info["Tag_deadline"];
        }
      });
      return tag_string += "<tr><td>" + item_tag_info["DeliveryBranch"] + "</td><td>" + item_tag_info["Tag"] + "</td><td>" + tag_deadline + "</td></tr>";
    }
  });
  return '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">' + '<tr><td>Tag Branch:</td><td>Tag Target</td><td>Deadline</td></tr>' + tag_string + '</table>';
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
