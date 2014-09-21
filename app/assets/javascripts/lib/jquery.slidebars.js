(function($){
	
	$.fn.slidebars = function() {
		$("body").css("padding", 0)
		this.wrap('<div id="sb-site"></div>')
	
		$.slidebars();
	
		// Slidebars Submenus
		$('.sb-toggle-submenu').off('click').on('click', function() {
			$submenu = $(this).next('.sb-submenu');
			$(this).add($submenu).toggleClass('sb-submenu-active'); // Toggle active class.

			if ($submenu.hasClass('sb-submenu-active')) {
				$submenu.slideDown(200);
			} else {
				$submenu.slideUp(200);
			}
		});
	}
	
})(jQuery)