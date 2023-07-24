<%
	ui.decorateWith("kenyaemr", "standardPage")
    ui.includeCss("pharmacyapp", "container.css")

	ui.includeJavascript("ehrconfigs", "jquery-ui-1.9.2.custom.min.js")
	ui.includeJavascript("ehrconfigs", "moment.js")
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

<style>
	/*#modal-overlay {*/
	/*	background: #000 none repeat scroll 0 0;*/
	/*	opacity: 0.4 !important;*/
	/*}*/
</style>


${ui.includeFragment("pharmacyapp", fragment)}
