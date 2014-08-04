/*
* Copyright 2014 Sandro Boehme
* 
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* 
*   http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

// creating the namespace
var org = org || {};
org.sboehme = org.sboehme || {};
org.sboehme.jcrbrowser = org.sboehme.jcrbrowser || {};


/*
 Controller - It adapts the JSTree library for the use in the JCRBrowser.
 This JCRBrowserJSTreeAdapter contains as less logic as needed to configure the JSTree for the JCRBrowser. For 
 everything that goes beyond that and contains more functionality, the JCRBrowserTreeController is called.
*/

//defining the module
org.sboehme.jcrbrowser.LoginController = (function() {

	function LoginController(settings, mainController){
		var authorized = settings.authorized;
		$(document).ready(function() {
			setLoginTabLabel(settings.authorizedUser);
			
			$('#login_tab').click(function(e) {	
				if (authorized) {
		        	location.href='/system/sling/logout.html?resource='+settings.requestURI;
				} else {
					$('#login_tab_content').slideToggle(function() {mainController.adjust_height();});
					$("#login_form input[name='j_username']").focus();
				}
			});

			$('#login_form input').keydown(function(event) {
		        if (event.keyCode == 13/*Return key*/) {	
		    		submitForm();
		            return false;
		         }
		    });
			
			$('#login_submit').click(function(e) {	
				submitForm();
			});
		});
		

		function setLoginTabLabel(authorizedUser){
			$('#login_tab').text(authorized ? 'Logout '+authorizedUser : authorizedUser);
			if (authorized) {
				$('#login .nav-tabs').removeClass('nav-tabs').addClass('logout');
			}
		}

		function submitForm(){
			$('#login').removeClass('animated shake');
			$('#login .form-group.error').hide();
			
			$.ajax({
		  	  type: 'POST',
				  url: settings.contextPath + $('#login_form').attr('action') + '?' + $('#login_form').serialize(),
		  	  success: function(data, textStatus, jqXHR) {
		  		authorized=true;
		  		$('#login_tab_content').slideToggle(function() {
		  			mainController.adjust_height();
		  			setLoginTabLabel($('#login_form input[name="j_username"]').val());
		  		});
			  },
		  	  error: function(data) {
		  			$('#login_error').text(data.responseText);
		  			$('#login .form-group.error').slideToggle();
		  			$('#login').addClass('animated shake');
			  }
		  	});
		}
	};

	return LoginController;
}());
