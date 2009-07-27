window.addEvent('domready', function(){
  flashErrors();
  fadeNotices();
});

// get rid of radiant notifications (after a pause)

fadeNotices = function () {
  reallyFadeNotices.delay(3000);
}

reallyFadeNotices = function () {
  $$('div.notice').each(function (element) { element.fade('out'); });
  $$('div.error').each(function (element) { element.fade('out'); });
}

// flash validation errors

flashErrors = function () {
  $$('p.haserror').each(function (element) { element.highlight(); });
}









