document.observe('dom:loaded', function() {
  $$('.delivery_chooser').each(function (rb) { rb.observe('click', toggle_readerlist); });
  if (delivery_selection() != 'selection') Effect.Fade('select_readers');
});

var toggle_readerlist = function() {
  fx = (delivery_selection() == 'selection') ? Effect.Appear : Effect.Fade;
  fx('select_readers', { duration: 0.5 });
};

var delivery_selection = function () {
  return $$('input:checked[type="radio"][name="delivery"]').pluck('value');
};
