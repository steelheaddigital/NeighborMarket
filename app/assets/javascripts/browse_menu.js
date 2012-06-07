$(document).on("click", ".secondLevelBrowseMenu", function(event){
   event.preventDefault();
   var url = $(this).attr("href")
   
   $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;
   
   $("#MainContent").empty();
   
   $.ajax({
       type: 'GET',
       url: url,
       cache: false,
       dataType: 'html',
       success: function(data){
           $("#MainContent").html(data);
       }
    });
    return false;
   
});


