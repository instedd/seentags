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
    '<input type="text" style="width:440px"/> ' +
    '<button onclick="save_correction()">Correct</button> ' +
    '<button onclick="cancel_correction()">Cancel</button>'
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
