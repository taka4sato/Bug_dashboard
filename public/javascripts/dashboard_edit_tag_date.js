var addItem_click_callback, check_original_date, create_TagList, deleteItem_click_callback, global_tag_info, global_tag_info_del, global_tag_info_new, global_tag_info_orig, init_Buttons, reset_UIParts, selectMenuOnchange, select_input, sort_tag_info, startpoint_dashboard_edit_tag_date, submit_click_callback, submit_deleteMode_click_callback, update_page, update_tag_date_info;

global_tag_info = "";

global_tag_info_new = "";

global_tag_info_orig = "";

global_tag_info_del = "";

startpoint_dashboard_edit_tag_date = function() {
  var targetURL;
  targetURL = window.location.protocol + "//" + window.location.host + "/tag_date/tag_info.json";
  return $.getJSON(targetURL, function(tag_info) {
    return create_TagList(tag_info);
  });
};

create_TagList = function(tag_info) {
  var previous_BranchName;
  global_tag_info = JSON.parse(JSON.stringify(tag_info));
  global_tag_info_new = JSON.parse(JSON.stringify(tag_info));
  global_tag_info_orig = JSON.parse(JSON.stringify(tag_info));
  global_tag_info_del = JSON.parse(JSON.stringify(tag_info));
  $("#tag_Header").append("<span class='buffer_forCheckbox'></span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:250px' class='list_header'>Branch Name</span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:145px' class='list_header'>Tag Name</span><span style='width:100px' class='list_header'>Active?</span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:150px' class='list_header'>Deadline</span><br>");
  sort_tag_info(global_tag_info);
  previous_BranchName = "";
  $.each(global_tag_info["Tag_item"], function(i, item) {
    var isActive;
    if (item["Tag_active"] === "True") {
      isActive = "<select name='" + item["Tag_branch"] + "," + item["Tag_name"] + "' onchange='selectMenuOnchange(this)'><option value='True' selected>Yes</option><option value='False'>No</option></select>";
    } else {
      isActive = "<select name='" + item["Tag_branch"] + "," + item["Tag_name"] + "' onchange='selectMenuOnchange(this)' style='background: #D8D8D8;'><option value='True'>Yes</option><option value='False' selected>No</option></select>";
    }
    if (item["Tag_branch"] === previous_BranchName) {
      $("#tag_Info").append("<span onclick='select_input(this);' ondblclick='select_input(this);' style='width:250px'></span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:150px'>" + item["Tag_name"] + "</span><span style='width:100px'>" + isActive + "</span><input type='text' align='center' style='width:150px' name='" + item["Tag_branch"] + item["Tag_name"] + "' value='" + item["Tag_deadline"] + "' /><br>");
    } else {
      $("#tag_Info").append("<span onclick='select_input(this);' ondblclick='select_input(this);' style='width:250px'>" + item["Tag_branch"] + "</span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:150px'>" + item["Tag_name"] + "</span><span style='width:100px'>" + isActive + "</span><input type='text' align='center' style='width:150px' name='" + item["Tag_branch"] + item["Tag_name"] + "' value='" + item["Tag_deadline"] + "' /><br>");
    }
    previous_BranchName = item["Tag_branch"];
    return $("input[name='" + item["Tag_branch"] + item["Tag_name"] + "']").daterangepicker({
      singleDatePicker: true,
      showDropdowns: true,
      showWeekNumbers: true,
      minDate: "2014/01/01",
      format: "YYYY-MM-DD"
    }, function(start, end, label) {
      var original_date, this_text_input;
      original_date = check_original_date(item["Tag_branch"], item["Tag_name"]);
      update_tag_date_info(item["Tag_branch"], item["Tag_name"], start.format('YYYY-MM-DD'));
      this_text_input = $(":text[name=" + item["Tag_branch"] + item["Tag_name"] + "]");
      if (start.format("YYYY-MM-DD") !== original_date) {
        return this_text_input.css("backgroundColor", "yellow");
      } else {
        return this_text_input.css("backgroundColor", "white");
      }
    });
  });
  return init_Buttons(false);
};

deleteItem_click_callback = function(button_id) {
  var previous_BranchName;
  reset_UIParts();
  init_Buttons(true);
  $("#tag_Warn").replaceWith("<span id='tag_Warn' class='warn_message'>Detele mode, check items you wan to delete and click submit</span>");
  $("#tag_Header").append("<span class='buffer_forCheckbox'></span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:250px' class='list_header'>Branch Name</span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:145px' class='list_header'>Tag Name</span><span style='width:100px' class='list_header'>Active?</span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:150px' class='list_header'>Deadline</span><br>");
  sort_tag_info(global_tag_info_del);
  previous_BranchName = "";
  return $.each(global_tag_info_del["Tag_item"], function(i, item) {
    var isActive;
    if (item["Tag_branch"] === "False") {
      isActive = "Y";
    } else {
      isActive = "No";
    }
    if (item["Tag_branch"] === previous_BranchName) {
      $("#tag_Info").append("<div class='delete_item'><span class='delete_item_tagBranch' style='color:#D8D8D8; width:250px'>" + item["Tag_branch"] + "</span><span class='delete_item_tagName' style='width:150px'>" + item["Tag_name"] + "</span><span style='width:100px'>" + isActive + "</span><span  style='width:150px'>" + item["Tag_deadline"] + "</span><input type='checkbox' class='checkbox' style='display:inline'/></div>");
    } else {
      $("#tag_Info").append("<div class='delete_item'><span class='delete_item_tagBranch' style='width:250px'>" + item["Tag_branch"] + "</span><span class='delete_item_tagName' style='width:150px'>" + item["Tag_name"] + "</span><span style='width:100px'>" + isActive + "</span><span  style='width:150px'>" + item["Tag_deadline"] + "</span><input type='checkbox' class='checkbox' style='display:inline'/></div>");
    }
    return previous_BranchName = item["Tag_branch"];
  });
};

submit_deleteMode_click_callback = function(button_id) {
  $(".delete_item").each(function() {
    var delete_item_tag_branch, delete_item_tag_name;
    if ($(this).children(".checkbox").is(':checked') === true) {
      delete_item_tag_branch = $(this).children(".delete_item_tagBranch").text();
      delete_item_tag_name = $(this).children(".delete_item_tagName").text();
      return $.each(global_tag_info_del["Tag_item"], function(i, item) {
        if (item["Tag_branch"] === delete_item_tag_branch && item["Tag_name"] === delete_item_tag_name) {
          global_tag_info_del["Tag_item"].splice(i, 1);
          return false;
        }
      });
    }
  });
  button_id.attr("disabled", true);
  $.ajax({
    type: "post",
    url: window.location.protocol + "//" + window.location.host + "/v1/edit_tag_date",
    data: JSON.stringify(global_tag_info_del),
    contentType: "application/JSON",
    dataType: "JSON",
    scriptCharset: "utf-8",
    success: function(data) {
      return $("#tag_Warn").replaceWith("<span id='tag_Warn' class='warn_message'>Update success</span>");
    },
    error: function(data) {
      return $("#tag_Warn").replaceWith("<span id='tag_Warn' class='warn_message'>Update failed, please reload</span>");
    }
  });
  button_id.attr("disabled", false);
  return setTimeout(update_page, 3000);
};

addItem_click_callback = function(button_id) {
  var new_item_deadline;
  $("#tag_Info").prepend("<div class='new_item'><span><input style='width:230px' class='new_item_tagBranch' type='text'></span><span><input style='width:130px' class='new_item_tagName' type='text'></span><span><select class='new_item_ActiveFlag'><option value='True' selected>Yes</option><option value='False'>No</option></select></span><span><input style='width:150px' type='text' name='new_item_tagDate' value='' /></span></div>");
  new_item_deadline = $(":text[name=new_item_tagDate]");
  new_item_deadline.css("backgroundColor", "yellow");
  $(".new_item_tagBranch, .new_item_tagName, .new_item_ActiveFlag").css("backgroundColor", "yellow");
  return $("input[name='new_item_tagDate']").daterangepicker({
    singleDatePicker: true,
    showDropdowns: true,
    showWeekNumbers: true,
    minDate: "2014/01/01",
    format: "YYYY-MM-DD"
  });
};

check_original_date = function(target_tag_branch, target_tag_name) {
  var count;
  count = 0;
  console.log(global_tag_info_orig);
  $.each(global_tag_info_orig["Tag_item"], function(i, item) {
    if (item["Tag_branch"] === target_tag_branch && item["Tag_name"] === target_tag_name) {
      return count = i;
    }
  });
  return global_tag_info_orig["Tag_item"][count]["Tag_deadline"];
};

update_tag_date_info = function(target_tag_branch, target_tag_name, new_date) {
  return $.each(global_tag_info_new["Tag_item"], function(i, item) {
    if (item["Tag_branch"] === target_tag_branch && item["Tag_name"] === target_tag_name) {
      return item["Tag_deadline"] = new_date;
    }
  });
};

selectMenuOnchange = function(obj) {
  $.each($(obj).children('option'), function(i, item) {
    if (item.outerHTML.includes("selected") === true) {
      if (item["value"] === obj.options[obj.selectedIndex].value) {
        return $(obj).css("backgroundColor", "white");
      } else {
        return $(obj).css("backgroundColor", "yellow");
      }
    }
  });
  return $.each(global_tag_info_new["Tag_item"], function(i, item) {
    if (item["Tag_branch"] === obj.name.split(",")[0] && item["Tag_name"] === obj.name.split(",")[1]) {
      return item["Tag_active"] = obj.options[obj.selectedIndex].value;
    }
  });
};

submit_click_callback = function(button_id) {
  var all_new_item_array, proceedPOST_flag, temprary_array;
  button_id.attr("disabled", true);
  $("#tag_Warn").replaceWith("<span id='tag_Warn'></span>");
  proceedPOST_flag = 1;
  all_new_item_array = [];
  temprary_array = [];
  $(".new_item").each(function() {
    var all_new_item, new_active_flag, new_tag_branch, new_tag_date, new_tag_name;
    new_tag_branch = $(this).children("span").children(".new_item_tagBranch").val();
    new_tag_name = $(this).children("span").children(".new_item_tagName").val();
    new_active_flag = $(this).children("span").children(".new_item_ActiveFlag").val();
    new_tag_date = $(this).children("span").children(":text[name=new_item_tagDate]").val();
    all_new_item = [new_tag_branch, new_tag_name, new_active_flag, new_tag_date];
    return all_new_item_array.push(all_new_item);
  });
  $(".new_item").each(function() {
    var duplicate_count, isEmpty_flag, new_active_flag, new_item_array, new_tag_branch, new_tag_date, new_tag_name;
    new_tag_branch = $(this).children("span").children(".new_item_tagBranch").val();
    new_tag_name = $(this).children("span").children(".new_item_tagName").val();
    new_active_flag = $(this).children("span").children(".new_item_ActiveFlag").val();
    new_tag_date = $(this).children("span").children(":text[name=new_item_tagDate]").val();
    new_item_array = {
      Tag_branch: new_tag_branch,
      Tag_name: new_tag_name,
      Tag_active: new_active_flag,
      Tag_deadline: new_tag_date
    };
    isEmpty_flag = 0;
    if (new_tag_branch === "" && new_tag_name === "" && new_tag_date === "") {
      $(this).children("span").children(".new_item_tagBranch, .new_item_tagName, :text[name=new_item_tagDate]").css("backgroundColor", "#EEEEEE");
      $("#tag_Warn").replaceWith("<span id='tag_Warn'></span>");
      isEmpty_flag = 1;
    } else if (new_tag_branch === "" || new_tag_name === "" || new_tag_date === "") {
      $(this).children("span").children(".new_item_tagBranch, .new_item_tagName, :text[name=new_item_tagDate]").css("backgroundColor", "#FFE4E1");
      $("#tag_Warn").replaceWith("<span id='tag_Warn' class='warn_message'>Necessary field is blank</span>");
      proceedPOST_flag = 0;
    }
    duplicate_count = 0;
    $.each(all_new_item_array, function(i, item) {
      if (new_tag_branch === item[0] && new_tag_name === item[1]) {
        duplicate_count += 1;
      }
      if (duplicate_count > 1) {
        $("#tag_Warn").replaceWith("<span id='tag_Warn' class='warn_message'>Some of new items are duplicated</span>");
        $(this).children("span").children(".new_item_tagBranch, .new_item_tagName, :text[name=new_item_tagDate]").css("backgroundColor", "#FFE4E1");
        return proceedPOST_flag = 0;
      }
    });
    $.each(global_tag_info_orig["Tag_item"], function(i, item) {
      if (new_tag_branch === item["Tag_branch"] && new_tag_name === item["Tag_name"]) {
        $("#tag_Warn").replaceWith("<span id='tag_Warn' class='warn_message'>Some of new items are already exist</span>");
        $(this).children("span").children(".new_item_tagBranch, .new_item_tagName, :text[name=new_item_tagDate]").css("backgroundColor", "#FFE4E1");
        return proceedPOST_flag = 0;
      }
    });
    if (proceedPOST_flag === 1 && isEmpty_flag === 0) {
      return temprary_array.push(new_item_array);
    }
  });
  if (proceedPOST_flag === 1) {
    temprary_array.forEach(function(item) {
      global_tag_info_new["Tag_item"].push(item);
    });
    if (JSON.stringify(global_tag_info_new["Tag_item"]) === JSON.stringify(global_tag_info_orig["Tag_item"])) {
      $("#tag_Warn").replaceWith("<span id='tag_Warn' class='warn_message'>No new item exists</span>");
      return button_id.attr("disabled", false);
    } else {
      console.log("before ajax");
      return $.ajax({
        type: "post",
        url: window.location.protocol + "//" + window.location.host + "/v1/edit_tag_date",
        data: JSON.stringify(global_tag_info_new),
        contentType: "application/JSON",
        dataType: "JSON",
        scriptCharset: "utf-8"
      }).done(function(data, status, xhr) {
        return $("#tag_Warn").replaceWith("<span id='tag_Warn' class='warn_message'>Update success</span>");
      }).fail(function(xhr, status, error) {
        return $("#tag_Warn").replaceWith("<span id='tag_Warn' class='warn_message'>Update failed, please reload</span>");
      }).always(function(arg1, status, arg2) {
        return setTimeout(update_page, 1000);
      });
    }
  } else {
    return button_id.attr("disabled", false);
  }
};

update_page = function() {
  reset_UIParts();
  return startpoint_dashboard_edit_tag_date();
};

reset_UIParts = function() {
  $("#tag_Warn").replaceWith("<span id='tag_Warn'></span>");
  $("#tag_Button").replaceWith("<span id='tag_Button'></span>");
  $("#tag_Header").replaceWith("<div id='tag_Header'></div>");
  return $("#tag_Info").replaceWith("<div id='tag_Info'></div>");
};

init_Buttons = function(isDeleteMode) {
  var addItem_click, cancel_click, deleteItem_click, submit_click;
  $("#tag_Button").append("<button type='button' id='addItem' class='btn btn-lg btn-default'>Add New Item</button> ");
  $("#tag_Button").append("<button type='button' id='deleteItem' class='btn btn-lg btn-warning'>Delete Items</button> ");
  $("#tag_Button").append("<button type='button' id='cancel' class='btn btn-lg btn-default'>Cancel</button> ");
  $("#tag_Button").append("<button type='button' id='submit' class='btn btn-lg btn-primary'>Submit</button>");
  addItem_click = document.getElementById("addItem");
  submit_click = document.getElementById("submit");
  if (isDeleteMode === false) {
    addItem_click.addEventListener("click", function() {
      var button;
      button = $(this);
      return addItem_click_callback(button);
    });
    submit_click.addEventListener("click", function() {
      var button;
      button = $(this);
      return submit_click_callback(button);
    });
  } else {
    addItem_click.disabled;
    addItem_click.style.backgroundColor = "gray";
    submit_click.addEventListener("click", function() {
      var button;
      button = $(this);
      return submit_deleteMode_click_callback(button);
    });
  }
  deleteItem_click = document.getElementById("deleteItem");
  deleteItem_click.addEventListener("click", function() {
    var button;
    button = $(this);
    return deleteItem_click_callback(button);
  });
  cancel_click = document.getElementById("cancel");
  return cancel_click.addEventListener("click", function() {
    $("#tag_Warn").replaceWith("<span id='tag_Warn' class='warn_message'>Canceled..</span>");
    return setTimeout(update_page, 1000);
  });
};

select_input = function(elem) {
  var range, sel;
  sel = window.getSelection();
  range = sel.getRangeAt(0);
  range.selectNode(elem);
  return sel.addRange(range);
};

sort_tag_info = function(tag_info) {
  return tag_info["Tag_item"].sort(function(a, b) {
    if (a["Tag_active"] < b["Tag_active"]) {
      return 1;
    } else if (a["Tag_active"] > b["Tag_active"]) {
      return -1;
    } else if (a["Tag_branch"] > b["Tag_branch"]) {
      return 1;
    } else if (a["Tag_branch"] < b["Tag_branch"]) {
      return -1;
    } else if (a["Tag_branch"] === b["Tag_branch"]) {
      if (a["Tag_deadline"] >= b["Tag_deadline"]) {
        return 1;
      }
      if (a["Tag_deadline"] < b["Tag_deadline"]) {
        return -1;
      }
    }
    return 0;
  });
};
