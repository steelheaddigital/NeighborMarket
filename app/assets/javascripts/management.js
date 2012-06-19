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
    $("#ManagementLoading").show();
    $.post(url, data, function(){
     var approveSellers = $("#ApproveSellers");

     //if we are on the Approve Sellers screen, then refresh the Approve Seller table
     if(approveSellers.length > 0){
         mgmt.LoadManagementContent('/management/approve_sellers');
     }

     $("#ManagementNotice").html("User successfully updated!").show();
     $("#ManagementLoading").hide();
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
    event.preventDefault();
    $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;

    var queryString = $(this).serialize();
    var url = $(this).attr("action");

    $("#ManagerSearchResults").empty();
    $("#ManagerSearchResultsLoading").show();

    $("#ManagerSearchResults").load(url+"?"+queryString, function(){
        $("#ManagerSearchResultsLoading").hide();
    });

    return false;
});

$(document).on("click", "#UserSearchNav", function(event){
    event.preventDefault();
    var url = $(this).attr("href")
    var mgmt = new Management();

    mgmt.SetActiveNavButton($(this));
    mgmt.LoadManagementContent(url, true);

    return false;
});

$(document).on("click", "#ApproveSellersNav", function(event){
    event.preventDefault();

    var url = $(this).attr("href")
    var mgmt = new Management();

    mgmt.SetActiveNavButton($(this));
    mgmt.LoadManagementContent(url, true);

    return false;
});

$(document).on("click", "#ManageCategoriesNav", function(event){
    event.preventDefault();

    var url = $(this).attr("href")
    var mgmt = new Management();

    mgmt.SetActiveNavButton($(this));
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

function Management(){
 
    var self = this;
 
    this.SubmitCategoryForm = function(url, data){
       $.ajax({
           type: "POST",
           url: url,
           data: data,
           cache: false,
           dataType: "html",
           success: function(){
             mgmt.LoadManagementContent('/management/categories');
             mgmt.CloseManagementDialog();
             $("#ManagementNotice").html("Categories successfully updated!").show();
             $("#ManagementLoading").hide();
           },
           error: function(request){
            $("#Modal").html(request.responseText).modal('show');
           }
        });
    }
    
    this.LoadManagementDialog = function(url){
        $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;

        $("#Modal").load(url, function() 
            {$("#ManagementNotice").hide();
        }).modal('show');
    }

    this.CloseManagementDialog = function(){
        $("#Modal").modal('hide');
    }

    this.LoadManagementContent = function(url, reset){
        $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;

        $('#ManagementContent').load(url, function(){
            if(reset == true){
                $("#ManagementNotice").hide();
            }   
        });
    }

    this.DeleteCategory = function(url){

        var deleteConfirm = confirm("WARNING! This will delete the category and any seller inventory items in the category. Are you sure?");

        if(deleteConfirm == true){
            $("#ManagementLoading").show();
            
            $.post(url, {_method: 'delete'}, function() {
                   self.LoadManagementContent('/management/categories', false);
                   $("#ManagementNotice").html("Category successfully deleted!").show();
                   $("#ManagementLoading").hide();
               }
            );
        }
    }
    
    this.SetActiveNavButton = function(object){
        object.parent().siblings().removeClass('active');
        object.parent().addClass('active');
    }
}