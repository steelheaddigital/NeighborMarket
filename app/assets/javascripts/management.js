/*
Copyright 2013 Neighbor Market

This file is part of Neighbor Market.

Neighbor Market is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Neighbor Market is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Neighbor Market.  If not, see <http://www.gnu.org/licenses/>.
*/

//= require ./lib/jquery.form
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require summernote
//= require inventory_items

(function($, utils) {
    
    function Management() {
        init();
    }

    function init() {
        $(document).on("click", "#RecurringOrderCycleCheckBox", function(){
            $("#RecurringOrderCycleSettings").toggleClass("hidden")
        });

        $(document).on("change", "#RoleTypeSelect", function(){
            roleTypeSelect.call(this);
        });

        $(document).on("submit", "#UserSearchForm", function(event){
            submitUserSearchForm.call(this, event)
        });

        $(document).on("click", "#PreviewHistoricalOrdersSubmit", function(event){
            submitHistoricalOrdersForm.call(this, event);
        });

        $(document).on('click', '[data-toggle="show"]', function() {
            showPaymentProcessorSettings.call(this);
        });

        $(document).on("submit", "#TopLevelCategoryForm", function(event){
            submitCategoryForm.call(this, event);
        });

        $(document).on("submit", "#SecondLevelCategoryForm", function(event){
            submitCategoryForm.call(this, event);
        });
    }

    function roleTypeSelect(){
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
    }

    function submitUserSearchForm(event){
        event.preventDefault();
        var queryString = $(this).serialize(),
        url = $(this).attr("action")

        $("#ManagerSearchResults").empty();
        $("#ManagerSearchResultsLoading").show();

        $("#ManagerSearchResults").load(url+"?"+queryString, function(){
            $("#ManagerSearchResultsLoading").hide();
        });
    }

    function submitHistoricalOrdersForm(event){
        event.preventDefault();
        var form = $(this).closest("form")
        url = form.attr("action")

        $("#HistoricalOrdersLoading").show();
        form.ajaxSubmit({
           dataType: "html",
           success: function(content){
             $("#HistoricalOrdersReportContent").html(content);
             $("#HistoricalOrdersLoading").hide();
           },
           error: function(request){
            $("#HistoricalOrdersLoading").hide();
            $("#HistoricalOrdersReportContent").html(request.responseText).modal('show');
           }
        });
    }

    function showPaymentProcessorSettings(){
        var target = "#" + $(this).data("target");
        var toHide = $(".payment-processor-setting-container").not(target);

        $(target + ' :input').prop('disabled', false);
        toHide.find(':input').prop('disabled', true);
        toHide.addClass('hidden');
        $(target).removeClass('hidden');
    }

    function submitCategoryForm(event){
        event.preventDefault();
        var form = $(this);
        
        submitButton = form.find(':submit');
        submitButton.attr('disabled', 'disabled');
        submitButton.attr('value', "Saving...");
        form.ajaxSubmit({
            cache: false,
            dataType: "html",
            success: function(data){
                utils.closeDialog();
                $('#ManagementContent').html(data);
            },
            error: function(request){
                $("#Modal").html(request.responseText).modal('show');
            }
        });
    }


    return new Management();

})(jQuery, Utils);

