$(document).on("click", ".sellerNav", function(event){
    event.preventDefault();
    var url = $(this).attr("href")
    var seller = new Seller();

    utils.SetActiveNavButton($(this));
    seller.LoadSellerContent(url, true);

    return false;
});


$(document).on("change", "#inventory_item_top_level_category_id", function() {

    var url = '/inventory_items/get_second_level_category'
    var data = {category_id:$(this).val()};

    $.get(url ,data, function(data){
      $("#inventory_item_second_level_category_id").empty();
      $("#inventory_item_second_level_category_id").append("<option value=\"\" selected=\"selected\"></option>");
      $.each(data, function(index, value) {
        $("#inventory_item_second_level_category_id").append("<option value = " + value.id + ">" + value.name + "</option>");
      });
      $("#inventory_item_second_level_category_id").removeAttr("disabled");
    });
});


$(document).on("submit", "#NewInventoryItemButton", function(event){
    event.preventDefault();
    
    var url = $(this).attr("action");
    var seller = new Seller();
    
    seller.LoadInventoryDialog(url);
    
    return false;
});

$(document).on("submit", ".sellerListDatePicker", function(event){
	event.preventDefault();
	
	$("#SellerLoadingImage").show();
    $(this).ajaxSubmit({
       dataType: "html",
       success: function(response){
		
		
		$("#SellerContent").html(response);
        $("#SellerLoadingImage").hide();
       },
       error: function(request){
        $("#SellerLoadingImage").hide();
        $("#SellerContent").html(request.responseText);
       }
    });
});

$(document).on("submit", "#new_inventory_item", function(){
    var seller = new Seller();
    
    $("#SellerLoadingImage").show();
    $(this).ajaxSubmit({
       dataType: "html",
       //Remove the file input if it's empty so paperclip doesn't choke'
       beforeSerialize: function() {
           if($("#inventory_item_photo").val() === ""){
               $("#inventory_item_photo").remove();
           }
       },
       success: function(data){
           seller.LoadCurrentInventory('/seller/current_inventory');
           utils.ShowAlert($("#InventoryNotice"), "Inventory item successfully added!");
           $("#SellerLoadingImage").hide();
           seller.CloseInventoryDialog();
       },
       error: function(request){
           $("#SellerLoadingImage").hide();
           $("#InventoryModal").html(request.responseText).modal('show');
       }
    });
    return false;
});

$(document).on("submit", "#edit_inventory_item", function(){
    var seller = new Seller();
    
    $("#SellerLoadingImage").show();
    $(this).ajaxSubmit({
       dataType: "html",
       //Remove the file input if it's empty so paperclip doesn't choke
       beforeSerialize: function() {
           if($("#inventory_item_photo").val() === ""){
               $("#inventory_item_photo").remove();
           }
       },
       success: function(data){
           $('#InventoryNotice').empty();
           seller.LoadCurrentInventory('/seller/current_inventory');
           $("#InventoryDetail").html(data);
           utils.ShowAlert($("#InventoryNotice"), "Inventory item successfully updated!");
           $("#SellerLoadingImage").hide();
           seller.CloseInventoryDialog();
       },
       error: function(request){
           $("#SellerLoadingImage").hide();
           $("#InventoryModal").html(request.responseText).modal('show');
       }
    });
    return false;
});

$(document).on("submit", ".editInventoryItemButton", function(event){
    event.preventDefault();
    
    var url = $(this).attr("action");
    var seller = new Seller();
    
    seller.LoadInventoryDialog(url);
    
    return false;
});

$(document).on("submit", ".deleteInventoryItemButton", function(event){
    event.preventDefault();
    
    var deleteConfirm = confirm("Are you sure you want to delete this item?");
    var url = $(this).attr("action");
    var seller = new Seller();
    
    if(deleteConfirm === true){
        $('#InventoryNotice').hide();
        $("#SellerLoadingImage").show();

        $.post(url, {_method: 'delete'}, function() {
               seller.LoadCurrentInventory('seller/current_inventory');
               utils.ShowAlert($("#SellerNotice"), "Inventory item successfully deleted!");
               $("#SellerLoadingImage").hide();
           }
        );
    }
	
	return false;
});

$(document).on("click", ".sellerDeleteOrderItem", function(event){
	event.preventDefault();
    var deleteConfirm = confirm("Are you sure you want to delete this item?");
    var url = $(this).attr("href");
    
    if(deleteConfirm === true){
        $('#InventoryNotice').hide();
        $("#SellerLoadingImage").show();
		
        $.post(url, {_method: 'delete'}, function() {
               $("#SellerContent").load('/seller/packing_list');
               utils.ShowAlert($("#SellerNotice"), "Item successfully deleted!");
               $("#SellerLoadingImage").hide();
           }
        );
    }
	
	return false;
});

$(document).on("click", ".sellerUpdateOrderSubmit", function(event){
    event.preventDefault()
    var seller = new Seller();
    if($(this)[0].value === 'Delete All Items'){
        if(confirm("Are you sure you want to delete all items in this order?")){
            seller.SubmitEditOrderForm($(this));
        }
    }
    else{
        seller.SubmitEditOrderForm($(this));
    }

    return false;

})

function Seller(){
    
    this.SubmitEditOrderForm = function(button){
        $("#SellerLoadingImage").show();
        var input = $("<input type='hidden' />").attr("name", button[0].name).attr("value", button[0].value);
        button.closest('form').append(input);
        var form = button.closest('form');
        form.ajaxSubmit({
           dataType: "html",
           success: function(){
	         $("#SellerContent").load('/seller/packing_list');
             utils.ShowAlert($("#SellerNotice"), "Order successfully updated!")
             $("#SellerLoadingImage").hide();
           },
           error: function(request){
            $("#SellerLoadingImage").hide();
            $("#SellerContent").html(request.responseText);
           }
        });
    }
	
    this.LoadSellerContent = function(url, reset){
        $("#SellerLoadingImage").show();
        
        $('#SellerContent').load(url, function(){
            if(reset == true){
                $("#SellerNotice").hide();
                $("#SellerLoadingImage").hide();
            }   
        }); 
    }
    
    this.LoadInventoryDialog = function(url){
        $("#InventoryModal").load(url, function() 
            {$("#SellerNotice").hide();
        }).modal('show');
    }

    this.CloseInventoryDialog = function(){
        $("#InventoryModal").modal('hide');
    }

    this.LoadNewInventory = function(url){
        $('#InventoryNotice').hide();
        $('#SellerContent').load(url);
    }

    this.LoadCurrentInventory = function(url){
        $('SellerNotice').hide();
        $('#SellerContent').load(url);
    }
}
