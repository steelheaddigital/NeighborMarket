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

$(document).on("submit", "#InboundDeliveryLogForm", function(event){

    event.preventDefault();

    var data = $(this).serialize();
    var url = $(this).attr("action");
    var reloadUrl = '/management/inbound_delivery_log'
    var mgmt = new Management();

    mgmt.SubmitDeliveryLogForm(url, data, reloadUrl);

    return false;
});

$(document).on("submit", "#InventoryItemApprovalForm", function(event){

    event.preventDefault();

    var data = $(this).serialize();
    var url = $(this).attr("action");
	var reloadUrl = '/management/inventory_item_approval'
    var mgmt = new Management();

    mgmt.SubmitInventoryItemApprovalForm(url, data, reloadUrl);

    return false;
});

$(document).on("submit", "#OutboundDeliveryLogForm", function(event){

    event.preventDefault();

    var data = $(this).serialize();
    var url = $(this).attr("action");
    var reloadUrl = '/management/outbound_delivery_log'
    var mgmt = new Management();

    mgmt.SubmitDeliveryLogForm(url, data, reloadUrl);

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

$(document).on("click", ".mgmtNav", function(event){
    event.preventDefault();
    var mgmt = new Management();
    var url = $(this).attr("href")
	
	$("#ManagementLoading").show();
    utils.SetActiveNavButton($(this));
    mgmt.LoadManagementContent(url, true);
    
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

$(document).on("submit", ".deleteTopLevelCategoryButton", function(event){
    event.preventDefault();

    var url = $(this).attr("action");
    var mgmt = new Management();

    mgmt.DeleteCategory(url);

    return false;
});

$(document).on("submit", ".deleteSecondLevelCategoryButton", function(event){
    event.preventDefault();

    var url = $(this).attr("action");
    var mgmt = new Management();

    mgmt.DeleteCategory(url);

    return false;
});

$(document).on("click", ".cycleSettingsSubmit", function(event){
    event.preventDefault()
    var mgmt = new Management();
    if($(this)[0].value === 'Save and Start New Cycle'){
        if(confirm("This will cancel the current cycle and start a new one. All orders for the current cycle will be lost. Do you want to continue?")){
            mgmt.SubmitOrderCycleSettingsForm($(this));
        }
    }
    else{
        mgmt.SubmitOrderCycleSettingsForm($(this));
    }

    return false;
})

$(document).on("submit", "#SiteSettingsForm", function(event){
    event.preventDefault();
    var mgmt = new Management();
    mgmt.SubmitSiteSettingsForm($(this))
    return false;
})

$(document).on("click", ".addNewUserButton", function(event){
    event.preventDefault();

    var url = $(this).attr("href");
    var mgmt = new Management();

    mgmt.LoadManagementDialog(url);

    return false;
});

$(document).on("submit", "#NewUserForm", function(event){
    event.preventDefault();
    var mgmt = new Management();
    mgmt.SubmitNewUserForm($(this))
    return false;
})

$(document).on("submit", "#ManagementEditInventoryItem", function(){
    var mgmt = new Management();
    
    $("#ManagementLoading").show();
    $(this).ajaxSubmit({
       dataType: "html",
       //Remove the file input if it's empty so paperclip doesn't choke
       beforeSerialize: function() {
           if($("#inventory_item_photo").val() === ""){
               $("#inventory_item_photo").remove();
           }
       },
       success: function(data){
		   mgmt.LoadManagementContent('/management/inventory')
           utils.ShowAlert($("#ManagementNotice"), "Inventory item successfully updated!");
           $("#ManagementLoading").hide();
           $("#InventoryModal").modal('hide');
       },
       error: function(request){
           $("#ManagementLoading").hide();
           $("#Modal").html(request.responseText).modal('show');
       }
    });
    return false;
});

$(document).on("click", "#mgmtEditInventoryItemButton", function(event){
    event.preventDefault();
    var url = $(this).attr("href");

    $("#Modal").load(url).modal('show');    
    
    return false;
});

$(document).on("submit", ".mgmtDeleteInventoryItemButton", function(event){
    event.preventDefault();
    
    var deleteConfirm = confirm("Are you sure you want to delete this item?");
    var url = $(this).attr("action");
    var mgmt = new Management();
    
    if(deleteConfirm === true){
        $("#ManagementLoading").show();

        $.post(url, {_method: 'delete'}, function() {
               mgmt.LoadManagementContent('/management/inventory');
			   utils.ShowAlert($("#ManagementNotice"), "Inventory item successfully deleted!");
               $("#ManagementLoading").hide();
           }
        );
    }
	
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

	this.SubmitHistoricalOrdersForm = function(form){
		$("#ManagementLoading").show();
        form.ajaxSubmit({
           dataType: "html",
           success: function(content){
			 $("#HistoricalOrdersReportContent").html(content);
             $("#ManagementLoading").hide();
           },
           error: function(request){
            $("#ManagementLoading").hide();
			$("#HistoricalOrdersReportContent").html(request.responseText).modal('show');
           }
        });
	}

    this.SubmitNewUserForm = function(form){
        $("#ManagementLoading").show();
        form.ajaxSubmit({
           dataType: "html",
           success: function(){
             self.CloseManagementDialog();
             utils.ShowAlert($("#ManagementNotice"), "User successfully added!")
             $("#ManagementLoading").hide();
           },
           error: function(request){
            $("#ManagementLoading").hide();
			$("#Modal").html(request.responseText).modal('show');
           }
        });
    }

    this.SubmitOrderCycleSettingsForm = function(button){
        $("#ManagementLoading").show();
        var input = $("<input type='hidden' />").attr("name", button[0].name).attr("value", button[0].value);
        button.closest('form').append(input);
        var form = button.closest('form');
        form.ajaxSubmit({
           dataType: "html",
           success: function(){
             self.LoadManagementContent('/order_cycle/edit');
             self.CloseManagementDialog();
             utils.ShowAlert($("#ManagementNotice"), "Order cycle settings successfully updated!")
             $("#ManagementLoading").hide();
           },
           error: function(request){
            $("#ManagementLoading").hide();
            $("#ManagementContent").html(request.responseText);
           }
        });
    }
    
    this.SubmitSiteSettingsForm = function(form){
        $("#ManagementLoading").show();
        form.ajaxSubmit({
           dataType: "html",
           success: function(){
             self.LoadManagementContent('/site_setting/edit');
             self.CloseManagementDialog();
             utils.ShowAlert($("#ManagementNotice"), "Site settings successfully updated!")
             $("#ManagementLoading").hide();
           },
           error: function(request){
            $("#ManagementLoading").hide();
            $("#ManagementContent").html(request.responseText);
           }
        });
    }
 
    this.SubmitCategoryForm = function(url, data){
       $.ajax({
           type: "POST",
           url: url,
           data: data,
           cache: false,
           dataType: "html",
           success: function(){
             self.LoadManagementContent('/management/categories');
             self.CloseManagementDialog();
             utils.ShowAlert($("#ManagementNotice"), "Categories successfully updated!")
             $("#ManagementLoading").hide();
           },
           error: function(request){
            $("#Modal").html(request.responseText).modal('show');
			$("#ManagementLoading").hide();
           }
        });
    }
    
    this.SubmitDeliveryLogForm = function(url, data, reloadUrl){
        $("#ManagementLoading").show();
        $.ajax({
           type: "POST",
           url: url,
           data: data,
           cache: false,
           dataType: "html",
           success: function(){
             self.LoadManagementContent(reloadUrl);
             utils.ShowAlert($("#ManagementNotice"), "Delivery log successfully updated!")
             $("#ManagementLoading").hide();
           },
           error: function(){
            utils.ShowAlert($("#ManagementNotice"), "Delivery log could not be updated.");
			$("#ManagementLoading").hide();
           }
        });
    }

    this.SubmitInventoryItemApprovalForm = function(url, data, reloadUrl){
        $("#ManagementLoading").show();
        $.ajax({
           type: "POST",
           url: url,
           data: data,
           cache: false,
           dataType: "html",
           success: function(content){
			 self.LoadManagementContent(reloadUrl);
             utils.ShowAlert($("#ManagementNotice"), "Inventory items successfully updated!");
             $("#ManagementLoading").hide();
           },
           error: function(){
            utils.ShowAlert($("#ManagementNotice"), "Inventory items could not be updated.");
           }
        });
    }
    
    this.SubmitEditUsersForm = function(url, data){
        $("#ManagementLoading").show();
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
                 self.LoadManagementContent('/management/approve_sellers');
             }

             utils.ShowAlert($("#ManagementNotice"), "User successfully updated!");
             $("#ManagementLoading").hide();
           },
           error: function(){
            $("#ManagementLoading").hide();
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

    this.LoadManagementContent = function(url, reset){

        $('#ManagementContent').load(url, function(){
            if(reset == true){
                $("#ManagementNotice").hide();
            }
			$("#ManagementLoading").hide();
        });
    }

    this.DeleteCategory = function(url){

        var deleteConfirm = confirm("WARNING! This will delete the category and any seller inventory items in the category. Are you sure?");

        if(deleteConfirm == true){
            $("#ManagementLoading").show();
            
            $.post(url, {_method: 'delete'}, function() {
                   self.LoadManagementContent('/management/categories', false);
                   $("#ManagementNotice").append("Category successfully deleted!").show();
                   $("#ManagementLoading").hide();
               }
            );
        }
    }
}