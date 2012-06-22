$(document).on("submit", ".addToCartButton", function(event){
    event.preventDefault();
    
    var url = $(this).attr("action");
    var data = $(this).serialize();
    
    $.post(url, data, function() {
           utils.ShowAlert($("#AddToCartNotice"), "Item added to your cart!")
       }
    );
    
    return false;
});

$(document).on("submit", ".deleteCartItemButton", function(event){
    
    event.preventDefault();
    $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;
    
    var deleteConfirm = confirm("Are you sure you want to delete this item?");
    var url = $(this).attr("action");
    var items = new InventoryItems();
    
    if(deleteConfirm == true){
        $.post(url, {_method: 'delete'}, function() {
                var cart = new Cart();
                cart.LoadCart();
           }
        );
    }
});

function Cart(){
    $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;
    this.LoadCart = function(){
        $("#MainContent").load("/cart");
    }

}