startpoint_dashboard_edit_tag_date= (tag_info) ->
  $("#tag_Date").append tag_info
  tag_info_json = JSON.parse(tag_info);
  $.each tag_info_json.Tag_date, (i, item) ->
    console.log item
    console.log item.Tag_name
    $("#tag_Info").append item.Tag_name + ":: <input type='text' name='" + item.Tag_name + "' value='" + item.Tag_deadline + "' /><br>"

