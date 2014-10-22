$(document).on("click", ".review", function(event){
    event.preventDefault();
    var url = $(this).attr("href"),
     	review = new Review()
    
    review.LoadReviewDialog(url);
    
    return false;
});

$(document).on("submit", "#ReviewForm", function(){
    var review = new Review();
    review.SubmitReviewForm($(this));
    return false;
});

function Review(){
	
	var self = this;
	
    this.SubmitReviewForm = function(form){
		submitButton = form.find(':submit');
		submitButton.attr('disabled', 'disabled');
		submitButton.attr('value', "Saving...");
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
	
    this.LoadReviewDialog = function(url){
        $("#Modal").load(url, function() {
            var modal = $(this);
			var ratings = modal.find("input[type=radio].star");
			modal.modal('show');
			ratings.rating()
        });
    }
	
    this.CloseDialog = function(){
        $("#Modal").modal('hide');
    }
}
