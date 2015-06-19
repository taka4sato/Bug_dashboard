global_tag_info = ""
global_tag_info_new = ""
global_tag_info_orig = ""

startpoint_dashboard_edit_tag_date= (tag_info) ->

  global_tag_info      = JSON.parse(tag_info)
  global_tag_info_new  = JSON.parse(tag_info)
  global_tag_info_orig = JSON.parse(tag_info)

  $("#tag_Header").append "<span style='width:250px' class='list_header'>Branch Name</span><span style='width:145px' class='list_header'>Tag Name</span><span style='width:150px' class='list_header'>Deadline</span><br>"

  $.each global_tag_info.Tag_item, (i, item) ->
    $("#tag_Info").append "<span style='width:250px'>" + item["Tag_branch"] + "</span><span style='width:150px'>" + item["Tag_name"] + "</span><input type='text' align='center' style='width:150px' name='" + item["Tag_branch"] + item["Tag_name"] + "' value='" + item["Tag_deadline"] + "' /><br>"

    $("input[name='" + item["Tag_branch"] + item["Tag_name"] + "']").daterangepicker {
      singleDatePicker: true
      showDropdowns: true
      showWeekNumbers: true
      minDate: "2014/01/01"
      format: "YYYY-MM-DD",
    }, (start, end, label) ->

      original_date = check_original_date(item["Tag_branch"], item["Tag_name"])
      update_tag_date_info(item["Tag_branch"], item["Tag_name"], start.format('YYYY-MM-DD'))

      this_text_input = $(":text[name=" + item["Tag_branch"] + item["Tag_name"] + "]")
      if start.format("YYYY-MM-DD") != original_date
        this_text_input.css "backgroundColor", "yellow"
      else
        this_text_input.css "backgroundColor", "white"

  $("#tag_Button").append "<button type='button' id='addItem' class='btn btn-lg btn-default'>Add New Item</button> "
  $("#tag_Button").append "<button type='button' id='cancel' class='btn btn-lg btn-default'>Cancel</button> "
  $("#tag_Button").append "<button type='button' id='submit' class='btn btn-lg btn-primary'>Submit</button>"
  addItem_click = document.getElementById("addItem")
  addItem_click.addEventListener "click", ->
    button = $(this)
    addItem_click_callback(button)

  submit_click = document.getElementById("submit")
  submit_click.addEventListener "click", ->
    button = $(this)
    submit_click_callback(button)

  cancel_click = document.getElementById("cancel")
  cancel_click.addEventListener "click", ->
    $("#tag_Warn").replaceWith "<span id='tag_Warn' class='warn_message'>Canceled..</span>"
    setTimeout cancel_page, 1000


addItem_click_callback = (button_id) ->
  $("#tag_Info").prepend "<div class='new_item'><span><input style='width:220px' class='new_item_tagBranch' type='text'></span><span><input style='width:125px' class='new_item_tagName' type='text'></span><span><input style='width:150px' type='text' name='new_item_tagDate' value='' /></span></div>"
  new_item_deadline = $(":text[name=new_item_tagDate]")
  new_item_deadline.css "backgroundColor", "yellow"
  $(".new_item_tagBranch, .new_item_tagName").css "backgroundColor", "yellow"

  $("input[name='new_item_tagDate']").daterangepicker {
    singleDatePicker: true
    showDropdowns: true
    showWeekNumbers: true
    minDate: "2014/01/01"
    format: "YYYY-MM-DD",
  }


check_original_date = (target_tag_branch, target_tag_name) ->
  count = 0
  $.each global_tag_info_orig["Tag_item"], (i, item) ->
    if item["Tag_branch"] == target_tag_branch and item["Tag_name"] == target_tag_name
      count = i
  return global_tag_info_orig["Tag_item"][count]["Tag_deadline"]


update_tag_date_info = (target_tag_branch, target_tag_name, new_date) ->
  $.each global_tag_info_new["Tag_item"], (i, item) ->
    #console.log item
    if item["Tag_branch"] == target_tag_branch and item["Tag_name"] == target_tag_name
      item["Tag_deadline"] = new_date


submit_click_callback = (button_id) ->
  $("#tag_Warn").replaceWith "<span id='tag_Warn'></span>"
  proceedPOST_flag = 1
  all_new_item_array = []
  temprary_array = []

  $(".new_item").each ->
    new_tag_branch = $(this).children("span").children(".new_item_tagBranch").val()
    new_tag_name   = $(this).children("span").children(".new_item_tagName").val()
    new_tag_date   = $(this).children("span").children(":text[name=new_item_tagDate]").val()
    all_new_item   = [new_tag_branch, new_tag_name, new_tag_date]
    all_new_item_array.push(all_new_item)

  $(".new_item").each ->
    new_tag_branch = $(this).children("span").children(".new_item_tagBranch").val()
    new_tag_name   = $(this).children("span").children(".new_item_tagName").val()
    new_tag_date   = $(this).children("span").children(":text[name=new_item_tagDate]").val()
    new_item_array = {Tag_branch: new_tag_branch, Tag_name: new_tag_name, Tag_deadline: new_tag_date}
    isEmpty_flag = 0

    # when all cells are blank, just set the background to Gray and ignore
    if new_tag_branch == "" and new_tag_name == "" and new_tag_date == ""
      $(this).children("span").children(".new_item_tagBranch, .new_item_tagName, :text[name=new_item_tagDate]").css "backgroundColor", "#EEEEEE"
      $("#tag_Warn").replaceWith "<span id='tag_Warn'></span>"
      isEmpty_flag = 1

    # when some cells are are blank, do not generate POST
    else if new_tag_branch == "" or new_tag_name == "" or new_tag_date == ""
      $(this).children("span").children(".new_item_tagBranch, .new_item_tagName, :text[name=new_item_tagDate]").css "backgroundColor", "#FFE4E1"
      $("#tag_Warn").replaceWith "<span id='tag_Warn' class='warn_message'>Necessary field is blank</span>"
      proceedPOST_flag = 0

    # when some of new items are duplicated, do not generate POST
    duplicate_count = 0
    $.each all_new_item_array, (i, item) ->
      if new_tag_branch == item[0] and new_tag_name == item[1]
        duplicate_count += 1
      if duplicate_count > 1
        $("#tag_Warn").replaceWith "<span id='tag_Warn' class='warn_message'>Some of new items are duplicated</span>"
        $(this).children("span").children(".new_item_tagBranch, .new_item_tagName, :text[name=new_item_tagDate]").css "backgroundColor", "#FFE4E1"
        proceedPOST_flag = 0

    # when some of new items are duplicated of existing, do not generate POST
    $.each global_tag_info_orig["Tag_item"], (i, item) ->
      if new_tag_branch == item["Tag_branch"] and new_tag_name == item["Tag_name"]
        $("#tag_Warn").replaceWith "<span id='tag_Warn' class='warn_message'>Some of new items are already exist</span>"
        $(this).children("span").children(".new_item_tagBranch, .new_item_tagName, :text[name=new_item_tagDate]").css "backgroundColor", "#FFE4E1"
        proceedPOST_flag = 0

    if proceedPOST_flag == 1 and isEmpty_flag == 0
      temprary_array.push(new_item_array)


  if proceedPOST_flag == 1
    console.log "proceedPOST_flag is 1"
    temprary_array.forEach (item) ->
      global_tag_info_new["Tag_item"].push(item)

    if JSON.stringify(global_tag_info_new["Tag_item"]) == JSON.stringify(global_tag_info_orig["Tag_item"])
      console.log "proceedPOST_flag is 1 - no new item exist"
      $("#tag_Warn").replaceWith "<span id='tag_Warn' class='warn_message'>No new item exists</span>"

    else
      console.log "proceedPOST_flag is 1 - will go to POST"
      button_id.attr "disabled", true
      $.ajax
        type: "post"
        url: window.location.protocol + "//" + window.location.host + "/v1/edit_tag_date"
        data: JSON.stringify(global_tag_info_new)
        contentType: "application/JSON"
        dataType: "JSON"
        scriptCharset: "utf-8"
        success: (data) ->
          $("#tag_Warn").replaceWith "<span id='tag_Warn' class='warn_message'>Update success</span>"
        error: (data) ->
          $("#tag_Warn").replaceWith "<span id='tag_Warn' class='warn_message'>Update failed, please reload</span>"


      button_id.attr("disabled", false);
      setTimeout update_page, 3000

cancel_page = ->
  $("#tag_Warn").replaceWith "<span id='tag_Warn'></span>"
  $("#tag_Button").replaceWith "<span id='tag_Button'></span>"
  $("#tag_Header").replaceWith "<div id='tag_Header'></div>"
  $("#tag_Info").replaceWith "<div id='tag_Info'></div>"
  startpoint_dashboard_edit_tag_date(JSON.stringify(global_tag_info_orig))

update_page = ->
  $("#tag_Warn").replaceWith "<span id='tag_Warn'></span>"
  $("#tag_Button").replaceWith "<span id='tag_Button'></span>"
  $("#tag_Header").replaceWith "<div id='tag_Header'></div>"
  $("#tag_Info").replaceWith "<div id='tag_Info'></div>"
  startpoint_dashboard_edit_tag_date(JSON.stringify(global_tag_info_new))
