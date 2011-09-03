// This is your 'select all' checkbox: its state is applied to all siblings with 'toggled' class.
//
Toggle.SelectAllBehavior = Behavior.create(Toggle.CheckboxBehavior, {
  toggle: function() {
    var state = this.element.checked;
    this.element.ancestors()[1].select('input.toggled').each(function (el) { el.checked = state; });
  }
});

// This is a normal remote link that replaces itself with the response.
//
Remote.UpdatingLink = Behavior.create(Remote.Base, {
  onclick : function() {
    var self = this;
    var options = Object.extend({ 
      url : this.element.href, 
      method : 'get',
      update: this.element.up(),
      onLoading: function () { self.element.addClassName('waiting'); },
      onComplete: function () { self.element.removeClassName('waiting'); },
      onSuccess: function () { Event.addBehavior.reload(); },
      onFailure: function () { self.element.addClassName('failed'); }
    }, self.options);
    return self._makeRequest(options);
  }
});

Event.addBehavior({ 
  'div.radio_group': Toggle.RadioGroupBehavior(),
  'input.select_all': Toggle.SelectAllBehavior(),
  'a.fake_checkbox': Remote.UpdatingLink()
});