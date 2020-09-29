<%
	ui.decorateWith("kenyaemr", "standardPage")
	ui.includeJavascript("ehrconfigs", "moment.js")
	ui.includeJavascript("ehrconfigs", "jquery-ui-1.9.2.custom.min.js")
	ui.includeJavascript("ehrconfigs", "underscore-min.js")
	ui.includeJavascript("ehrconfigs", "knockout-3.4.0.js")
	ui.includeJavascript("ehrconfigs", "emr.js")
	ui.includeCss("ehrconfigs", "jquery-ui-1.9.2.custom.min.css")
	// toastmessage plugin: https://github.com/akquinet/jquery-toastmessage-plugin/wiki
	ui.includeJavascript("ehrconfigs", "jquery.toastmessage.js")
	ui.includeCss("ehrconfigs", "jquery.toastmessage.css")
	// simplemodal plugin: http://www.ericmmartin.com/projects/simplemodal/
	ui.includeJavascript("ehrconfigs", "jquery.simplemodal.1.4.4.min.js")
	ui.includeCss("ehrconfigs", "referenceapplication.css")
%>

<head>
	<script>
        jq(function () {
            jq("#tabs").tabs();
			var index = jq('#tabs a[href="#${tabId}"]').parent().index();
			jq('#tabs').tabs('select', index);
			
        });
    </script>    
</head>

<body>
	<div class="clear"></div>
	<div class="container">
		<div class="example">
			<ul id="breadcrumbs">
				<li>
					<a href="${ui.pageLink('kenyaemr', 'userHome')}">
					<i class="icon-home small"></i></a>
				</li>
				
				<li>
					<i class="icon-chevron-right link"></i>
					Pharmacy Module
				</li>
			</ul>
		</div>
		
		<div class="patient-header new-patient-header">
			<div class="demographics">
				<h1 class="name" style="border-bottom: 1px solid #ddd;">
					<span>PHARMACY DASHBOARD &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
				</h1>
			</div>

			<div class="identifiers">
				<em>&nbsp; &nbsp; Current Time:</em>
				<span>${currentTime}</span>
			</div>
			
			<div id="tabs" style="margin-top: 40px!important;">
				<ul id="inline-tabs">
					<li><a href="#accountdrug">Issue drug to Account</a></li>
					<li><a href="#manage">DRUG ORDERS</a></li>
				</ul>
				<div id="accountdrug">
					<div>${ ui.includeFragment("pharmacyapp", "issueDrugAccountList") }</div>
				</div>
				
				<div id="manage">
					<div>${ ui.includeFragment("pharmacyapp", "indentDrugList") }</div>
				</div>
			</div>
		
		</div>
	</div>
</body>