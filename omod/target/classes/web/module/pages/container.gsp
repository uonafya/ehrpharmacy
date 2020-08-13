<%
    ui.decorateWith("appui", "standardEmrPage", [title: title])	
    ui.includeCss("pharmacyapp", "container.css")
	
    ui.includeJavascript("billingui", "moment.js")
	ui.includeJavascript("billingui", "jq.browser.select.js")
%>

<style>
	#modal-overlay {
		background: #000 none repeat scroll 0 0;
		opacity: 0.4 !important;
	}
</style>


${ui.includeFragment("pharmacyapp", fragment)}
