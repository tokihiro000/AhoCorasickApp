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

get_history_obj_func = function() {
  //  レア度のチェックボックスを確認する
  var checked_rarity_id_list = []
  $(".select_check_box_rarity:checked").each(function() {
      const rarity_id = '#' + $(this)[0].id;
      checked_rarity_id_list.push(rarity_id);
  });

  // 属性のチェックボックスを確認する
  var checked_attribute_id_list = []
  $(".select_check_box_attribute:checked").each(function() {
      const attirbute_id = '#' + $(this)[0].id;
      checked_attribute_id_list.push(attirbute_id);
  });

  const search_type_id = '#' + $(".select_radio_button:checked")[0].id;
  return {
    page: Number($('#page').val()),
    keyword: $("#input-13").val(),
    keyword_state: $("#input-13").is(':disabled'),
    search_type_id: search_type_id,
    checked_rarity_id_list: checked_rarity_id_list,
    checked_attribute_id_list: checked_attribute_id_list
  }
}

set_history_obj_func = function(obj) {
  // ページ
  const page_number = obj.page ? obj.page : 1;
  $('#page').val(page_number);

  // キーワード
  $("#input-13").val(obj.keyword);
  $("#input-13").prop('disabled', obj.keyword_state);

  // 検索タイプ
  search_type_id = obj.search_type_id ? obj.search_type_id : "#search_type_category_card_name"
  $(search_type_id).prop("checked", true);

  // レア度チェック
  // 一旦全部消す
  $(".select_check_box_rarity").each(function() {
      $(this).prop("checked", false);
  });
  if (obj.checked_rarity_id_list) {
    obj.checked_rarity_id_list.forEach(function(v, i, a) {
      $(v).prop("checked", true);
    });
  }
  // 属性チェック
  // 一旦全部消す
  $(".select_check_box_attribute").each(function() {
      $(this).prop("checked", false);
  });
  if (obj.checked_attribute_id_list) {
    obj.checked_attribute_id_list.forEach(function(v, i, a) {
      $(v).prop('checked', true);
    });
  }
}

$(document).ready(function() {
  $(window).on('popstate', function(e) {
      console.log("popstate");
      if (e.originalEvent.state) {
        // var page_number = Number(e.originalEvent.state.page);
        // $('#page').val(page_number);
        set_history_obj_func(e.originalEvent.state);
        prepare_load_func();
        display_load_func();
        $('body, html').animate({ scrollTop: 340 }, 50);
        Rails.fire($("#form1_id")[0], "submit");
      } else {
        console.log("e.originalEvent.state is null");
      }
  });
});

$(document).ready(function() {
  $('#form1_id').keypress( function ( e ) {
  	if ( e.which == 13 ) {
      console.log(".keyword change");
      prepare_load_func();
      display_load_func();
      $('#page').val(1);

      window.history.pushState(get_history_obj_func(), null);
      $('#form1_id').submit();
  		return false;
  	}
  });
});

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

    window.history.pushState(get_history_obj_func(), null);
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
  $(".select_check_box_rarity").change(function() {
    console.log(".select_check_box_rarity change");
    $('#page').val(1);
    prepare_load_func();
    display_load_func();

    window.history.pushState(get_history_obj_func(), null);
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
  $(".select_check_box_attribute").change(function() {
    console.log(".select_check_box_attribute change");
    $('#page').val(1);
    prepare_load_func();
    display_load_func();

    window.history.pushState(get_history_obj_func(), null);
    $('#form1_id').submit();
  })
  .ajaxStart(function() {
    $("#form1_id").disabled = true;
  })
  .ajaxComplete(function() {
    $("#form1_id").disabled = false;
  })
})
