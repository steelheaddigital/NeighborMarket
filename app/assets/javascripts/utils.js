var utils = {
    ShowAlert: function(message){
        $("#FlashMessages").html(message).show();
    },
    
    SetActiveNavButton: function(object){
        object.parentsUntil(".nav .nav-pills").siblings().removeClass('active');
        object.parent().addClass('active');
    }
}