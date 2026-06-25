// RP Master index - filters
(function() {
  var toggleBtn = document.getElementById('toggle-filters');
  if (!toggleBtn) return;

  toggleBtn.addEventListener('click', function(e) {
    e.preventDefault();
    var el = document.getElementById('advanced-filters');
    el.style.display = el.style.display === 'none' ? '' : 'none';
  });

  function buildUrl(extraParams) {
    var params = new URLSearchParams(window.location.search);
    Object.keys(extraParams).forEach(function(k) {
      if (extraParams[k]) params.set(k, extraParams[k]);
      else params.delete(k);
    });
    params.delete('page');
    return '/rp_master' + (params.toString() ? '?' + params.toString() : '');
  }

  var searchInput = document.getElementById('search-input');
  if (searchInput) {
    searchInput.addEventListener('keydown', function(e) {
      if (e.key === 'Enter') {
        e.preventDefault();
        window.location.href = buildUrl({ search: this.value });
      }
    });
  }

  ['filter-category', 'filter-relationship', 'filter-sebi', 'filter-companies-act', 'filter-status'].forEach(function(id) {
    var el = document.getElementById(id);
    if (el && el.tomselect) {
      el.tomselect.on('change', function(val) {
        var key = id.replace('filter-', '').replace('-', '_');
        var obj = {};
        obj[key] = val;
        window.location.href = buildUrl(obj);
      });
    } else if (el) {
      el.addEventListener('change', function() {
        var key = id.replace('filter-', '').replace('-', '_');
        var obj = {};
        obj[key] = this.value;
        window.location.href = buildUrl(obj);
      });
    }
  });

  var perPageEl = document.getElementById('per-page-select');
  if (perPageEl && perPageEl.tomselect) {
    perPageEl.tomselect.on('change', function(val) {
      window.location.href = buildUrl({ per_page: val });
    });
  } else if (perPageEl) {
    perPageEl.addEventListener('change', function() {
      window.location.href = buildUrl({ per_page: this.value });
    });
  }
})();
