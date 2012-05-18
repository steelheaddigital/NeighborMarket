function LoadInventoryDialog(url){
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
  
function DeleteInventoryItem(url){
    var deleteConfirm = confirm("Are you sure you want to delete this inventory item?");
    if (deleteConfirm == true){
        $.post(url, {_method: 'delete'}, function(){
            $("#InventoryNotice").html("Inventory item successfully deleted!");
            var url = '/seller/current_inventory'
            $('#SellerContent').load(url);
        });
    }
}


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
           $("#InventoryNotice").html("Inventory item successfully added!")
       }   
    });
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
           var url = '/seller/current_inventory'
           $('#InventoryNotice').empty();
           LoadCurrentInventory(url);
           $("#InventoryDetail").html(data);
           $("#InventoryNotice").html("Inventory item successfully updated!")
           CloseInventoryDialog();
       }   
    });
    return false;
});
