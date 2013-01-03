$(document).ready(function() {
	var length = $.trim($('#FlashMessages').html())
	if(length){
		$('#FlashMessages').show();
	}
	else{
		$('#FlashMessages').hide();
	}
});

$(document).on("click", ".secondLevelBrowseMenu", function(event){
   event.preventDefault();
   
   var url = $(this).attr("href")
   
   $("#MainContent").empty();
   $("#Loading").show();
   
   $.ajax({
       type: 'GET',
       url: url,
       cache: false,
       dataType: 'html',
       success: function(data){
           $("#MainContent").html(data);
           $("#Loading").hide();
       }
    });
    return false;
   
});

$(document).on("submit", "#MainSearchForm", function(event) {
   event.preventDefault();
   
   var url = '/inventory_items/search'
   var postData = $(this).serialize();
   
   $("#MainContent").empty();
   $("#Loading").show();
   
   $.ajax({
       type: 'GET',
       url: url,
       data: postData,
       cache: false,
       dataType: 'html',
       success: function(data){
           $("#MainContent").html(data);
           $("#Loading").hide();
       }
    });
    return false;
});
