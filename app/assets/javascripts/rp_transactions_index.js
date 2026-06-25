// RP Transactions index - filter dropdowns
(function() {
  var entityEl = document.getElementById('reporting_entity');
  var unitEl = document.getElementById('reporting_unit');
  var periodEl = document.getElementById('period');

  if (!entityEl || !unitEl || !periodEl) return;

  function applyFilter() {
    var params = [];
    var entityVal = getTS(entityEl) ? getTS(entityEl).getValue() : '';
    var unitVal = getTS(unitEl) ? getTS(unitEl).getValue() : '';
    var periodVal = getTS(periodEl) ? getTS(periodEl).getValue() : '';
    if (entityVal) params.push('reporting_entity_id=' + entityVal);
    if (unitVal) params.push('reporting_unit_id=' + unitVal);
    if (periodVal) params.push('period_id=' + periodVal);
    window.location = '/rp_transactions' + (params.length ? '?' + params.join('&') : '');
  }

  var entityTS = getTS(entityEl);
  if (entityTS) {
    entityTS.on('change', function(value) {
      if (!value) {
        refreshTS(unitEl, [], '-- Select Reporting Entity first --');
        unitEl.disabled = true;
        applyFilter();
        return;
      }
      fetch('/rp_transactions/reporting_units?reporting_entity_id=' + value)
        .then(function(r) { return r.json(); })
        .then(function(units) {
          var opts = units.map(function(u) { return { value: u.id, text: u.name }; });
          unitEl.disabled = false;
          refreshTS(unitEl, opts, '-- All Reporting Units --');
          applyFilter();
        });
    });
  }

  if (getTS(unitEl)) getTS(unitEl).on('change', applyFilter);
  if (getTS(periodEl)) getTS(periodEl).on('change', applyFilter);
})();
