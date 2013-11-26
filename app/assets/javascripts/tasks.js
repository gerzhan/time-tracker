$(document).ready(function() {
	$('#completed_tasks_start').change(function() {
		window.location = location.protocol + '//' + location.host + location.pathname + "?start=" + $('#completed_tasks_start').val() + "&end=" + $('#completed_tasks_end').val()
	});
	$('#completed_tasks_end').change(function() {
		window.location = location.protocol + '//' + location.host + location.pathname + "?start=" + $('#completed_tasks_start').val() + "&end=" + $('#completed_tasks_end').val()
	});
	$('#tasks_start').change(function() {
		window.location = location.protocol + '//' + location.host + location.pathname + "?user=" + $('#tasks_selected_user').val() +  "start=" + $('#tasks_start').val() + "&end=" + $('#tasks_end').val()
	});
	$('#tasks_end').change(function() {
		window.location = location.protocol + '//' + location.host + location.pathname + "?user=" + $('#tasks_selected_user').val() +  "start=" + $('#tasks_start').val() + "&end=" + $('#tasks_end').val()
	});
	$('#tasks_selected_user').select2({

	});
	$('#tasks_selected_user').change(function() {
		window.location = location.protocol + '//' + location.host + location.pathname + "?user=" + $('#tasks_selected_user').val() +  "start=" + $('#tasks_start').val() + "&end=" + $('#tasks_end').val()
	});
	$('#tasks_selected_department').select2({

	});
	$('#tasks_selected_user').change(function() {
		window.location = location.protocol + '//' + location.host + location.pathname + "?user=" + $('#tasks_selected_user').val() +  "start=" + $('#tasks_start').val() + "&end=" + $('#tasks_end').val()
	});
		
});