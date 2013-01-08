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
    seller.SubmitInventoryItemForm($(this));
    return false;
});

$(document).on("submit", "#edit_inventory_item", function(){
    var seller = new Seller();
	seller.SubmitInventoryItemForm($(this));
    return false;
});

$(document).on("submit", ".editInventoryItemButton", function(event){
    event.preventDefault();
    
    var url = $(this).attr("action");
    var seller = new Seller();
    
    seller.LoadInventoryDialog(url);
    
    return false;
});

$(document).on("click", ".sellerDeleteOrderItem", function(event){
	event.preventDefault();
    var deleteConfirm = confirm("Are you sure you want to delete this item?");
    var url = $(this).attr("href");
    
    if(deleteConfirm === true){
        $('#InventoryNotice').hide();
        $("#SellerLoadingImage").show();
		
        $.post(url, {_method: 'delete'}, function(content) {
               $("#SellerContent").load('/seller/packing_list');
               utils.ShowAlert("Item successfully deleted!");
               $("#SellerLoadingImage").hide();
           }
        );
    }
	
	return false;
});

function Seller(){
	
	var self = this;
	
    this.SubmitInventoryItemForm = function(form){
		form.ajaxSubmit({
	       dataType: "html",
	       //Remove the file input if it's empty so paperclip doesn't choke
	       beforeSerialize: function() {
	           if($("#inventory_item_photo").val() === ""){
	               $("#inventory_item_photo").remove();
	           }
	       },
	       success: function(data){
	           utils.ShowAlert("Inventory item successfully updated!");
	           self.CloseInventoryDialog();
			   $("#SellerContent").html(data);
	       },
	       error: function(request){
	           $("#InventoryModal").html(request.responseText).modal('show');
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
