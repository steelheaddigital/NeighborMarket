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
    var items = new InventoryItems();
    
    items.LoadInventoryDialog(url);
    
    return false;
});

$(document).on("submit", "#new_inventory_item", function(){
    var postData = $(this).serialize();
    var url = $(this).attr("action"); 
    var items = new InventoryItems();
    
    items.CloseInventoryDialog();
    $("#SellerLoadingImage").show();
    $.ajax({
       type: "POST",
       url: url,
       data: postData,
       cache: false,
       dataType: "html",
       success: function(data){
           $("#SellerContent").html(data);
           items.LoadCurrentInventory('/seller/current_inventory');
           $("#InventoryNotice").html("Inventory item successfully added!").show();
           $("#SellerLoadingImage").hide();
       }   
    });
    return false;
});

$(document).on("submit", ".editInventoryItemButton", function(event){
    event.preventDefault();
    
    var url = $(this).attr("action");
    var items = new InventoryItems();
    
    items.LoadInventoryDialog(url);
    
    return false;
});

$(document).on("submit", ".deleteInventoryItemButton", function(event){
    
    event.preventDefault();
    $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;
    
    var deleteConfirm = confirm("Are you sure you want to delete this item?");
    var url = $(this).attr("action");
    var items = new InventoryItems();
    
    if(deleteConfirm == true){
        $('#InventoryNotice').hide();
        $("#SellerLoadingImage").show();

        $.post(url, {_method: 'delete'}, function() {
               items.LoadCurrentInventory('seller/current_inventory');
               $("#InventoryNotice").html("Item successfully deleted!").show();
               $("#SellerLoadingImage").hide();
           }
        );
    }
});

$(document).on("submit", "#edit_inventory_item", function(){
    var postData = $(this).serialize();
    var url = $(this).attr("action");
    var items = new InventoryItems();
    
    items.CloseInventoryDialog();
    $("#SellerLoadingImage").show();
    $.ajax({
       type: "POST",
       url: url,
       data: postData,
       cache: false,
       dataType: "html",
       success: function(data){
           $('#InventoryNotice').empty();
           items.LoadCurrentInventory('/seller/current_inventory');
           $("#InventoryDetail").html(data);
           $("#InventoryNotice").html("Inventory item successfully updated!").show();
           $("#SellerLoadingImage").hide();
       }   
    });
    return false;
});

function InventoryItems(){
    this.LoadInventoryDialog = function(url){
        $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;

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