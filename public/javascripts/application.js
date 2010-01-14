function $(id) {
  return document.getElementById(id);
}

function $n(id) {
  return document.getElementsByName(id);
}

function toggle(id) {
  var elem = $(id);
  if (elem.style.display != 'none') {
    elem.style.display = 'none';
  } else {
    elem.style.display = '';
  }
}

function delete_report_set(id, name) {
  if (confirm('Are you sure you want to delete the Report Set ' + name + '?')) {
    window.location = '/report_set/' + id + '/delete';
  }
}
