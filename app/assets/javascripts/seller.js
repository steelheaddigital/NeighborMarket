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

$(document).on("submit", "#new_inventory_item", function(){
    var postData = $(this).serialize();
    var url = $(this).attr("action"); 
    var seller = new Seller();
    
    $("#SellerLoadingImage").show();
    $.ajax({
       type: "POST",
       url: url,
       data: postData,
       cache: false,
       dataType: "html",
       success: function(data){
           $("#SellerContent").html(data);
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
    var postData = $(this).serialize();
    var url = $(this).attr("action");
    var seller = new Seller();
    
    $("#SellerLoadingImage").show();
    $.ajax({
       type: "POST",
       url: url,
       data: postData,
       cache: false,
       dataType: "html",
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
    
    if(deleteConfirm == true){
        $('#InventoryNotice').hide();
        $("#SellerLoadingImage").show();

        $.post(url, {_method: 'delete'}, function() {
               seller.LoadCurrentInventory('seller/current_inventory');
               utils.ShowAlert($("#InventoryNotice"), "Inventory item successfully deleted!");
               $("#SellerLoadingImage").hide();
           }
        );
    }
});

function Seller(){
    
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
            {$("#InventoryNotice").hide();
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
        $('#InventoryNotice').hide();
        $('#SellerContent').load(url);
    }
}
