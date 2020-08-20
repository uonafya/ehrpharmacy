<%
    ui.decorateWith("appui", "standardEmrPage", [title: title])	
    ui.includeCss("pharmacyapp", "container.css")
	
    ui.includeJavascript("ehrcashier", "moment.js")
	ui.includeJavascript("ehrcashier", "jq.browser.select.js")
%>

<style>
	#modal-overlay {
		background: #000 none repeat scroll 0 0;
		opacity: 0.4 !important;
	}
</style>


${ui.includeFragment("pharmacyapp", fragment)}
