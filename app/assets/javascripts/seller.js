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
//= require inventory_items

(function($, utils){

	var Seller = function() {
		init();
	}

	function init() {

		$(document).on("click", "#SelectAllInventoryItems", function() {
			selectAll.call(this);
		});

		$(document).on("click", "#PreviewSalesReportSubmit", function(event){
			submitSalesReportForm.call(this, event)
		});

		$(document).on("click", "#PastInventortyToggleContainer", toggleAngleIcons);
	}

	function selectAll(){
		var element = $(this);
		var rows = element.parents("table").find("tbody").find("tr");
			
		//Toggle the checkbox for each row in the table
		rows.each(function(){
			$(this).find("td:first")
				   .children(":first")
				   .attr('checked', function(idx, oldAttr) {
				    	return !oldAttr;
				    })
		});
	}

	function submitSalesReportForm(form){
		event.preventDefault();
		var form = $(this).closest("form")
		var url = form.attr("action")
		var loading = $("#SalesReportLoading");

		loading.show();
        form.ajaxSubmit({
           	dataType: "html",
           	success: function(content){
			 	$("#SalesReportContent").html(content);
             	loading.hide();
           	},
           	error: function(request){
            	loading.hide();
				$("#SalesReportContent").html(request.responseText).modal('show');
           	}
        });
	}

    function toggleAngleIcons(){
    	var icon = $("#AddPastInventoryItemsIcon");

    	icon.toggleClass("fa-angle-double-down");
		icon.toggleClass("fa-angle-double-up");
    }

    return new Seller();

})(jQuery, Utils);

