//= require jquery
//= require jquery_ujs
//= require jquery.turbolinks
prepare_load_func = function() {
  var h = $(window).height();
  $('#wrap').css('display','none');
  $('#loader-bg ,#loader').height(h).css('display','block');
}

display_load_func = function() {
  $('#loader-bg').delay(900).fadeOut(800);
  $('#loader').delay(600).fadeOut(300);
  $('#wrap').css('display', 'block');
}

$(document).ready(function() {
  $('.keyword').change(function() {
    prepare_load_func();
    display_load_func();
    $('#page').val(1);
    $('#submit_btn').submit()
    $("#submit_btn").prop("disabled", true);
  })
  $(document)
  .ajaxStart(function() {
    $("#submit_btn").prop("disabled", true);
  })
  .ajaxComplete(function() {
    $("#submit_btn").prop("disabled", false);
  })
})

$(document).ready(function() {
  $('.card_id').change(function() {
    $('#submit_btn').submit()
    $("#submit_btn").prop("disabled", true);
  })
  $(document)
  .ajaxStart(function() {
    $("#submit_btn").prop("disabled", true);
  })
  .ajaxComplete(function() {
    $("#submit_btn").prop("disabled", false);
  })
})

$(document).ready(function() {
  $("input[name='search_type[category]']").change(function() {
    var value = $("input[name='search_type[category]']:checked").val()
    $('#page').val(1);
    if (value == 'all') {
      $(".keyword").val('一覧表示中です(´・ω・)')
      $(".keyword").prop('disabled', true);
    } else {
      $(".keyword").val('')
      $(".keyword").prop('disabled', false);
    }

    prepare_load_func();
    display_load_func();
    $('#submit_btn').submit()
    $("#submit_btn").prop("disabled", true);
  });
  $(document)
  .ajaxStart(function() {
    $("#submit_btn").prop("disabled", true);
  })
  .ajaxComplete(function() {
    $("#submit_btn").prop("disabled", false);
  })
})

$(document).ready(function() {
  $(".select_check_box").change(function() {
    $('#page').val(1);

    prepare_load_func();
    display_load_func();
    $('#submit_btn').submit()
    $("#submit_btn").prop("disabled", true);
  });
  $(document)
  .ajaxStart(function() {
    $("#submit_btn").prop("disabled", true);
  })
  .ajaxComplete(function() {
    $("#submit_btn").prop("disabled", false);
  })
})
