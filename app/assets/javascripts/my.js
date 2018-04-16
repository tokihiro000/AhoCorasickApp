//= require jquery
//= require jquery_ujs
//= require jquery.turbolinks

keyword = ""
$(document).ready(function() {
  $('#keyword').keyup(function() {
    $('#submit_btn').submit()
    $("#submit_btn").prop("disabled", true);
    console.log("keyword key up");
  })
  $(document)
  .ajaxStart(function() { $("#submit_btn").prop("disabled", true); })
  .ajaxComplete(function() { $("#submit_btn").prop("disabled", false); })
})

// $(document).on('page:load', ready)
