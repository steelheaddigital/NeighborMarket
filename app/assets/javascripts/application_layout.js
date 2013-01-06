$(document).ready(function() {
	var length = $.trim($('#FlashMessages').html())
	if(length){
		$('#FlashMessages').show();
	}
	else{
		$('#FlashMessages').hide();
	}
});


