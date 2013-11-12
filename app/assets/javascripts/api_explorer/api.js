// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function(){
	var container = $("body.api_explorer")
	var parameters_container = $("#parameters_container", container);
	var method_description = $("#method_description", container);
	var select_method = $("#api_methods", container);

	// Change selected method
	select_method.change(function(){
		$("#graph_path", container).val($(this).val());
		
		

		var position = $(this)[0].selectedIndex;

		// if a method is selected
		if (position > 0)
			$.get("api_explorer/method", {position: position}).done(function(data){
				parameters_container.html(data.parameters_html);
				method_description.html(data.description);
				parameters_container.show();
				method_description.show();
			});
		else
		{
			// Clean everything
			parameters_container.html('');
			method_description.html('');
			parameters_container.hide();
			method_description.hide();
		}
	})	

	// Clear parameters button
	$(container).on('click', '#clear_parameters', function(){
		$("input", parameters_container).val('')
	})

	//make request
	$("#api_explorer_submit", container).click(function(e){
		e.preventDefault();
		
		var data = $("input", parameters_container).serializeArray();
		data.push({name: 'url', value: $("#graph_path", container)});
		data.push({name: 'method', value: select_method.find('option:selected').data('method')});

		$.post("api_explorer/execute", data, function(response){
			console.log(response);
		})


	});
})
