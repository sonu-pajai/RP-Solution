// Report Documents form - rich text editor
(function() {
  var editor = document.getElementById('editor');
  var contentField = document.getElementById('content-field');
  var form = document.getElementById('doc-form');

  if (!editor || !form) return;

  // Sync editor content to hidden field before submit
  form.addEventListener('submit', function() {
    contentField.value = editor.innerHTML;
  });

  // Toolbar commands
  window.execCmd = function(cmd) {
    document.execCommand(cmd, false, null);
    editor.focus();
  };

  window.execHeading = function(tag) {
    document.execCommand('formatBlock', false, '<' + tag + '>');
    editor.focus();
  };

  window.insertTable = function() {
    var rows = prompt('Number of rows:', '3');
    var cols = prompt('Number of columns:', '3');
    if (!rows || !cols) return;
    var html = '<table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse; width:100%;"><tbody>';
    for (var i = 0; i < parseInt(rows); i++) {
      html += '<tr>';
      for (var j = 0; j < parseInt(cols); j++) {
        html += '<td>&nbsp;</td>';
      }
      html += '</tr>';
    }
    html += '</tbody></table><p></p>';
    document.execCommand('insertHTML', false, html);
    editor.focus();
  };

  // Insert data from server
  window.insertData = function(section) {
    var entityEl = document.getElementById('doc-entity');
    var periodEl = document.getElementById('doc-period');
    var entityId = getTS(entityEl) ? getTS(entityEl).getValue() : entityEl.value;
    var periodId = getTS(periodEl) ? getTS(periodEl).getValue() : periodEl.value;

    fetch('/report_documents/insert_data?section=' + section + '&reporting_entity_id=' + entityId + '&period_id=' + periodId)
      .then(function(r) { return r.json(); })
      .then(function(data) {
        editor.focus();
        document.execCommand('insertHTML', false, data.html);
      });
  };
})();
