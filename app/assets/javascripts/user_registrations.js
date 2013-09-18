$(document).on("click", "#TermsOfServiceLink", function(event){
    event.preventDefault();
	var url = $(this).attr('href')
	
    $("#Modal").load(url, function() {
		$(this).modal('show');
    });
		
	return false;
});