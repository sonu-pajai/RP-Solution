(function() {
  var viewFilter = document.getElementById('view-filter');
  var periodFilter = document.getElementById('period-filter');
  var entityFilter = document.getElementById('entity-filter');
  var entityGroup = document.getElementById('entity-filter-group');

  if (!viewFilter) return;

  function toggleEntityFilter() {
    if (entityGroup) {
      entityGroup.style.display = viewFilter.value === 'standalone' ? '' : 'none';
    }
  }

  function applyFilters() {
    var params = [];
    if (viewFilter.value) params.push('view_type=' + viewFilter.value);
    if (periodFilter && periodFilter.value) params.push('period_id=' + periodFilter.value);
    if (viewFilter.value === 'standalone' && entityFilter && entityFilter.value) params.push('reporting_entity_id=' + entityFilter.value);
    window.location.href = '/rp_consolidation_output' + (params.length ? '?' + params.join('&') : '');
  }

  viewFilter.addEventListener('change', function() { toggleEntityFilter(); applyFilters(); });
  if (periodFilter) periodFilter.addEventListener('change', applyFilters);
  if (entityFilter) entityFilter.addEventListener('change', applyFilters);

  toggleEntityFilter();
})();
