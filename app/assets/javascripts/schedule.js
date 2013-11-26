$(document).ready(function() {
	$("#schedule_selected_date").change(function() {
		window.location = location.protocol + '//' + location.host + location.pathname + "?department=" + $("#schedule_selected_department").val() + "&week=" + $("#schedule_selected_date").val() + "&user=" + $("#schedule_selected_user").val()
	});
	$("#schedule_selected_department").change(function() {
		window.location = location.protocol + '//' + location.host + location.pathname + "?department=" + $("#schedule_selected_department").val() + "&week=" + $("#schedule_selected_date").val() + "&user=" + $("#schedule_selected_user").val()
	});
	$('#schedule_selected_department').select2({
      
    });
	$("#schedule_selected_user").change(function() {
		window.location = location.protocol + '//' + location.host + location.pathname + "?department=" + $("#schedule_selected_department").val() + "&week=" + $("#schedule_selected_date").val() + "&user=" + $("#schedule_selected_user").val()
	});
	$('#schedule_selected_user').select2({
      
    });
});
