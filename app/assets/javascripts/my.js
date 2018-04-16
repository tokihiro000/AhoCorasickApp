//= require jquery
//= require jquery_ujs
//= require jquery.turbolinks

$(document).ready(function() {
  $('#keyword').keyup(function() {
    $('#submit_btn').submit()
    console.log("keyword key up");
  })
})
// $(document).on('page:load', ready)
