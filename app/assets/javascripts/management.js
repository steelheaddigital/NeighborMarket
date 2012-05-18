function LoadManagementDialog(url){
    
    $("#Modal").load(url, function() 
        {$("#ManagementNotice").empty();
    }).modal('show');
}

function CloseManagementDialog(){
    $("#Modal").modal('hide');
}

function LoadManagementContent(url, reset){
    $('#ManagementContent').load(url, function(){
        if(reset == true){
            $("#ManagementNotice").empty();
        }   
    });
}

function DeleteCategory(url){
    
    var deleteConfirm = confirm("Are you sure you want to delete this category?");
    
    if(deleteConfirm == true){
        $.post(url, {_method: 'delete'}, function() {
               LoadManagementContent('/management/categories');
               $("#ManagementNotice").html("Category Successfully Deleted");
           }
        );
    }
}

 $(document).on("submit", "#TopLevelCategoryForm", function(event){
     var data = $(this).serialize();
     var url = $(this).attr("action");
     
     $.post(url, data, function(){
         CloseManagementDialog();
         LoadManagementContent('/management/categories');
         $("#ManagementNotice").html("Categories Successfully Updated");
     });
     
     return false;
 });
 
  $(document).on("submit", "#SecondLevelCategoryForm", function(event){
     var data = $(this).serialize();
     var url = $(this).attr("action");
     
     $.post(url, data, function(){
         CloseManagementDialog();
         LoadManagementContent('/management/categories');
         $("#ManagementNotice").html("Categories Successfully Updated");
     });
     
     return false;
 });

 $(document).on("submit", "#EditUserForm", function(event){
     var data = $(this).serialize();
     var url = $(this).attr("action");
     
     $.post(url, data, function(){
         var approveSellers = $("#ApproveSellers");
         
         //if we are on the Approve Sellers screen, then refresh the Approve Seller table
         if(approveSellers.length > 0){
             LoadManagementContent('/management/approve_sellers');
         }
         
         CloseManagementDialog();
         $("#ManagementNotice").html("User Successfully Updated");
     });
     
     return false;
 });
 
$(document).on("change", "#RoleTypeSelect", function(){
    if($(this).val() == "Seller"){
      $("#SellerApprovalStyleLabel").show();
      $("#seller_approval_style").show();
      $("#SellerApprovedLabel").show();
      $("#seller_approved").show();
    }
    else{
      $("#SellerApprovalStyleLabel").hide();
      $("#seller_approval_style").hide();
      $("#SellerApprovedLabel").hide();
      $("#seller_approved").hide();
    }
});

$(document).on("submit", "#UserSearchForm", function(){
   var queryString = $(this).serialize();
   var url = $(this).attr("action");
   $("#ManagerSearchResults").load(url+"?"+queryString);
   return false;
});