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
});