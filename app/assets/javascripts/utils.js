var utils = {
    ShowAlert: function(message){
		$("#FlashMessages").show();
        $("#FlashAlert").html(message);
    },
    ShowNotice: function(message){
		$("#FlashMessages").show();
        $("#FlashNotice").html(message);
    }
}