<%
	ui.decorateWith("kenyaemr", "standardPage")
    ui.includeCss("pharmacyapp", "dashboard.css")
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

<script>
	jq(function () {
		var redirectLink = '';
		
		jq('#queue, #dispense, #patient, #stock, #expired, #accounts, #indent, #summary').on('click', function(){
			if (jq(this).attr('id') == 'queue'){
				redirectLink = 'patients-queue';
			}
			else if (jq(this).attr('id') == 'dispense'){
				redirectLink = 'dispense-drugs';
			}
			else if (jq(this).attr('id') == 'patient'){
				redirectLink = 'issue-to-patient';
			}
			else if (jq(this).attr('id') == 'accounts'){
				redirectLink = 'issue-to-account';
			}
			else if (jq(this).attr('id') == 'stock'){
				redirectLink = 'current-stock';
			}
			else if (jq(this).attr('id') == 'expired'){
				redirectLink = 'expired-stock';
			}
			else if (jq(this).attr('id') == 'indent'){
				redirectLink = 'indent-drugs';
			}
			else if (jq(this).attr('id') == 'summary'){
                redirectLink = 'dispense-summaries';
            }
			else{
				return false;
			}
			
			window.location.href = ui.pageLink("pharmacyapp", "container", {
				rel: redirectLink
			});
		});
		
		jq(window).resize(function(){
			var d=jq('#main-dashboard');
			var m=0.5306122;
			
			d.height((d.width()*m));
		}).resize();
		
	});
</script>

<div class="clear"></div>
<div class="container">
	<div class="example">
		<ul id="breadcrumbs">
			<li>
				<a href="${ui.pageLink('kenyaemr','userHome')}">
					<i class="icon-home small"></i></a>
			</li>

			<li>
				<i class="icon-chevron-right link"></i>
				Pharmacy Dashboard
			</li>
		</ul>
	</div>
	<div class="patient-header new-patient-header">

		<div class="identifiers">
			<em>&nbsp; &nbsp; Current Time:</em>
			<span>${currentTime}</span>
		</div>
	</div>
</div>


<div id='main-dashboard'>
	<div id="queue">
		<i class="icon-group"></i><br/>
		<span>PHARMACY QUEUE</span>	
	</div>	

	<div id="dispense">
		<i class="icon-exchange"></i><br/>
		<span>DISPENSE DRUGS</span>	
	</div>
	<div id="patient">
		<i class="icon-user"></i><br/>
		<span>ISSUE TO PATIENT</span>	
	</div>
	
	<div id="stock">
		<i class="icon-paste"></i><br/>
		<span>DRUG STOCK</span>
	</div>
	
	<div id="expired">
		<i class="icon-calendar"></i><br/>
		<span>EXPIRED DRUGS</span>
	</div>
	
	<div id="accounts">
		<i class="icon-lock"></i><br/>
		<span>ISSUE TO ACCOUNT</span>
	</div>
	
	<div id="indent">
		<i class="icon-retweet"></i><br/>
		<span>ORDER DRUGS</span>
	</div>
	<div id="summary">
        <i class="icon-paper-clip"></i><br/>
        <span>DISPENSED DRUGS SUMMARIES</span>
    </div>
</div>

