$(document).on("click", ".star-rating", function () {
	form = $(this).closest("form")
    form.ajaxSubmit({
		cache: false,
        dataType: "html",
     });
});

$(document).on("click", ".rating-cancel", function () {
	form = $(this).closest("form")
    form.ajaxSubmit({
        dataType: "html",
     });
});