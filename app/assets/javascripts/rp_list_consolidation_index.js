// RP List Consolidation index - filters
(function() {
  var entityEl = document.getElementById('entity-select');
  var periodEl = document.getElementById('period-select');
  var searchFilter = document.getElementById('search-filter');

  if (!entityEl || !periodEl) return;

  var debounceTimer;
  var tab = (document.getElementById('page-data') || {}).dataset.tab || 'to_submit';

  function loadRecords() {
    var entityVal = getTS(entityEl) ? getTS(entityEl).getValue() : entityEl.value;
    var periodVal = getTS(periodEl) ? getTS(periodEl).getValue() : periodEl.value;
    if (entityVal && periodVal) {
      window.location.href = '/rp_list_consolidation?reporting_entity_id=' + entityVal + '&period_id=' + periodVal;
    }
  }

  if (getTS(entityEl)) getTS(entityEl).on('change', loadRecords);
  else entityEl.addEventListener('change', loadRecords);
  if (getTS(periodEl)) getTS(periodEl).on('change', loadRecords);
  else periodEl.addEventListener('change', loadRecords);

  if (searchFilter) {
    searchFilter.addEventListener('input', function() {
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(function() {
        var entityVal = getTS(entityEl) ? getTS(entityEl).getValue() : entityEl.value;
        var periodVal = getTS(periodEl) ? getTS(periodEl).getValue() : periodEl.value;
        var params = [];
        params.push('reporting_entity_id=' + entityVal);
        params.push('period_id=' + periodVal);
        params.push('tab=' + tab);
        if (searchFilter.value) params.push('search=' + encodeURIComponent(searchFilter.value));
        window.location.href = '/rp_list_consolidation?' + params.join('&');
      }, 500);
    });
  }

  var selectAllHeader = document.getElementById('select-all-header');
  var selectAll = document.getElementById('select-all');
  var checkboxes = document.querySelectorAll('.rp-checkbox');

  function toggleAll(checked) {
    checkboxes.forEach(function(cb) { cb.checked = checked; });
    if (selectAllHeader) selectAllHeader.checked = checked;
    if (selectAll) selectAll.checked = checked;
  }

  if (selectAllHeader) selectAllHeader.addEventListener('change', function() { toggleAll(this.checked); });
  if (selectAll) selectAll.addEventListener('change', function() { toggleAll(this.checked); });
})();
