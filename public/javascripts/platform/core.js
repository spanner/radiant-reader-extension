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





// some useful extensions

var top_z = null;
var topZ = function () {
  if (top_z) return top_z;
  $$('*').each(function (element) {
    z = parseInt(element.getStyle('z-index'), 10);
    if (z > top_z) top_z = z;
  });
  return top_z;
};

Element.implement({
  front: function () {
    top_z = topZ() + 1;
    this.setStyle('z-index', top_z);
  }
});

var unevent = function (e) {
  if (e) new Event(e).stop();
};