$(document).on("submit", ".addToCartButton", function(event){
    event.preventDefault();
    
    var url = $(this).attr("action");
    var data = $(this).serialize();
    
    $.post(url, data, function() {
           $("#AddToCartNotice").html("Item added to your cart!").show();
       }
    );
    
    return false;
});