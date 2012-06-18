$(document).on("submit", ".addToCartButton", function(event){
    event.preventDefault();
    
    var url = $(this).attr("action");
    var data = $(this).serialize();
    
    $.ajax({
       type: "POST",
       url: url,
       data: data,
       success: function(data){
           $("#AddToCartNotice").html("Item added to your cart!").show();
       },
       error: function(request){

       }
    });
    
    $.post(url, function() {
           $("#AddToCartNotice").html("Item added to your cart!").show();
       }
    );
    
    return false;
});