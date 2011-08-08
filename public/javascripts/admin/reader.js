Toggle.SelectAllBehavior = Behavior.create(Toggle.CheckboxBehavior, {
  toggle: function() {
    var state = this.element.checked;
    this.element.ancestors()[1].select('input.toggled').each(function (el) { el.checked = state; });
  }
});

Event.addBehavior({ 
  'div.radio_group': Toggle.RadioGroupBehavior(),
  'input.select_all': Toggle.SelectAllBehavior()
});