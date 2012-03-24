function LoadUserDetail(url){
    $("#UserDetail").load(url);
};

 $(document).on("submit", "#EditUserForm", function(event){
     var data = $(this).serialize();;
     var url = $(this).attr("action");
     
     $.post(url, data, function(){
         $("#UserDetail").html("<p class=\"notice\">User Successfully Updated</p>")
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