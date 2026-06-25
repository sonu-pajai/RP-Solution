// Sidebar toggle
var toggle = document.getElementById('sidebar-toggle');
var sidebar = document.getElementById('sidebar');
var main = document.getElementById('main-content');
var isMobile = window.innerWidth <= 768;

if (toggle) {
  toggle.addEventListener('click', function() {
    if (isMobile) {
      sidebar.classList.toggle('mobile-open');
    } else {
      sidebar.classList.toggle('collapsed');
      main.classList.toggle('expanded');
    }
  });
}

window.addEventListener('resize', function() {
  isMobile = window.innerWidth <= 768;
});

// Tom Select initialization
function initTomSelect() {
  document.querySelectorAll('select.form-control:not(.tomselected)').forEach(function(el) {
    if (el.tomselect) return;
    new TomSelect(el, { plugins: ['dropdown_input'], allowEmptyOption: true });
  });
}
initTomSelect();
document.addEventListener('turbo:render', initTomSelect);

// Shared helpers
window.getTS = function(el) { return el ? el.tomselect : null; };

window.refreshTS = function(el, options, placeholder) {
  var ts = window.getTS(el);
  if (ts) {
    ts.clear();
    ts.clearOptions();
    ts.addOption({ value: '', text: placeholder });
    options.forEach(function(o) { ts.addOption(o); });
    ts.refreshOptions(false);
    if (el.disabled) { ts.disable(); } else { ts.enable(); }
  }
};
