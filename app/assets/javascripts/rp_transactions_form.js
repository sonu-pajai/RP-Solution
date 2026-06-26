// RP Transactions form - cascading dropdowns
(function() {
  var entityEl = document.getElementById('form_reporting_entity');
  var unitEl = document.getElementById('form_reporting_unit');
  var natureEl = document.getElementById('form_nature');
  var subNatureEl = document.getElementById('form_sub_nature');
  var typeEl = document.getElementById('form_transaction_type');
  var mainCodeEl = document.getElementById('form_main_code');
  var subCodeEl = document.getElementById('form_sub_code');
  var icCodeEl = document.getElementById('form_ic_code');

  if (!entityEl || !natureEl) return;

  var entityTS = getTS(entityEl);
  var natureTS = getTS(natureEl);
  var subNatureTS = getTS(subNatureEl);

  if (entityTS) {
    entityTS.on('change', function(value) {
      if (!value) { refreshTS(unitEl, [], '-- Select Reporting Entity first --'); unitEl.disabled = true; return; }
      fetch('/rp_transactions/reporting_units?reporting_entity_id=' + value)
        .then(function(r) { return r.json(); })
        .then(function(units) {
          var opts = units.map(function(u) { return { value: u.id, text: u.name }; });
          unitEl.disabled = false;
          refreshTS(unitEl, opts, '-- Select Reporting Unit --');
        });
    });
  }

  if (natureTS) {
    natureTS.on('change', function(value) {
      refreshTS(typeEl, [], '-- Select Sub-Nature first --'); typeEl.disabled = true;
      if (!value) { refreshTS(subNatureEl, [], '-- Select Nature first --'); subNatureEl.disabled = true; return; }
      fetch('/rp_transactions/sub_natures?nature=' + encodeURIComponent(value))
        .then(function(r) { return r.json(); })
        .then(function(items) {
          var opts = items.map(function(i) { return { value: i, text: i }; });
          subNatureEl.disabled = false;
          refreshTS(subNatureEl, opts, '-- Select --');
        });
    });
  }

  if (subNatureTS) {
    subNatureTS.on('change', function(value) {
      var nature = getTS(natureEl).getValue();
      if (!value) { refreshTS(typeEl, [], '-- Select Sub-Nature first --'); typeEl.disabled = true; clearCodes(); return; }
      fetch('/rp_transactions/transaction_types?nature=' + encodeURIComponent(nature) + '&sub_type=' + encodeURIComponent(value))
        .then(function(r) { return r.json(); })
        .then(function(items) {
          var opts = items.map(function(i) { return { value: i, text: i }; });
          typeEl.disabled = false;
          refreshTS(typeEl, opts, '-- Select --');
        });
      // Auto-fill sub_code and ic_code on sub-nature selection
      fetch('/rp_transactions/transaction_codes?nature=' + encodeURIComponent(nature) + '&sub_type=' + encodeURIComponent(value))
        .then(function(r) { return r.json(); })
        .then(function(data) {
          if (subCodeEl) subCodeEl.value = data.sub_code || '';
          if (icCodeEl) icCodeEl.value = data.ic_code || '';
        });
    });
  }

  var typeTS = getTS(typeEl);
  if (typeTS) {
    typeTS.on('change', function(value) {
      if (!value) { if (mainCodeEl) mainCodeEl.value = ''; return; }
      var nature = getTS(natureEl).getValue();
      var subNature = getTS(subNatureEl).getValue();
      // Auto-fill main_code and ic_code on transaction type selection
      fetch('/rp_transactions/transaction_codes?nature=' + encodeURIComponent(nature) + '&sub_type=' + encodeURIComponent(subNature) + '&transaction_type=' + encodeURIComponent(value))
        .then(function(r) { return r.json(); })
        .then(function(data) {
          if (mainCodeEl) mainCodeEl.value = data.main_code || '';
          if (icCodeEl) icCodeEl.value = data.ic_code || '';
        });
    });
  }

  function clearCodes() {
    if (mainCodeEl) mainCodeEl.value = '';
    if (subCodeEl) subCodeEl.value = '';
    if (icCodeEl) icCodeEl.value = '';
  }
})();
