var activations = [];

var activate = function (scope) {
  if (!scope) scope = document;
  activations.each(function (fun) { fun.run(scope); });
};

window.addEvent('domready', function(){
  activate();
});

var fadeNotices = function () {
  $$('div.notice, div.error').fade('out');
};

activations.push(function (scope) {
  fadeNotices.delay(3000);
});
