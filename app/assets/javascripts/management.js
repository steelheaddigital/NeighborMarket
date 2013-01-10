$(document).on("click", "#order_cycle_setting_recurring", function(){
	$("#OrderCycleEndDateContainer").toggleClass("hidden")
});

$(document).on("submit", "#TopLevelCategoryForm", function(event){

    event.preventDefault();

    var data = $(this).serialize();
    var url = $(this).attr("action");
    var mgmt = new Management();

    mgmt.SubmitCategoryForm(url, data);

    return false;
});

$(document).on("submit", "#SecondLevelCategoryForm", function(event){

    event.preventDefault();

    var data = $(this).serialize();
    var url = $(this).attr("action");
    var mgmt = new Management();

    mgmt.SubmitCategoryForm(url, data);

    return false;
});

$(document).on("submit", "#EditUserForm", function(event){
    event.preventDefault();

    var data = $(this).serialize();
    var url = $(this).attr("action");
    var mgmt = new Management();

    mgmt.CloseManagementDialog();
    mgmt.SubmitEditUsersForm(url, data)

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

$(document).on("submit", "#UserSearchForm", function(event){
    event.preventDefault();

    var queryString = $(this).serialize();
    var url = $(this).attr("action");

    $("#ManagerSearchResults").empty();
    $("#ManagerSearchResultsLoading").show();

    $("#ManagerSearchResults").load(url+"?"+queryString, function(){
        $("#ManagerSearchResultsLoading").hide();
    });

    return false;
});

$(document).on("submit", ".editUsersButton", function(event){
    event.preventDefault();

    var url = $(this).attr("action");
    var mgmt = new Management();

    mgmt.LoadManagementDialog(url);

    return false;
});

$(document).on("submit", "#NewTopLevelCategoryButton", function(event){
    event.preventDefault();

    var url = $(this).attr("action");
    var mgmt = new Management();

    mgmt.LoadManagementDialog(url);

    return false;
});

$(document).on("submit", ".newSecondLevelCategoryButton", function(event){
    event.preventDefault();

    var url = $(this).attr("action");
    var mgmt = new Management();

    mgmt.LoadManagementDialog(url);

    return false;
});

$(document).on("submit", ".editTopLevelCategoryButton", function(event){
    event.preventDefault();

    var url = $(this).attr("action");
    var mgmt = new Management();

    mgmt.LoadManagementDialog(url);

    return false;
});

$(document).on("submit", ".editSecondLevelCategoryButton", function(event){
    event.preventDefault();

    var url = $(this).attr("action");
    var mgmt = new Management();

    mgmt.LoadManagementDialog(url);

    return false;
});

$(document).on("submit", "#ManagementEditInventoryItem", function(){
	event.preventDefault();
    var mgmt = new Management();
    mgmt.SubmitEditInventoryItem($(this))
    return false;
});

$(document).on("click", "#mgmtEditInventoryItemButton", function(event){
    event.preventDefault();
    var url = $(this).attr("href");

    $("#Modal").load(url).modal('show');    
    
    return false;
});

$(document).on("click", "#PreviewHistoricalOrdersSubmit", function(event){
    event.preventDefault();
    
	var form = $(this).closest("form")
    var url = form.attr("action");
    var mgmt = new Management();
    
	mgmt.SubmitHistoricalOrdersForm(form)
		
	return false;
});


function Management(){
 
    var self = this;

	this.SubmitEditInventoryItem = function(form){
		form.ajaxSubmit({
	       dataType: "html",
	       //Remove the file input if it's empty so paperclip doesn't choke
	       beforeSerialize: function() {
	           if($("#inventory_item_photo").val() === ""){
	               $("#inventory_item_photo").remove();
	           }
	       },
	       success: function(data){
			   $("#ManagementContent").html(data);
			   self.CloseManagementDialog();
	           utils.ShowAlert("Inventory item successfully updated!");
	       },
	       error: function(request){
	           $("#Modal").html(request.responseText).modal('show');
	       }
	    });
	};
 
    this.SubmitCategoryForm = function(url, data){
       $.ajax({
           type: "POST",
           url: url,
           data: data,
           cache: false,
           dataType: "html",
           success: function(data){
             self.CloseManagementDialog();
			 $('#ManagementContent').html(data);
             utils.ShowAlert("Categories successfully updated!")
             $("#ManagementLoading").hide();
           },
           error: function(request){
            $("#Modal").html(request.responseText).modal('show');
			$("#ManagementLoading").hide();
           }
        });
    }
    
    this.SubmitEditUsersForm = function(url, data){
        $.ajax({
           type: "POST",
           url: url,
           data: data,
           cache: false,
           dataType: "html",
           success: function(){
             var approveSellers = $("#ApproveSellers");
             //if we are on the Approve Sellers screen, then refresh the Approve Seller table
             if(approveSellers.length > 0){
				$('#ManagementContent').load('/management/approve_sellers');
             }
             utils.ShowAlert("User successfully updated!");
           },
           error: function(request){
			$("#Modal").html(request.responseText).modal('show');
           }
        });
    }
    
    this.LoadManagementDialog = function(url){
        $("#Modal").load(url, function() 
            {$("#ManagementNotice").hide();
        }).modal('show');
    }

    this.CloseManagementDialog = function(){
        $("#Modal").modal('hide');
    }
}