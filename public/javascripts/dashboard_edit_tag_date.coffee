global_tag_info = ""
global_tag_info_new  = ""
global_tag_info_orig = ""
global_tag_info_del  = ""

startpoint_dashboard_edit_tag_date= () ->
  targetURL = window.location.protocol + "//" + window.location.host + "/tag_date/test.json"
  $.getJSON targetURL, (tag_info) ->
    create_TagList tag_info

create_TagList = (tag_info) ->

  global_tag_info      = JSON.parse(JSON.stringify(tag_info))
  global_tag_info_new  = JSON.parse(JSON.stringify(tag_info))
  global_tag_info_orig = JSON.parse(JSON.stringify(tag_info))
  global_tag_info_del  = JSON.parse(JSON.stringify(tag_info))

  $("#tag_Header").append "<span class='buffer_forCheckbox'></span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:250px' class='list_header'>Branch Name</span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:145px' class='list_header'>Tag Name</span><span style='width:100px' class='list_header'>Active?</span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:150px' class='list_header'>Deadline</span><br>"

  sort_tag_info(global_tag_info)

  previous_BranchName = ""
  $.each global_tag_info["Tag_item"], (i, item) ->
    if item["Tag_active"] == "True"
      isActive = "<select name='" + item["Tag_branch"] + "," + item["Tag_name"] + "' onchange='selectMenuOnchange(this)'><option value='True' selected>Yes</option><option value='False'>No</option></select>"
    else
      isActive = "<select name='" + item["Tag_branch"] + "," + item["Tag_name"] + "' onchange='selectMenuOnchange(this)' style='background: #D8D8D8;'><option value='True'>Yes</option><option value='False' selected>No</option></select>"

    if item["Tag_branch"] == previous_BranchName
      $("#tag_Info").append "<span onclick='select_input(this);' ondblclick='select_input(this);' style='width:250px'></span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:150px'>" + item["Tag_name"] + "</span><span style='width:100px'>" + isActive + "</span><input type='text' align='center' style='width:150px' name='" + item["Tag_branch"] + item["Tag_name"] + "' value='" + item["Tag_deadline"] + "' /><br>"
    else
      $("#tag_Info").append "<span onclick='select_input(this);' ondblclick='select_input(this);' style='width:250px'>" + item["Tag_branch"] + "</span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:150px'>" + item["Tag_name"] + "</span><span style='width:100px'>" + isActive + "</span><input type='text' align='center' style='width:150px' name='" + item["Tag_branch"] + item["Tag_name"] + "' value='" + item["Tag_deadline"] + "' /><br>"

    previous_BranchName = item["Tag_branch"]

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

  init_Buttons(false)



deleteItem_click_callback = (button_id) ->
  reset_UIParts()
  init_Buttons(true)
  $("#tag_Warn").replaceWith "<span id='tag_Warn' class='warn_message'>Detele mode, check items you wan to delete and click submit</span>"
  $("#tag_Header").append "<span class='buffer_forCheckbox'></span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:250px' class='list_header'>Branch Name</span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:145px' class='list_header'>Tag Name</span><span style='width:100px' class='list_header'>Active?</span><span onclick='select_input(this);' ondblclick='select_input(this);' style='width:150px' class='list_header'>Deadline</span><br>"

  #global_tag_info_del = global_tag_info_orig
  sort_tag_info(global_tag_info_del)

  previous_BranchName = ""
  $.each global_tag_info_del["Tag_item"], (i, item) ->

    if item["Tag_branch"] == "False"
      isActive = "Y"
    else
      isActive = "No"
    if item["Tag_branch"] == previous_BranchName
      $("#tag_Info").append "<div class='delete_item'><span class='delete_item_tagBranch' style='color:#D8D8D8; width:250px'>" + item["Tag_branch"] + "</span><span class='delete_item_tagName' style='width:150px'>" + item["Tag_name"] + "</span><span style='width:100px'>" + isActive + "</span><span  style='width:150px'>" + item["Tag_deadline"] + "</span><input type='checkbox' class='checkbox' style='display:inline'/></div>"
    else
      $("#tag_Info").append "<div class='delete_item'><span class='delete_item_tagBranch' style='width:250px'>" + item["Tag_branch"] + "</span><span class='delete_item_tagName' style='width:150px'>" + item["Tag_name"] + "</span><span style='width:100px'>" + isActive + "</span><span  style='width:150px'>" + item["Tag_deadline"] + "</span><input type='checkbox' class='checkbox' style='display:inline'/></div>"

    previous_BranchName = item["Tag_branch"]

submit_deleteMode_click_callback = (button_id) ->

  $(".delete_item").each ->
    if $(this).children(".checkbox").is(':checked') == true
      delete_item_tag_branch = $(this).children(".delete_item_tagBranch").text()
      delete_item_tag_name   = $(this).children(".delete_item_tagName").text()
      #console.log  $(this).children(".delete_item_tagBranch").text()
      #console.log  $(this).children(".delete_item_tagName").text()

      $.each global_tag_info_del["Tag_item"], (i, item) ->
        if item["Tag_branch"] == delete_item_tag_branch and item["Tag_name"] == delete_item_tag_name
          #console.log "bingo" + item["Tag_branch"] + " -- " + item["Tag_name"]
          global_tag_info_del["Tag_item"].splice i, 1
          return false

  button_id.attr "disabled", true
  $.ajax
    type: "post"
    url: window.location.protocol + "//" + window.location.host + "/v1/edit_tag_date"
    data: JSON.stringify(global_tag_info_del)
    contentType: "application/JSON"
    dataType: "JSON"
    scriptCharset: "utf-8"
    success: (data) ->
      $("#tag_Warn").replaceWith "<span id='tag_Warn' class='warn_message'>Update success</span>"
    error: (data) ->
      $("#tag_Warn").replaceWith "<span id='tag_Warn' class='warn_message'>Update failed, please reload</span>"

  button_id.attr("disabled", false);
  setTimeout update_page, 3000

addItem_click_callback = (button_id) ->
  $("#tag_Info").prepend "<div class='new_item'><span><input style='width:230px' class='new_item_tagBranch' type='text'></span><span><input style='width:130px' class='new_item_tagName' type='text'></span><span><select class='new_item_ActiveFlag'><option value='True' selected>Yes</option><option value='False'>No</option></select></span><span><input style='width:150px' type='text' name='new_item_tagDate' value='' /></span></div>"
  new_item_deadline = $(":text[name=new_item_tagDate]")
  new_item_deadline.css "backgroundColor", "yellow"
  $(".new_item_tagBranch, .new_item_tagName, .new_item_ActiveFlag").css "backgroundColor", "yellow"

  $("input[name='new_item_tagDate']").daterangepicker {
    singleDatePicker: true
    showDropdowns: true
    showWeekNumbers: true
    minDate: "2014/01/01"
    format: "YYYY-MM-DD",
  }


check_original_date = (target_tag_branch, target_tag_name) ->
  count = 0
  console.log global_tag_info_orig
  $.each global_tag_info_orig["Tag_item"], (i, item) ->
    if item["Tag_branch"] == target_tag_branch and item["Tag_name"] == target_tag_name
      count = i
  return global_tag_info_orig["Tag_item"][count]["Tag_deadline"]


update_tag_date_info = (target_tag_branch, target_tag_name, new_date) ->
  $.each global_tag_info_new["Tag_item"], (i, item) ->
    #console.log item
    if item["Tag_branch"] == target_tag_branch and item["Tag_name"] == target_tag_name
      item["Tag_deadline"] = new_date

selectMenuOnchange = (obj) ->
  #console.log "selected raw -> branch: " + obj.name.split(",")[0] + " tag: " + obj.name.split(",")[1]
  #console.log $(obj)
  #console.log obj.options[obj.selectedIndex]
  #console.log "selected text: " + obj.options[obj.selectedIndex].text
  #console.log "selected item: " + obj.options[obj.selectedIndex].value

  $.each $(obj).children('option'), (i, item) ->
    if item.outerHTML.includes("selected") == true
      if item["value"] == obj.options[obj.selectedIndex].value
        $(obj).css "backgroundColor", "white"
      else
        $(obj).css "backgroundColor", "yellow"

  $.each global_tag_info_new["Tag_item"], (i, item) ->
    if item["Tag_branch"] == obj.name.split(",")[0] and item["Tag_name"] == obj.name.split(",")[1]
      item["Tag_active"] = obj.options[obj.selectedIndex].value


submit_click_callback = (button_id) ->
  button_id.attr "disabled", true
  $("#tag_Warn").replaceWith "<span id='tag_Warn'></span>"
  proceedPOST_flag = 1
  all_new_item_array = []
  temprary_array = []

  $(".new_item").each ->
    new_tag_branch = $(this).children("span").children(".new_item_tagBranch").val()
    new_tag_name   = $(this).children("span").children(".new_item_tagName").val()
    new_active_flag  = $(this).children("span").children(".new_item_ActiveFlag").val()
    new_tag_date   = $(this).children("span").children(":text[name=new_item_tagDate]").val()
    all_new_item   = [new_tag_branch, new_tag_name, new_active_flag, new_tag_date]
    all_new_item_array.push(all_new_item)

  $(".new_item").each ->
    new_tag_branch = $(this).children("span").children(".new_item_tagBranch").val()
    new_tag_name   = $(this).children("span").children(".new_item_tagName").val()
    new_active_flag  = $(this).children("span").children(".new_item_ActiveFlag").val()
    new_tag_date   = $(this).children("span").children(":text[name=new_item_tagDate]").val()
    new_item_array = {Tag_branch: new_tag_branch, Tag_name: new_tag_name, Tag_active: new_active_flag, Tag_deadline: new_tag_date}
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
    temprary_array.forEach (item) ->
      global_tag_info_new["Tag_item"].push(item)
      return

    if JSON.stringify(global_tag_info_new["Tag_item"]) == JSON.stringify(global_tag_info_orig["Tag_item"])
      $("#tag_Warn").replaceWith "<span id='tag_Warn' class='warn_message'>No new item exists</span>"
      button_id.attr "disabled", false

    else
      console.log "before ajax"
      $.ajax
        type: "post"
        url: window.location.protocol + "//" + window.location.host + "/v1/edit_tag_date"
        data: JSON.stringify(global_tag_info_new)
        contentType: "application/JSON"
        dataType: "JSON"
        scriptCharset: "utf-8"
      .done((data, status, xhr) ->
        $("#tag_Warn").replaceWith "<span id='tag_Warn' class='warn_message'>Update success</span>"
      ).fail((xhr, status, error) ->
        $("#tag_Warn").replaceWith "<span id='tag_Warn' class='warn_message'>Update failed, please reload</span>"
      ).always (arg1, status, arg2) ->
        setTimeout update_page, 1000
  else
    button_id.attr "disabled", false


update_page = ->
  reset_UIParts()
  #startpoint_dashboard_edit_tag_date(JSON.stringify(global_tag_info_new))
  startpoint_dashboard_edit_tag_date()

reset_UIParts = () ->
  $("#tag_Warn").replaceWith "<span id='tag_Warn'></span>"
  $("#tag_Button").replaceWith "<span id='tag_Button'></span>"
  $("#tag_Header").replaceWith "<div id='tag_Header'></div>"
  $("#tag_Info").replaceWith "<div id='tag_Info'></div>"


init_Buttons = (isDeleteMode) ->
  $("#tag_Button").append "<button type='button' id='addItem' class='btn btn-lg btn-default'>Add New Item</button> "
  $("#tag_Button").append "<button type='button' id='deleteItem' class='btn btn-lg btn-warning'>Delete Items</button> "
  $("#tag_Button").append "<button type='button' id='cancel' class='btn btn-lg btn-default'>Cancel</button> "
  $("#tag_Button").append "<button type='button' id='submit' class='btn btn-lg btn-primary'>Submit</button>"

  addItem_click = document.getElementById("addItem")
  submit_click = document.getElementById("submit")

  if isDeleteMode == false
    addItem_click.addEventListener "click", ->
      button = $(this)
      addItem_click_callback(button)

    submit_click.addEventListener "click", ->
      button = $(this)
      submit_click_callback(button)
  else
    addItem_click.disabled
    addItem_click.style.backgroundColor = "gray"

    submit_click.addEventListener "click", ->
      button = $(this)
      submit_deleteMode_click_callback(button)

  deleteItem_click = document.getElementById("deleteItem")
  deleteItem_click.addEventListener "click", ->
    button = $(this)
    deleteItem_click_callback(button)

  cancel_click = document.getElementById("cancel")
  cancel_click.addEventListener "click", ->
    $("#tag_Warn").replaceWith "<span id='tag_Warn' class='warn_message'>Canceled..</span>"
    setTimeout update_page, 1000

select_input = (elem) ->
  sel = window.getSelection()
  range = sel.getRangeAt(0)
  range.selectNode elem
  sel.addRange range

sort_tag_info = (tag_info) ->
  tag_info["Tag_item"].sort (a, b) ->
    if a["Tag_active"] < b["Tag_active"]
      return 1
    else if a["Tag_active"] > b["Tag_active"]
      return -1
    else if a["Tag_branch"] > b["Tag_branch"]
      return 1
    else if a["Tag_branch"] < b["Tag_branch"]
      return -1
    else if a["Tag_branch"] == b["Tag_branch"]
      if a["Tag_deadline"] >= b["Tag_deadline"]
        return 1
      if a["Tag_deadline"] < b["Tag_deadline"]
        return -1
    return 0
