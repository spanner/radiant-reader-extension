(function($) { 

	$.fn.toggler = function() { 
		this.each(function() { 
		  var self = $(this);
		  var toggling = $(self.attr.rel);
      self.click( function (event) {
        event.preventDefault();
        toggling.toggle();
      });
		});
		return this;
	};

})(jQuery);

$(function() {
  $("a.toggle").toggler();
});
