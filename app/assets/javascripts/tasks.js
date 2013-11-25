$(document).ready(function() {
	$('#completed_tasks_start').change(function() {
		window.location = location.protocol + '//' + location.host + location.pathname + "?start=" + $('#completed_tasks_start').val() + "&end=" + $('#completed_tasks_end').val()
	});
	$('#completed_tasks_end').change(function() {
		window.location = location.protocol + '//' + location.host + location.pathname + "?start=" + $('#completed_tasks_start').val() + "&end=" + $('#completed_tasks_end').val()
	});
});