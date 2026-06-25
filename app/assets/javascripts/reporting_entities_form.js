// Reporting Entities form - add/remove units
(function() {
  var addBtn = document.getElementById('add-unit');
  if (!addBtn) return;

  var unitIndex = parseInt(addBtn.dataset.unitIndex || '0');

  addBtn.addEventListener('click', function(e) {
    e.preventDefault();
    var container = document.getElementById('units-container');
    var html = '<div class="unit-row" style="display:flex; gap:8px; align-items:center; margin-bottom:8px;">' +
      '<input type="text" name="reporting_entity[reporting_units_attributes][' + unitIndex + '][name]" placeholder="Unit name" style="flex:1; padding:10px 12px; border:1px solid #d1d5db; border-radius:6px; font-size:14px;" />' +
      '<a href="#" class="action-link danger remove-unit">✕</a></div>';
    container.insertAdjacentHTML('beforeend', html);
    unitIndex++;
  });

  document.addEventListener('click', function(e) {
    if (e.target.classList.contains('remove-unit')) {
      e.preventDefault();
      var row = e.target.closest('.unit-row');
      var destroyField = row.querySelector('.destroy-field');
      if (destroyField) {
        destroyField.value = '1';
        row.style.display = 'none';
      } else {
        row.remove();
      }
    }
  });
})();
