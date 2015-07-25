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

$(document).on("change", "#inventory_item_top_level_category_id", function() {
    var data = {category_id:$(this).val()},
	 	seller = new Seller()
	
	seller.GetSecondLevelCategories(data);
});

$(document).on("click", "#SelectAllInventoryItems", function() {
	var rows = $(this).parents("table").find("tbody").find("tr");
	
	//Toggle the checkbox for each row in the table
	rows.each(function(){
		$(this).find("td:first")
			   .children(":first")
			   .attr('checked', function(idx, oldAttr) {
			            return !oldAttr;
			        })
	});
	
});

$(document).on("submit", "#NewInventoryItemButton", function(event){
    event.preventDefault();
    var url = $(this).attr("action"),
     	seller = new Seller()
    
    seller.LoadInventoryDialog(url);
    
    return false;
});

$(document).on("submit", "#new_inventory_item", function(){
    var seller = new Seller();
    seller.SubmitInventoryItemForm($(this));
    return false;
});

$(document).on("submit", "#edit_inventory_item", function(){
    var seller = new Seller();
	seller.SubmitInventoryItemForm($(this));
    return false;
});

$(document).on("click", ".editInventoryItemButton", function(event){
    event.preventDefault();
    var url = $(this).attr("href"),
     	seller = new Seller()
    
    seller.LoadInventoryDialog(url);
    
    return false;
});

$(document).on("click", "#PreviewSalesReportSubmit", function(event){
    event.preventDefault();
	var form = $(this).closest("form"),
     	url = form.attr("action"),
    	seller = new Seller()
    
	seller.SubmitSalesReportForm(form)
		
	return false;
});

function Seller(){
	
	var self = this;
	
	this.SubmitSalesReportForm = function(form){
		$("#SalesReportLoading").show();
        form.ajaxSubmit({
           dataType: "html",
           success: function(content){
			 $("#SalesReportContent").html(content);
             $("#SalesReportLoading").hide();
           },
           error: function(request){
            $("#SalesReportLoading").hide();
			$("#SalesReportContent").html(request.responseText).modal('show');
           }
        });
	}
	
	this.GetSecondLevelCategories = function(data){
		var url = '/inventory_items/get_second_level_category'
		$("#inventory_item_second_level_category_id").attr("disabled", "disabled")
		$.get(url ,data, function(data){
	      $("#inventory_item_second_level_category_id").empty();
	      $("#inventory_item_second_level_category_id").append("<option value=\"\" selected=\"selected\"></option>");
	      $.each(data, function(index, value) {
	        $("#inventory_item_second_level_category_id").append("<option value = " + value.id + ">" + value.name + "</option>");
	      });
	      $("#inventory_item_second_level_category_id").removeAttr("disabled");
	    });
	}
	
    this.SubmitInventoryItemForm = function(form){
		submitButton = form.find(':submit');
		submitButton.attr('disabled', 'disabled');
		submitButton.attr('value', "Saving...");
		form.ajaxSubmit({
	       dataType: "html",
	       //Remove the file input if it's empty so paperclip doesn't choke
	       beforeSerialize: function() {
	           if($("#inventory_item_photo").val() === ""){
	               $("#inventory_item_photo").remove();
	           }
	       },
	       success: function(data, textStatus, request){
	           self.CloseInventoryDialog();
			   $("#SellerContent").html(data);
	       },
	       error: function(request){
	           $("#Modal").html(request.responseText).modal('show');
	       }
	    });
	}
    
    this.LoadInventoryDialog = function(url){
        $("#Modal").load(url, function() {
			$("#SellerNotice").hide();
			$(this).modal('show');
        });
    }

    this.CloseInventoryDialog = function(){
        $("#Modal").modal('hide');
    }
}
