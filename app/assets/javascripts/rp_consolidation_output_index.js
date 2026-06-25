// RP Consolidation Output index - filters
(function() {
  var viewFilter = document.getElementById('view-filter');
  var periodFilter = document.getElementById('period-filter');
  var entityFilter = document.getElementById('entity-filter');
  var entityGroup = document.getElementById('entity-filter-group');

  if (!viewFilter) return;

  function toggleEntityFilter() {
    var val = getTS(viewFilter) ? getTS(viewFilter).getValue() : viewFilter.value;
    entityGroup.style.display = val === 'standalone' ? '' : 'none';
  }

  function applyFilters() {
    var params = [];
    var viewVal = getTS(viewFilter) ? getTS(viewFilter).getValue() : '';
    var periodVal = getTS(periodFilter) ? getTS(periodFilter).getValue() : '';
    var entityVal = getTS(entityFilter) ? getTS(entityFilter).getValue() : '';
    if (viewVal) params.push('view_type=' + viewVal);
    if (periodVal) params.push('period_id=' + periodVal);
    if (viewVal === 'standalone' && entityVal) params.push('reporting_entity_id=' + entityVal);
    window.location.href = '/rp_consolidation_output' + (params.length ? '?' + params.join('&') : '');
  }

  if (getTS(viewFilter)) getTS(viewFilter).on('change', function() { toggleEntityFilter(); applyFilters(); });
  if (getTS(periodFilter)) getTS(periodFilter).on('change', applyFilters);
  if (getTS(entityFilter)) getTS(entityFilter).on('change', applyFilters);

  toggleEntityFilter();
})();
