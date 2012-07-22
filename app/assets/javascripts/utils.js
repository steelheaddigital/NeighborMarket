var utils = {
    ShowAlert: function(alertElement, message){
        alertElement.html(message).show();
        $(alertElement).delay(4000).fadeOut("slow", function () { $(this).hide(); });
    },
    
    SetActiveNavButton: function(object){
        object.parent().siblings().removeClass('active');
        object.parent().addClass('active');
    }
}