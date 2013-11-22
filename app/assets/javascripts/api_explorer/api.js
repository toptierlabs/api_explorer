// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function(){

	// Match all containers and placeholders
	var container = $("body.api_explorer"); // In order to avoid naming colisions, all the selectors are within this context
	var parameters_container = $("#parameters_container", container);
	var headers_container = $("#headers_container", container);
	var authentication_container = $("#authentication_container", container);	
	var method_description = $("#method_description", container);
	var select_method = $("#api_methods", container);
	var response_placeholder = $("#response_placeholder", container);
	var tab_history = $("#response_placeholder").find(".tab_history");
	var history_menu = tab_history.find(".history_menu");
	var authentication_method = $("#authentication_type", container);

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
				headers_container.show();
				method_description.show();
				authentication_container.show();
			});
		else
		{
			// Clean everything
			parameters_container.html('');
			method_description.html('');
			parameters_container.hide();
			headers_container.hide();
			method_description.hide();
			authentication_container.hide();
		}
	})	

	// Change authentication method
	authentication_method.change(function(){
		if ($(this).val() != ''){
			$('.auth_wrapper', authentication_container).hide();
			$('input[type="text"]',authentication_container).val('');
			$('#' + $(this).val() ,authentication_container).show();
		}
		else{
			// If 'none' is selected, hide authentication option containers
			$('.auth_wrapper', authentication_container).hide();
			$('input[type="text"]',authentication_container).val('');
		}
	});

	// Clear parameters button
	$(container).on('click', '#clear_parameters', function(){
		$("input", parameters_container).val('')
	})

	// Clear the headers
	$('#clear_headers', container).click(function(){
		$("input", headers_container).val('');
		$(".deletable", headers_container).remove();
		
	})

	// Clear authentication section
	$('#clear_authentication', container).click(function(){
		$("input", authentication_container).val('');
		$("select", authentication_container).val('');
		$(".auth_wrapper", authentication_container).hide();
	})

	// Add headers when focusing on headers input
	headers_container.on('focus', ".parameter_input",function(){
		header_line = $(this).parents(".headers_line");
		if (header_line.is(':last-child'))
		{ 

			header_line.parent().append('<div class="headers_line"><div class="header_field"><input type="text" placeholder="Header name" name="header[name][]" class="parameter_input" /></div><div class="header_field"><input type="text" placeholder="Value" name="header[value][]" class="parameter_input" /></div></div>');
			
			// Add delete button
			header_line.append('<div class="delete_btn"></div>');
			header_line.addClass('deletable');
		}
	}); 

	// Delete header
	headers_container.on('click', ".delete_btn",function(){
		$(this).parents('.headers_line').remove();
	});

	// Funciton used to minimize sections
	var  minimize_container = function(self, min_container)
	{
		min_container.addClass('minimized');
		self.removeClass('minimize');
		self.addClass('maximize');
		self.attr('title','Maximize');
	} 

	// Function used to maximize sections
	var  maximize_container = function(self, max_container)
	{
		max_container.removeClass('minimized');
		self.removeClass('maximize');
		self.addClass('minimize');
		self.attr('title','Minimize');
	}

	// Headers container minimize function 
	headers_container.on('click', ".minimize",function(){
		minimize_container($(this), headers_container);
	});

	// Headers container maximize function 
	headers_container.on('click', ".maximize",function(){
		maximize_container($(this),headers_container);
	});

	// Paremeters container minimize function
	parameters_container.on('click', ".minimize",function(){
		minimize_container($(this),parameters_container);
	});

	// Paremeters container maximize function
	parameters_container.on('click', ".maximize",function(){
		maximize_container($(this), parameters_container);
	});

	// Authentication container minimize function
	authentication_container.on('click', ".minimize",function(){
		minimize_container($(this),authentication_container);
	});

	// Authentication container maximize function
	authentication_container.on('click', ".maximize",function(){
		maximize_container($(this), authentication_container);
	});

	// History item selected
	history_menu.on('click', '.history_item', function(){
		$(".history_item", history_menu).removeClass('active');
		$(this).addClass('active');
		var history_content = tab_history.find(".history_content");
		var timestamp = $(this).data('timestamp');
		$(".content_wrapper", history_content).hide();
			
		$("."+ timestamp, history_content).show();
	});

	// Make request
	$("#api_explorer_submit", container).click(function(e){
		e.preventDefault();

		// Build array of parameters
		var data = $("input", parameters_container).serializeArray().concat($("input", headers_container).serializeArray()).concat($("input, select", authentication_container).serializeArray());
		data.push({name: 'url', value: $("#graph_path", container).val()});
		data.push({name: 'method', value: select_method.find('option:selected').data('method')});

		// Send the information to the server
		$.post("api_explorer/execute", data, function(response){
			// Response returned, minimize headers, parameters and authentication
			headers_container.addClass('minimized');
			parameters_container.addClass('minimized');
			authentication_container.addClass('minimized');

			// Change minimize icon
			headers_container.find('.minimize').removeClass('minimize').addClass('maximize');
			parameters_container.find('.minimize').removeClass('minimize').addClass('maximize');
			authentication_container.find('.minimize').removeClass('minimize').addClass('maximize');
			
			// Set the html of the request/response
			response_placeholder.find(".tab_response").find(".content").html(response.response_html);
			response_placeholder.find(".tab_request").find(".content").html(response.request_html);
			
			// Set History
			var history_content = tab_history.find(".history_content");
			$(".history_item", history_menu).removeClass('active');
			
			// If I have more than 9 elements, remove the last one
			if ($(".history_item", history_menu).length > 9)
			{
				$(".history_item", history_menu).last().remove();
				$(".content_wrapper", history_content).last().remove();
			}
			history_content.prepend(response.history_html);
			history_menu.prepend("<div class='history_item active' data-timestamp='"+ response.timestamp + "'>" + response.http_method + " to "+response.request_url +" ( at " + response.date +" ) " + "</div>");
			
			// Select the current element in History
			$(".content_wrapper", history_content).hide();
			$("." + response.timestamp, history_content).show();

			// Slide down the response placeholder and check the response tab as checked
			response_placeholder.slideDown();
			response_placeholder.find(".tab_response").find('input[type="radio"]').prop("checked", true);

			// Scroll to response position
			$('html, body').animate({
		        scrollTop: response_placeholder.offset().top + 50
		    }, 500);


		}).error(function() { 
			alert('There was an error executing the webservice. Please check if you are using a multithreaded server');
		});

	});
})
