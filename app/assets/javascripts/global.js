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

// Always send the authenticity_token with ajax
$(document).ajaxSend(function(event, request, settings) {
    if ( settings.type == 'post' ) {
        settings.data = (settings.data ? settings.data + "&" : "")
                + "authenticity_token=" + encodeURIComponent( AUTH_TOKEN );
        request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    }

	$("#FlashMessages").hide();
	$("#FlashNotice").empty();
	$("#FlashAlert").empty();
});

$(document).ajaxSuccess(function(event, request, settings) {
   	var notice = request.getResponseHeader("X-Notice")
	if(notice){
		utils.ShowNotice(notice);
	} 
	
   	var alert = $.cookie('alert');
	if(alert){
		utils.ShowAlert(alert);
	} 
});

// When I say html I really mean script for rails
$.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;

$(document).ready(function() {
	var length = $.trim($('#FlashNotice').html()) + $.trim($('#FlashAlert').html())
	if(length){
		$('#FlashMessages').show();
	}
	else{
		$('#FlashMessages').hide();
	}
	
	$('.dropdown-submenu').click(function(event){
	     event.stopPropagation();
	 });
});

$(document).on('click', '.collapseIconLink', function(){
	$(this).find('i').toggleClass('fa-plus-circle').toggleClass('fa-minus-circle')
})