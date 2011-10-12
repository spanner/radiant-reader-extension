// This is your 'select all' checkbox: its state is applied to all siblings with 'toggled' class.
//
Toggle.SelectAllBehavior = Behavior.create(Toggle.CheckboxBehavior, {
  toggle: function() {
    var state = this.element.checked;
    this.element.ancestors()[1].select('input.toggled').each(function (el) { el.checked = state; });
  }
});

// This checkbox, when checked, will check and disable all others within the same containing element.
// It's useful in a tree view when the checked property will be inherited.
//
Treebox = Behavior.create({
  onclick: function(e) {
    this.toggle();
  },
  toggle: function() {
    var state = this.element.checked;
    this.element.up('li').down('ul').select('input').each(function (el) { 
      el.checked = state; 
      el.disabled = state == true;
    });
  }
});

GroupSelection = Behavior.create({
  onsubmit : function(e) {
    if (e) e.stop();
    var group_list = this.element.getInputs('checkbox').collect(function(i) { if (i.checked && !i.disabled) return i.value; }).compact();
    var flag = $('group_status_flag');
    if (group_list.length == 0) {
      flag.removeClassName('restricted').addClassName('unrestricted').update('Open');
    } else {
      flag.removeClassName('unrestricted').addClassName('restricted').update('Restricted');
    }
    field = $(this.element.readAttribute('rel'));
    field.value = group_list.join(',');
    this.element.closePopup();
  }
});

// This is a normal remote link that replaces itself with the response.
//
Remote.UpdatingLink = Behavior.create(Remote.Base, {
  onclick : function() {
    var self = this;
    var options = Object.extend({ 
      url : self.element.href, 
      method : 'get',
      update: self.element.up(),
      onLoading: function () { self.element.addClassName('waiting'); },
      onComplete: function () { self.element.removeClassName('waiting'); },
      onSuccess: function () { Event.addBehavior.reload(); },
      onFailure: function () { self.element.addClassName('failed'); }
    }, self.options);
    return self._makeRequest(options);
  }
});

Remote.UpdatingForm = Behavior.create(Remote.Base, {
  onsubmit : function() {
    var self = this;
    var options = Object.extend({
      url : self.element.action,
      method : self.element.method || 'get',
      parameters : self.element.serialize(),
      update: self.element.up(),
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
  'a.fake_checkbox': Remote.UpdatingLink(),
  'a.inplace': Remote.UpdatingLink(),
  'form.inplace': Remote.UpdatingForm(),
  'input.treebox': Treebox(),
  'form.group_selection': GroupSelection()
});