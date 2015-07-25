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

$(document).on("click", ".contactButton", function(event){
    event.preventDefault();
    var url = $(this).attr("href"),
     	user = new User()
    
    user.LoadContactDialog(url);
    
    return false;
});

$(document).on("submit", "#new_user_contact_message", function(){
    var user = new User();
	user.SubmitContactForm($(this));
    return false;
});

function User(){
	
	var self = this;
	
    this.LoadContactDialog = function(url){
        $("#Modal").load(url, function() {
			$(this).modal('show');
        });
    }
	
    this.SubmitContactForm = function(form){
		submitButton = form.find(':submit');
		submitButton.attr('disabled', 'disabled');
		submitButton.attr('value', "Sending...");
		form.ajaxSubmit({
	       dataType: "html",
	       success: function(data, textStatus, request){
           		$("#InnerContent").html(request.responseText);
  				var ratings = $("#InnerContent").find("input[type=radio].star");
  				ratings.rating();
				self.CloseDialog();
	       },
	       error: function(request){
	           $("#Modal").html(request.responseText).modal('show');
	       }
	    });
	}
	
    this.CloseDialog = function(){
        $("#Modal").modal('hide');
    }
}
