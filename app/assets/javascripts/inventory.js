function LoadNewInventory(url){
    $('#InventoryNotice').empty();
    $('#SellerContent').load(url);
}

function LoadCurrentInventory(url){
    $('#InventoryNotice').empty();
    $('#SellerContent').load(url);
}
  
function LoadInventoryDetail(url){
    $('#InventoryNotice').empty();
    $("#InventoryDetail").load(url);
}

function DeleteInventoryItem(url){
    var deleteConfirm = confirm("Are you sure you want to delete this inventory item?");
    if (deleteConfirm == true){
        $.post(url, {_method: 'delete'}, function(){
            RefreshInventory();
        });
    }
}

function RefreshInventory(){
    var url = '/seller/current_inventory'
    LoadCurrentInventory(url);
}

$(document).on("change", "#inventory_top_level_category_id", function() {

    var url = '/inventories/get_second_level_category'
    var data = {category_id:$(this).val()};

    $.get(url ,data, function(data){
      $("#inventory_second_level_category_id").empty();
      $("#inventory_second_level_category_id").append("<option value=\"\" selected=\"selected\"></option>");
      $.each(data, function(index, value) {
        $("#inventory_second_level_category_id").append("<option value = " + value.id + ">" + value.description + "</option>");
      });
      $("#inventory_second_level_category_id").removeAttr("disabled");
    });
});

$(document).on("submit", "#new_inventory", function(){
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
       },
       error: function() { 
           alert("Error");
       }
           
    });
    return false;
});

$(document).on("submit", "#edit_inventory", function(){
    var postData = $(this).serialize();
    var url = $(this).attr("action");
    $.ajax({
       type: "POST",
       url: url,
       data: postData,
       cache: false,
       dataType: "html",
       success: function(data){
           RefreshInventory();
           $("#InventoryDetail").html(data);
           $("#InventoryNotice").html("Inventory item successfully updated!")
       },
       error: function() { 
           alert("Error editing inventory");
       }
           
    });
    return false;
});
