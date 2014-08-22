
$(document).ready(function(){
	$("table.sortable").tablesorter();
	$("td.requestnum").each(function(){
		var $td = $(this);
		var txt = $td.html();
		var $input = $("<input readonly='readonly' value='" + txt + "'/>");
		$td.empty().append($input);
		$input.click(function(){this.select()});
	});
});