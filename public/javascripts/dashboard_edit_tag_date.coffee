startpoint_dashboard_edit_tag_date= (tag_info_json) ->
  console.log 'welcome to dashboard edit tag date conffee' + tag_info_json
  $("#tag_Date").append tag_info_json

  $('input[name="birthdate"]').daterangepicker {
    singleDatePicker: true
    showDropdowns: true
  }, (start, end, label) ->
    years = moment().diff(start, 'years')
    alert 'You are ' + years + ' years old.'
    return
  return