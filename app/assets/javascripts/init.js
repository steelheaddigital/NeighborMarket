/*
Copyright 2013 Neighbor Market

This file is part of Neighbor Market.

Neighbor Market is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Neighbor Market is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Neighbor Market.  If not, see <http://www.gnu.org/licenses/>.
*/

(function($, utils) {

	function App() { 
		init();
	}

	function init() {
		
		Turbolinks.enableProgressBar();

		// When I say html I really mean script for rails
		$.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;

		$(document).ajaxSend(ajaxSend);

		$(document).ajaxSuccess(ajaxSuccess);

		$(document).on('page:change', documentReady);

		$(document).on('click', '.collapseIconLink', function(event){
			collapseLink.call(this, event)
		});

		$(document).on("submit", "[data-dialog]", function(event){
            loadDialog.call(this, event)
        });

        $(document).on("click", "[data-dialog]", function(event){
            loadDialog.call(this, event)
        });

        $(document).on("click", function(event){
			event.stopPropagation();
		});
	}

	function ajaxSend(event, request, settings) {
		// Always send the authenticity_token with ajax
		if ( settings.type == 'post' ) {
	        settings.data = (settings.data ? settings.data + "&" : "")
	                + "authenticity_token=" + encodeURIComponent( AUTH_TOKEN );
	        request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	    }

		$("#FlashMessages").hide();
		$("#FlashNotice").empty();
		$("#FlashAlert").empty();
	}

	function ajaxSuccess(event, request, settings) {
		var notice = request.getResponseHeader("X-Notice")
		if(notice){
			utils.showNotice(notice);
		} 
		
	   	var alert = $.cookie('alert');
		if(alert){
			utils.showAlert(alert);
		} 
	}

	function documentReady() {
		var length = $.trim($('#FlashNotice').html()) + $.trim($('#FlashAlert').html());
		if(length){
			$('#FlashMessages').show();
		}
		else{
			$('#FlashMessages').hide();
		}

		$(".fa-question-circle").tooltip();
		
		$("#Modal").modal({ show:false });

		$('input[type=radio].star').rating();
	}

	function collapseLink(){
		$(this).find('i').toggleClass('fa-plus-circle').toggleClass('fa-minus-circle')
	}

	function loadDialog(event){
        event.preventDefault();
        var element = $(this);
        var url = element.attr("action") ? element.attr("action") : element.attr("href");

        $("#Modal").load(url, function() {
            $(this).modal('show');
        });
    }

	return new App();
})(jQuery, Utils);

