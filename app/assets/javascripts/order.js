$(document).on("submit", "#EditOrderForm", function(event){
    event.preventDefault()
    var order = new Order();
    order.SubmitEditOrderForm($(this))
    return false;
})

function Order(){
    
    this.SubmitEditOrderForm = function(form){
        $("#Loading").show();
        form.ajaxSubmit({
           dataType: "html",
           success: function(content){
             $("#MainContent").html(content);
             utils.ShowAlert($("#ApplicationNotice"), "Order successfully updated")
             $("#Loading").hide();
           },
           error: function(request){
            $("#Loading").hide();
            $("#MainContent").html(request.responseText);
           }
        });
    }
}