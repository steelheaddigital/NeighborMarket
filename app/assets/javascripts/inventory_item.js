function LoadInventoryDialog(url){
    $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;
    
    $("#InventoryModal").load(url, function() 
        {$("#InventoryNotice").empty();
    }).modal('show');
}

function CloseInventoryDialog(){
    $("#InventoryModal").modal('hide');
}

function LoadNewInventory(url){
    $('#InventoryNotice').empty();
    $('#SellerContent').load(url);
}

function LoadCurrentInventory(url){
    $('#InventoryNotice').empty();
    $('#SellerContent').load(url);
}

$(document).on("submit", "#MainSearchForm", function(event) {
   
   event.preventDefault();
   $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;
   
   var url = '/inventory_items/search'
   var postData = $(this).serialize();
   
   $.ajax({
       type: 'GET',
       url: url,
       data: postData,
       cache: false,
       dataType: 'html',
       success: function(data){
           $("#MainContent").html(data);
       }
    });
    return false;
});

$(document).on("change", "#inventory_item_top_level_category_id", function() {

    var url = '/inventory_items/get_second_level_category'
    var data = {category_id:$(this).val()};

    $.get(url ,data, function(data){
      $("#inventory_item_second_level_category_id").empty();
      $("#inventory_item_second_level_category_id").append("<option value=\"\" selected=\"selected\"></option>");
      $.each(data, function(index, value) {
        $("#inventory_item_second_level_category_id").append("<option value = " + value.id + ">" + value.description + "</option>");
      });
      $("#inventory_item_second_level_category_id").removeAttr("disabled");
    });
});


$(document).on("submit", "#NewInventoryItemButton", function(event){
    event.preventDefault();
    
    var url = $(this).attr("action");
    LoadInventoryDialog(url);
    
    return false;
});

$(document).on("submit", "#new_inventory_item", function(){
    var postData = $(this).serialize();
    var url = $(this).attr("action");
    $.ajax({
       type: "POST",
       url: url,
       data: postData,
       cache: false,
       dataType: "html",
       success: function(data){
           $("#SellerContent").html(data);
           LoadCurrentInventory('/seller/current_inventory');
           $("#InventoryNotice").html("Inventory item successfully added!");
           CloseInventoryDialog();
       }   
    });
    return false;
});

$(document).on("submit", "#EditInventoryItemButton", function(event){
    event.preventDefault();
    
    var url = $(this).attr("action");
    LoadInventoryDialog(url);
    
    return false;
});

$(document).on("submit", "#edit_inventory_item", function(){
    var postData = $(this).serialize();
    var url = $(this).attr("action");
    $.ajax({
       type: "POST",
       url: url,
       data: postData,
       cache: false,
       dataType: "html",
       success: function(data){
           $('#InventoryNotice').empty();
           LoadCurrentInventory('/seller/current_inventory');
           $("#InventoryDetail").html(data);
           $("#InventoryNotice").html("Inventory item successfully updated!")
           CloseInventoryDialog();
       }   
    });
    return false;
});
