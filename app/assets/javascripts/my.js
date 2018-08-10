//= require jquery
//= require jquery_ujs
//= require jquery.turbolinks

$(document).ready(function() {
  $('.keyword').change(function() {
    $('#page').val(1);
    $('#submit_btn').submit()
    $("#submit_btn").prop("disabled", true);
  })
  $(document)
  .ajaxStart(function() { $("#submit_btn").prop("disabled", true); })
  .ajaxComplete(function() { $("#submit_btn").prop("disabled", false); })
})

$(document).ready(function() {
  $('.card_id').change(function() {
    $('#submit_btn').submit()
    $("#submit_btn").prop("disabled", true);
  })
  $(document)
  .ajaxStart(function() { $("#submit_btn").prop("disabled", true); })
  .ajaxComplete(function() { $("#submit_btn").prop("disabled", false); })
})

$(document).ready(function() {
  $('input').change(function() {
    var value = $("input[name='search_type[category]']:checked").val()
    $('#page').val(1);
    if (value == 'all') {
      $(".keyword").val('一覧表示中です(´・ω・)')
      $(".keyword").prop('disabled', true);
    } else {
      $(".keyword").val('')
      $(".keyword").prop('disabled', false);
    }

    $('#submit_btn').submit()
    $("#submit_btn").prop("disabled", true);
  });
  $(document)
  .ajaxStart(function() { $("#submit_btn").prop("disabled", true); })
  .ajaxComplete(function() { $("#submit_btn").prop("disabled", false); })
})
