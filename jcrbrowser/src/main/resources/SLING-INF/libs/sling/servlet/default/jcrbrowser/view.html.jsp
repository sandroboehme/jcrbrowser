<!DOCTYPE html>
<%@ page session="false"%>
<%@ page isELIgnored="false"%>
<%@ page import="javax.jcr.*,org.apache.sling.api.resource.Resource"%>
<%@ page import="java.security.Principal"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0"%>
<sling:defineObjects />
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link href='<%= request.getContextPath() %>/libs/jcrbrowser/content/css/font.css' rel='stylesheet' type='text/css'>
 <!--[if lt IE 9]>
<link href='<%= request.getContextPath() %>/libs/jcrbrowser/content/css/font_ie.css' rel='stylesheet' type='text/css'>
  <![endif]-->
  
<!-- 
original 
<link href='http://fonts.googleapis.com/css?family=Michroma' rel='stylesheet' type='text/css'>
 -->

<script type="text/javascript" src="<%= request.getContextPath() %>/libs/jsnodetypes/js/jsnodetypes.js"></script>

<script type="text/javascript" src="<%= request.getContextPath() %>/libs/jcrbrowser/content/js/jquery.min.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/libs/jcrbrowser/content/js/jquery-ui.custom.min.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/libs/jcrbrowser/content/js/bootstrap.min.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/libs/jcrbrowser/content/js/bootbox.min.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/libs/jcrbrowser/content/js/jstree.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/libs/jcrbrowser/content/js/jquery.scrollTo-min.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/libs/jcrbrowser/content/js/urlEncode.js"></script>

<link rel="stylesheet" type="text/css" media="all" href="<%= request.getContextPath() %>/libs/jcrbrowser/content/css/style.css">
<link rel="stylesheet" type="text/css" media="all" href="<%= request.getContextPath() %>/libs/jcrbrowser/content/css/bootstrap.css">
<link rel="stylesheet" type="text/css" media="all" href="<%= request.getContextPath() %>/libs/jcrbrowser/content/css/shake.css">
<link rel="stylesheet" type="text/css" media="all" href="<%= request.getContextPath() %>/libs/jcrbrowser/content/css/theme/smoothness/jquery-ui.custom.css">

<!--[if IE]>
	<link rel="stylesheet" type="text/css" media="all" href="<%= request.getContextPath() %>/libs/jcrbrowser/content/css/browser_ie.css"/>
<![endif]-->


<%
Principal userPrincipal = ((HttpServletRequest)pageContext.getRequest()).getUserPrincipal();
%>
<c:set var="authorized" value='<%=!"anonymous".equals(userPrincipal.getName()) %>'/>
<c:set var="userPrincipal" value='<%=userPrincipal %>'/>

<script type="text/javascript">
var ntManager = new de.sandroboehme.NodeTypeManager();

var authorized = ${authorized};
var authorizedUser = '${userPrincipal.name}';

var currentNodePath = $.URLDecode("${resource.path}");
var paths = currentNodePath.substring(1).split("/");
var selectingNodeWhileOpeningTree=true;

//!"#$%&'()*+,./:;<=>?@[\]^`{|}~
var specialSelectorChars = new RegExp("[\\[\\]:!\"#\\$%&'\\(\\)\\*\\+,\\./:;<=>\\?@\\\\\\^`{}\\|~]","g");

function getPathFromLi(li){
	return $(li).parentsUntil(".root").andSelf().map(
			function() {
				return this.tagName == "LI"
						? $(this).attr("nodename") 
						: null;
			}
		).get().join("/");
};

function getNTFromLi(li){
	var nt_name = $(li).children("a").find("span span.node-type").text();
    return ntManager.getNodeType(nt_name);	
}

function getSelectorFromPath(path){
	var paths = path.substring(1).split("/");
	return "#tree > ul [nodename='"+paths.join("'] > ul > [nodename='")+"']";
}


function openElement(root, paths) {
	var pathElementName = paths.shift().replace(specialSelectorChars,"\\\\$&");;
	var pathElementLi = root.children("[nodename='"+pathElementName+"']");
	if (pathElementLi.length === 0){
		alert("Couldn't find "+pathElementName+" under the path "+getPathFromLi(root.parent()));
	} else {
		selectingNodeWhileOpeningTree=true;
		$.jstree._reference(pathElementLi).select_node(pathElementLi, true);
		selectingNodeWhileOpeningTree=false;
		$.jstree._reference(pathElementLi).open_node(pathElementLi,
				function(){
					if (paths.length>0){
						openElement(pathElementLi.children("ul"), paths);
					}
				},
				function(){
					alert("Couldn't open "+pathElementName+" under the path "+getPathFromLi(root.parent()));
				}
			);

	}
}

function get_uri_from_li(li, extension){
	var path = getPathFromLi(li);
	path = $.URLEncode(path);
	path = path.replace(/%2F/g, "/");
	path = path.replace(/%3A/g, ":");
	return "<%= request.getContextPath() %>"+path+extension;
}

function adjust_height(){
	var login_height = $("#login").outerHeight(true);
	var header_height = $("#header").outerHeight(true);
	var alert_height = $("#alerts").outerHeight(true);
	var footer_height = $("#footer").outerHeight(true);
	var sidebar_margin = $("#sidebar").outerHeight(true)-$("#sidebar").outerHeight(false);
	var usable_height = $(window).height() - login_height - header_height - alert_height - sidebar_margin - 1;
// activate again if the footer is needed	
// 	var usable_height = $(window).height() - header_height - footer_height - sidebar_margin - 1;
	$("#sidebar").height( usable_height );
	$("#outer_content").height( usable_height );
}

function isModifierPressed(e){
	return (e.shiftKey || e.altKey || e.ctrlKey);
}

function setLoginTabLabel(authorizedUser){
	$('#login_tab').text(authorized ? 'Logout '+authorizedUser : authorizedUser);
	if (authorized) {
		$('#login .nav-tabs').removeClass('nav-tabs').addClass('logout');
	}
}

function displayAlert(errorMsg, rlbk){
	var errorMessage = $("#Message",errorMsg);
	$('#alertMsg').append(errorMessage);
	$('#alertMsg').bind('closed', function () {
		$("#alert").slideToggle(function() {
			adjust_height();
		  });
	});
	$("#alert").slideToggle(function() {
		adjust_height();
	  });
	$.jstree.rollback(rlbk);
}

$(document).ready(function() {
	adjust_height();
	$(window).resize( function() {
		adjust_height();
	});
	var selectorFromCurrentPath = getSelectorFromPath(currentNodePath);
	var scrollToPathFinished=false;
	
	setLoginTabLabel(authorizedUser);
	
	$('#login_tab').click(function(e) {	
		if (authorized) {
        	location.href='/system/sling/logout.html?resource=${pageContext.request.requestURI}';
		} else {
			$('#login_tab_content').slideToggle(function() {adjust_height();});
		}
	});

	$('#login_submit').click(function(e) {		
		$('#login').removeClass('animated shake');
		$('#login .control-group.error').hide();
		
    	$.ajax({
      	  type: 'POST',
			  url: '<%= request.getContextPath() %>' + $('#login_form').attr('action') + '?' + $('#login_form').serialize(),
      	  success: function(data, textStatus, jqXHR) {
      		authorized=true;
      		$('#login_tab_content').slideToggle(function() {
      			adjust_height();
      			setLoginTabLabel($('#login_form input[name="j_username"]').val());
      		});
      		
    	  },
      	  error: function(data) {
      			$('#login_error').text(data.responseText);
      			$('#login .control-group.error').slideToggle();
      			$('#login').addClass('animated shake');
    	  }
      	});
	});
	
	// TO CREATE AN INSTANCE
	// select the tree container using jQuery
	$("#tree")
	// call `.jstree` with the options object
	.jstree({
		"core"      : {
			html_titles : false,
		  'data' : {
			    'url' : function (li) {
					// the li the user clicked on.
					return li.attr ?  get_uri_from_li(li,".jcrbrowser.nodes.json") : "<%= request.getContextPath() %>/.jcrbrowser.nodes.json"; 
					}
		  }
		},
		"ui"      : {
			"select_limit" : 2
		},
		"html_data" : {
			"async" : true,
			"ajax" : {
				"url" : function (li) {
					// the li the user clicked on.
					return li.attr ?  get_uri_from_li(li,".jcrbrowser.nodes.html") : "<%= request.getContextPath() %>/.jcrbrowser.nodes.html"; 
					}
			},
			"progressive_render" : true
		},
		// the `plugins` array allows you to configure the active plugins on this instance
		"plugins" : [ "themes", "html_data",  "ui", "core"]
    }).bind("loaded.jstree", function (event, data) {
		if (currentNodePath != "/") {
			openElement($("#tree > ul > li[nodename=''] > ul"), paths);
		}
		selectingNodeWhileOpeningTree=false;
	    })
    .click(function(e) {		
        e.preventDefault(); 
       	var target = ($(e.target).attr("target")) ? $(e.target).attr("target") : $(e.target).parent().attr("target");
    	if (target && !selectingNodeWhileOpeningTree && !isModifierPressed(e)){
        	location.href=target+".jcrbrowser.html";
		}
	});
});
</script>	

</head>
<body>
	<div id="container-fluid">
		<div id="login" class="row-fluid">
			<div class="span12">
			 	<div class="logo">
				JCRBrowser 2.0<span class="edition">node-edit</span><span class="edition">edition</span>
				</div>			 	
				<div class="tabbable tabs-below"> 
				  <div id="login_tab_content" class="tab-content plate-background plate-box-shadow" style="display:none;">
				    <div class="tab-pane active">
						<div>
			                <form id="login_form" class="form-horizontal" action="/j_security_check" method="post">
			                        <div class="control-group">
										<div class="controls">
						                    <input type="hidden" value="${pageContext.request.requestURI}" name="resource" />
					                        <input type="hidden" value="form" name="selectedAuthType" />
											<input type="hidden" value="UTF-8" name="_charset_">
										</div>
									</div>
			                        <div class="control-group">
										<label class="control-label" for="j_username">Username:</label>
										<div class="controls">
											<input type="text" name="j_username" />
										</div>
									</div>
			                        <div class="control-group">
										<label class="control-label" for="j_password">Password:</label>
										<div class="controls">
											<input type="password" name="j_password" />
										</div>
									</div>
			                        <div class="control-group error">
										<div class="controls">
			                        		<span id="login_error" class="help-block"></span>
										</div>
									</div>
			                        <div class="control-group" id="login_submit_control_group">
										<div class="controls">
			                        		<input id="login_submit" type="button" class="btn" value="Login" >
										</div>
									</div>
			                </form>
						</div>
				    </div>
				  </div>
				  <ul class="nav nav-tabs">
				    <li class="active">
				    	<a id="login_tab" href="#login_tab_content" data-toggle="tab">Login</a>
				    </li>
				  </ul>
				</div>
			</div>
		</div>
		<div id="header" class="row-fluid">
			<div class="span12" style="display:none;">
				 <div class="plate">
				</div> 
			</div>
		</div>
		<div id="alerts" class="row-fluid">
			<div id="alert" style="display:none;" class="span12">
			  	<div id="alertMsg" class="alert alert-error">
			  		<button type="button" class="close" data-dismiss="alert">&times;</button>
			  		<h4>Error</h4>
		  		</div>
		  	</div>		
		</div>
		<div class="row-fluid">
			<div class="span4">
				<div id="sidebar" class="plate">
					<div id="tree" class="demo root" ></div>
				</div>
			</div>
			<div class="span8">
				<div id="outer_content" class="plate">
					<div id="inner_content_margin">
						<form action="not_configured_yet.change.properties" method="post">
							<c:set var="resourceIsNode" scope="request" value="<%=resource.adaptTo(Node.class) !=null %>"/>
							<c:if test="${resourceIsNode}">
								<%--
								For some reason I get the following exception when using the JSTL expression '${currentNode.properties}'
								instead of the scriptlet code 'currentNode.getProperties()':
								org.apache.sling.scripting.jsp.jasper.JasperException: Unable to compile class for JSP: 
								org.apache.sling.scripting.jsp.jasper.el.JspValueExpression cannot be resolved to a type
								see https://issues.apache.org/jira/browse/SLING-2455
								 --%>
								<c:forEach var="property" items="<%=currentNode.getProperties()%>">
							<%  Property property = (Property) pageContext.getAttribute("property");%>
									<fieldset>
										<label class="proplabel" for='${property.name}'>${property.name} [<%=PropertyType.nameFromValue(property.getType())%>${property.multiple ? ' multiple' : ''}]</label>
										<c:choose>
										     <c:when test="${property.multiple}" >
										     	<fieldset class="propmultival_fieldset">
										     		<div>&nbsp;</div>
										     	<c:forEach var="value" items="<%=property.getValues()%>">
										     		<c:choose>
										     		<c:when test="${property.type == PropertyType.BINARY}" >
												     	<p>I'm a binary property</p>
												     </c:when>
												     <c:otherwise>
											     		<input class="propinputmultival" value="${value.string}"/>
												     </c:otherwise>
												     </c:choose>
										     	</c:forEach>
				     							</fieldset>
										     </c:when>
										     <c:when test="${false}" >
										     </c:when>
										     <c:otherwise>
											     <c:choose>
											     <c:when test="<%=property.getType() == PropertyType.BINARY%>" >
											     	<c:choose>
												     	<c:when test='<%=currentNode.getParent().isNodeType("nt:file") %>'>
												     		<a class="propinput" href="<%= request.getContextPath() %>${resource.parent.path}">Download</a>
												     	</c:when>
												     	<c:otherwise>
												     		<a class="propinput" href="<%= request.getContextPath() %>${resource.path}.property.download?property=${property.name}">View (choose "Save as..." to download)</a>
												     	</c:otherwise>
											     	</c:choose>
											     </c:when>
											     <c:otherwise>
													<input class="propinput" id="${property.name}" name="${property.name}" value="${property.string}"/>							
											     </c:otherwise>
											     </c:choose>
										     </c:otherwise>
										 </c:choose>
									</fieldset>
								</c:forEach>
							</c:if>
						</form>
					</div>
			    </div>
			</div>
	    </div>
		<div class="row-fluid" style="display:none">
			<div class="span12">
				 <div id="footer" class="plate">
						<p>I'm looking forward to be filled with useful content</p>
				</div>
			</div>
		</div>
	</div>
</div>	
</body>
</html>
