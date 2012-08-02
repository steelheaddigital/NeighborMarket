$(document).on("submit", ".addToCartButton", function(event){
    event.preventDefault();
    
    var url = $(this).attr("action");
    var data = $(this).serialize();
    
    $.ajax({
       type: 'POST',
       url: url,
       data: data,
       dataType: 'html',
       success: function(data){
           utils.ShowAlert($("#AddToCartNotice"), "Item added to your cart!")
           var cart = new Cart();
           cart.GetCount();
       },
       error: function(xhr, status, error){
           utils.ShowAlert($("#AddToCartNotice"), xhr.responseText)
       }
    });
    
    return false;
});

$(document).on("click", ".deleteCartItemButton", function(event){
    event.preventDefault();
    
    var deleteConfirm = confirm("Are you sure you want to delete this item?");
    var url = $(this).attr("href");
    
    if(deleteConfirm === true){
        $.get(url, function() {
                var cart = new Cart();
                cart.LoadCart();
                cart.GetCount();
           }
        );
    }
    
    return false;
});

function Cart(){
    this.LoadCart = function(){
        $("#MainContent").load("/cart");
    }
    
    this.GetCount = function() {
        $.getJSON("/cart/item_count", function(data){
            $("#CartCount").html(data);
        });
    }
}