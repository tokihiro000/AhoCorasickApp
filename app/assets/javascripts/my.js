//= require jquery
//= require jquery_ujs
//= require jquery.turbolinks

$(document).ready(function() {
  $('.keyword').keyup(function() {
    $('#submit_btn').submit()
    $("#submit_btn").prop("disabled", true);
  })
  $(document)
  .ajaxStart(function() { $("#submit_btn").prop("disabled", true); })
  .ajaxComplete(function() { $("#submit_btn").prop("disabled", false); })
})

$(document).ready(function() {
  $('.card_id').keyup(function() {
    $('#submit_btn').submit()
    $("#submit_btn").prop("disabled", true);
  })
  $(document)
  .ajaxStart(function() { $("#submit_btn").prop("disabled", true); })
  .ajaxComplete(function() { $("#submit_btn").prop("disabled", false); })
})

$(document).ready(function() {
  $('input').change(function() {
    $('#submit_btn').submit()
    $("#submit_btn").prop("disabled", true);
  });
  $(document)
  .ajaxStart(function() { $("#submit_btn").prop("disabled", true); })
  .ajaxComplete(function() { $("#submit_btn").prop("disabled", false); })
})
