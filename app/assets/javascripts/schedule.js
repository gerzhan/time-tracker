$(document).ready(function() {
	$("#schedule_selected_date").change(function() {
		window.location = location.protocol + '//' + location.host + location.pathname + "?week=" + $("#schedule_selected_date").val()
	});
});