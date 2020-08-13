<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Pharmacy Dashboard"])	
    ui.includeCss("pharmacyapp", "dashboard.css")
%>

<script>
	jq(function () {
		var redirectLink = '';
		
		jq('#queue, #dispense, #patient, #stock, #expired, #accounts, #indent').on('click', function(){
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
			else{
				return false;
			}
			
			window.location.href = emr.pageLink("pharmacyapp", "container", {
				rel: redirectLink
			});
		});
		
		jq(window).resize(function(){
			var d=jq('#main-dashboard');
			var m=0.5306122;
			
			d.height((d.width()*m));
			
			console.log(d.height());
		}).resize();
		
	});
</script>

<div class="clear"></div>
<div class="container">
	<div class="example">
		<ul id="breadcrumbs">
			<li>
				<a href="${ui.pageLink('referenceapplication','home')}">
				<i class="icon-home small"></i></a>
			</li>
			
			<li>
				<i class="icon-chevron-right link"></i>
				Pharmacy Dasboard
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
</div>

