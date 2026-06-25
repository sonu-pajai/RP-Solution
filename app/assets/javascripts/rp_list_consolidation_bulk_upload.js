// RP List Consolidation bulk upload - template link
(function() {
  var modeEl = document.getElementById('mode-select');
  var downloadLink = document.getElementById('download-template');

  if (!modeEl || !downloadLink) return;

  var templatePath = downloadLink.dataset.templatePath;

  function updateTemplateLink() {
    var val = modeEl.tomselect ? modeEl.tomselect.getValue() : modeEl.value;
    downloadLink.href = templatePath + '?mode=' + val;
  }

  updateTemplateLink();
  if (modeEl.tomselect) { modeEl.tomselect.on('change', updateTemplateLink); }
  else { modeEl.addEventListener('change', updateTemplateLink); }
})();
