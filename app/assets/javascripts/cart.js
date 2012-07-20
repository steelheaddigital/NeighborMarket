$(document).on("submit", ".addToCartButton", function(event){
    event.preventDefault();
    
    var url = $(this).attr("action");
    var data = $(this).serialize();
    
    $.post(url, data, function() {
           utils.ShowAlert($("#AddToCartNotice"), "Item added to your cart!")
           var cart = new Cart();
           cart.GetCount();
       }
    );
    
    return false;
});

$(document).on("click", ".deleteCartItemButton", function(event){
    
    event.preventDefault();
    $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;
    
    var deleteConfirm = confirm("Are you sure you want to delete this item?");
    var url = $(this).attr("href");
    
    if(deleteConfirm == true){
        $.post(url, {_method: 'delete'}, function() {
                var cart = new Cart();
                cart.LoadCart();
                cart.GetCount();
           }
        );
    }
});

function Cart(){
    $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;
    
    this.LoadCart = function(){
        $("#MainContent").load("/cart");
    }
    
    this.GetCount = function() {
        $.getJSON("/cart/item_count", function(data){
            $("#CartCount").html(data);
        });
    }
}