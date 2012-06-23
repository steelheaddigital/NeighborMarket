var utils = {
    ShowAlert: function(alertElement, message){
        alertElement.html(message).show();
        $(alertElement).delay(4000).fadeOut("slow", function () { $(this).hide(); });
    }
}