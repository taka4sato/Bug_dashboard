startpoint_dashboard_edit_tag_date= (tag_info) ->
  $("#tag_Date").append tag_info
  tag_info_json = JSON.parse(tag_info)
  console.log tag_info_json
  new_tag_info_json = tag_info_json

  $.each tag_info_json.Tag_date, (i, item) ->
    console.log item
    console.log item.Tag_name
    $("#tag_Info").append item.Tag_name + ":: <input type='text' name='" + item.Tag_name + "' value='" + item.Tag_deadline + "' /><br>"

    $("input[name='" + item.Tag_name + "']").daterangepicker {
      singleDatePicker: true
      showDropdowns: true
      format: 'YYYY-MM-DD',
    }, (start, end, label) ->
      original_date = moment(item.Tag_deadline, 'YYYY-MM-DD')
      new_date_delta = start.diff(original_date, 'day')
      update_tag_date_info(new_tag_info_json, item.Tag_name, start.format('YYYY-MM-DD'))
      #console.log "selected date: " + start.format('YYYY-MM-DD')
      #console.log "new date is  : " + new_date_delta + " days later"

  $("#tag_Button").append "<button type='button' id='cancel' class='btn btn-lg btn-default'>Cancel</button> "
  $("#tag_Button").append "<button type='button' id='submit' class='btn btn-lg btn-primary'>Submit</button>"
  submit_click = document.getElementById('submit')
  submit_click.addEventListener 'click', ->
    button = $(this)
    button.attr 'disabled', true
    $.ajax
      type: 'post'
      url: window.location.protocol + "//" + window.location.host + "/v1/edit_tag_date"
      data: JSON.stringify(new_tag_info_json)
      contentType: 'application/JSON'
      dataType: 'JSON'
      scriptCharset: 'utf-8'
      success: (data) ->
        console.log 'POST succeed'
        console.log JSON.stringify(data)
        button.attr("disabled", false);
      error: (data) ->
        console.log 'POST failed'
        console.log JSON.stringify(data)
        button.attr("disabled", false);

  cancel_click = document.getElementById('cancel')
  cancel_click.addEventListener 'click', ->
    console.log 'cancellllllllll button clicked'

update_tag_date_info= (new_tag_info_json, target_tag_name, new_date) ->
  $.each new_tag_info_json.Tag_date, (i, item) ->
    console.log item
    if item["Tag_name"] == target_tag_name
      item["Tag_deadline"] = new_date

submit_click_callback = (new_tag_info_json) ->
  console.log "-----------------"
  console.log 'submit button clicked'
  console.log new_tag_info_json
  console.log "targetURL = " + window.location.protocol + "//" + window.location.host + "/v1/edit_tag_date"
  console.log "-----------------"
  button = $(this);
  console.log "time start"
  button.attr("disabled", true);

  setTimeout (->
    button.attr("disabled", false);
    console.log "time end"
    return
  ), 1500

