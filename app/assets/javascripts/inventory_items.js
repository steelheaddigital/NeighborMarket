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

//= require ./lib/bootstrap3-typeahead
//= require ./lib/jquery.rating
//= require ./lib/jquery.metadata

(function($, utils){

	var InventoryItems = function() { 
		init();
	}

	function init() { 
		$(document).on("change", "#inventory_item_top_level_category_id", function() {
			getSecondLevelCategories.call(this)
		});

		$(document).on("submit", "#new_inventory_item", function(event){
		    submitInventoryItemForm.call(this, event)
		});

		$(document).on("submit", "#edit_inventory_item", function(event){
		    submitInventoryItemForm.call(this, event)
		});
	}

	function getSecondLevelCategories(){
		var data = {category_id:$(this).val()}
		var url = '/inventory_items/get_second_level_category'
		var secondLevel = $("#inventory_item_second_level_category_id");

		secondLevel.attr("disabled", "disabled")
		$.get(url ,data, function(data){
			secondLevel.empty();
			secondLevel.append("<option value=\"\" selected=\"selected\"></option>");

			$.each(data, function(index, value) {
				secondLevel.append("<option value = " + value.id + ">" + value.name + "</option>");
			});

			secondLevel.removeAttr("disabled");
	    });
	}

	function submitInventoryItemForm(event){
    	event.preventDefault();
    	form = $(this);
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
			   	utils.closeDialog();
			   	$("#ViewContent").html(data);
			},
			error: function(request){
			   	$("#Modal").html(request.responseText).modal('show');
			}
	    });
	}

	return new InventoryItems();

})(jQuery, Utils);
