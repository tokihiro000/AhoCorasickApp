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
    console.log(".keyword change");
    prepare_load_func();
    display_load_func();
    $('#page').val(1);
    $('#form1_id').submit();
  })
  .ajaxStart(function() {
    $("#form1_id").disabled = true;
  })
  .ajaxComplete(function() {
    $("#form1_id").disabled = false;
  })
})

// $(document).ready(function() {
//   $('.card_id').change(function() {
//     console.log(".card_id change");
//     $('#form1_id').submit();
//   })
//   .ajaxStart(function() {
//     $("#submit_btn").prop("disabled", true);
//   })
//   .ajaxComplete(function() {
//     $("#submit_btn").prop("disabled", false);
//   })
// })

$(document).ready(function() {
  $("input[name='search_type[category]']").change(function() {
    console.log("input[name='search_type[category] change");
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
    $('#form1_id').submit();
  })
  .ajaxStart(function() {
    $("#form1_id").disabled = true;
  })
  .ajaxComplete(function() {
    $("#form1_id").disabled = false;
  })
})

$(document).ready(function() {
  $(".select_check_box").change(function() {
    console.log(".select_check_box change");
    $('#page').val(1);
    prepare_load_func();
    display_load_func();
    $('#form1_id').submit();
  })
  .ajaxStart(function() {
    $("#form1_id").disabled = true;
  })
  .ajaxComplete(function() {
    $("#form1_id").disabled = false;
  })
})
