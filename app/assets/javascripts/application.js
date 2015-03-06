// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require instedd-bootstrap
//= require_tree .

function toggle(id) {
  jQuery('#' + id).toggle('fast');
}

var $currentLink;
var $currentContent;
var currentId;
var currentIdx;
var currentText;

function correct_report(elem, id, idx) {
  cancel_correction();

  currentId = id;
  currentIdx = idx;
  $currentLink = jQuery(elem);
  $currentLink.hide();

  var $piece = $currentLink.parent('.piece');
  $currentContent = $piece.find('.content');
  currentText = jQuery.trim($currentContent.text());

  $currentContent.html(
    '<input type="text"/> ' +
    '<button onclick="save_correction()" class="btn btn-mini btn-primary">Correct</button> ' +
    '<button onclick="cancel_correction()" class="btn btn-mini btn-link">Cancel</button>'
  );

  var input = $currentContent.contents('input');
  input.val(currentText);
  input.focus();
  input.keydown(function(event) {
    switch(event.keyCode) {
    case 13:
      save_correction();
      break;
    case 27:
      cancel_correction();
      break;
    }
  });
}

function save_correction() {
  var input = $currentContent.contents('input');
  var text = input.val();

  jQuery.post('/report/' + currentId + '/correct', {text: text, idx: currentIdx}, function(data) {
    window.location.reload();
  });
}

function cancel_correction() {
  if ($currentContent) {
      $currentContent.html(currentText);
      $currentLink.show();
  }
  return false;
}
