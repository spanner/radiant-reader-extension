(function($) { 

	$.fn.rails_flash = function() { 
		this.each(function() { 
		  var self = $(this);
      var closer = $('<a href="#" class="closer">x</a>').appendTo(self);
      closer.click( function (event) {
        event.preventDefault();
        self.fadeOut('fast');
      });
		});
		return this;
  };

	$.fn.toggler = function() { 
		this.each(function() { 
		  var self = $(this);
		  var toggling = $(self.attr('rel'));
      self.click( function (event) {
        event.preventDefault();
        toggling.toggle();
      });
		});
		return this;
	};

  $.ajaxSetup({
    'beforeSend': function(xhr) {
      xhr.setRequestHeader("Accept", "text/javascript");
    }
  });
  
  // general-purpose event blocker
  function squash(e) {
    if(e) {
      e.preventDefault();
      e.stopPropagation();
      if (e.target) e.target.blur();
    } 
  }
	
	$.fn.fetch_remote_content = function() {
		this.each(function() {
		  var self = $(this);
		  var url = self.attr('href');
		  if (url) {
  		  self.addClass('waiting');
        $.get(url, function (result) { self.replaceWith($(result)); }, 'html');
		  }
		});
		return this;
	};

  /*
   * jQuery Color Animations
   * Copyright 2007 John Resig
   * Released under the MIT and GPL licenses.
   * syntax corrected but otherwise untouched.
   */
  
  // We override the animation for all of these color styles
  $.each(['backgroundColor', 'borderBottomColor', 'borderLeftColor', 'borderRightColor', 'borderTopColor', 'color', 'outlineColor'], function(i, attr) {
    $.fx.step[attr] = function(fx) {
      if (!fx.colorInit) {
        fx.start = getColor(fx.elem, attr);
        fx.end = getRGB(fx.end);
        fx.colorInit = true;
      }

      fx.elem.style[attr] = "rgb(" + [
      Math.max(Math.min(parseInt((fx.pos * (fx.end[0] - fx.start[0])) + fx.start[0], 10), 255), 0),
      Math.max(Math.min(parseInt((fx.pos * (fx.end[1] - fx.start[1])) + fx.start[1], 10), 255), 0),
      Math.max(Math.min(parseInt((fx.pos * (fx.end[2] - fx.start[2])) + fx.start[2], 10), 255), 0)
      ].join(",") + ")";
    }
  });

  // Color Conversion functions from highlightFade
  // By Blair Mitchelmore
  // http://jquery.offput.ca/highlightFade/

  // Parse strings looking for color tuples [255,255,255]
  function getRGB(color) {
      var result;

      // Check if we're already dealing with an array of colors
      if ( color && color.constructor == Array && color.length == 3 )
          return color;

      // Look for rgb(num,num,num)
      if (result = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(color))
          return [parseInt(result[1], 10), parseInt(result[2], 10), parseInt(result[3], 10)];

      // Look for rgb(num%,num%,num%)
      if (result = /rgb\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*\)/.exec(color))
          return [parseFloat(result[1])*2.55, parseFloat(result[2])*2.55, parseFloat(result[3])*2.55];

      // Look for #a0b1c2
      if (result = /#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/.exec(color))
          return [parseInt(result[1],16), parseInt(result[2],16), parseInt(result[3],16)];

      // Look for #fff
      if (result = /#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])/.exec(color))
          return [parseInt(result[1]+result[1],16), parseInt(result[2]+result[2],16), parseInt(result[3]+result[3],16)];

      // Look for rgba(0, 0, 0, 0) == transparent in Safari 3
      if (result = /rgba\(0, 0, 0, 0\)/.exec(color))
          return colors['transparent'];

      // Otherwise, we're most likely dealing with a named color
      return colors[jQuery.trim(color).toLowerCase()];
  }

  function getColor(elem, attr) {
    var color;

    do {
      color = $.curCSS(elem, attr);

      // Keep going until we find an element that has color, or we hit the body
      if ( color != '' && color != 'transparent' || jQuery.nodeName(elem, "body") )
        break;

      attr = "backgroundColor";
    } while ( elem = elem.parentNode );

    return getRGB(color);
  };

  // Some named colors to work with
  // From Interface by Stefan Petre
  // http://interface.eyecon.ro/

  var colors = {
      aqua:[0,255,255],
      azure:[240,255,255],
      beige:[245,245,220],
      black:[0,0,0],
      blue:[0,0,255],
      brown:[165,42,42],
      cyan:[0,255,255],
      darkblue:[0,0,139],
      darkcyan:[0,139,139],
      darkgrey:[169,169,169],
      darkgreen:[0,100,0],
      darkkhaki:[189,183,107],
      darkmagenta:[139,0,139],
      darkolivegreen:[85,107,47],
      darkorange:[255,140,0],
      darkorchid:[153,50,204],
      darkred:[139,0,0],
      darksalmon:[233,150,122],
      darkviolet:[148,0,211],
      fuchsia:[255,0,255],
      gold:[255,215,0],
      green:[0,128,0],
      indigo:[75,0,130],
      khaki:[240,230,140],
      lightblue:[173,216,230],
      lightcyan:[224,255,255],
      lightgreen:[144,238,144],
      lightgrey:[211,211,211],
      lightpink:[255,182,193],
      lightyellow:[255,255,224],
      lime:[0,255,0],
      magenta:[255,0,255],
      maroon:[128,0,0],
      navy:[0,0,128],
      olive:[128,128,0],
      orange:[255,165,0],
      pink:[255,192,203],
      purple:[128,0,128],
      violet:[128,0,128],
      red:[255,0,0],
      silver:[192,192,192],
      white:[255,255,255],
      yellow:[255,255,0],
      transparent: [255,255,255]
  };

  $.fn.blush = function(color, duration) {
    color = color || "#FFFF9C";
    duration = duration || 1500;
    var backto = this.css("background-color");
    if (backto == "" || backto == 'transparent') backto = '#ffffff';
    this.css("background-color", color).animate({"background-color": backto}, duration);
  };

})(jQuery);

$(function() {
  $("a.toggle").toggler();
  $("a.remotecontent").fetch_remote_content();
  $("div.notice, div.error").rails_flash();
});
