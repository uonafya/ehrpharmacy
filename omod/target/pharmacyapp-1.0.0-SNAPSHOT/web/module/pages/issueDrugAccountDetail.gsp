<%
    ui.decorateWith("appui", "standardEmrPage", [title: "View Drug List Items"])
    ui.includeCss("billingui", "jquery.dataTables.min.css")
	
    ui.includeCss("registration", "onepcssgrid.css")
    ui.includeCss("pharmacyapp", "container.css")

    ui.includeJavascript("billingui", "moment.js")
    ui.includeJavascript("billingui", "jq.print.js")
    ui.includeJavascript("billingui", "jquery.dataTables.min.js")
    ui.includeJavascript("laboratoryapp", "jq.browser.select.js")
    ui.includeJavascript("billingui", "jquery.PrintArea.js")
%>

<script>
    ACCOUNT = {
        detailDrugAccount: function (issueId) {
            if (SESSION.checkSession()) {
                url = "issueDrugAccountDetail.form?issueId=" + issueId + "&keepThis=false&TB_iframe=true&height=500&width=1000";
                tb_show("Detail Account Drug....", url, false);
            }
        }
    }
</script>

<script>
    jQuery(document).ready(function () {
        jq("#printButton").on("click", function (e) {
            jq("#print").print({
				globalStyles: 	false,
				mediaPrint: 	false,
				stylesheet: 	'${ui.resourceLink("pharmacyapp", "styles/print-out.css")}',
				iframe: 		false,
				width: 			800,
				height:			700
			});			
        });
		
        jq("#returnToDrugList").on("click", function (e) {
            window.location.href = emr.pageLink("pharmacyapp", "container", {
                "rel": "issue-to-account"
            });
        });
    });
</script>

<style>
	#queueList td:first-child{
		width: 5px;
	}
	
	#queueList td:last-child{
		width: 85px;
	}
	.print-only{
		display: none;
	}
</style>

<div class="clear"></div>
<div id="accounts-div">
	<div class="container">
		<div class="example">
			<ul id="breadcrumbs">
				<li>
					<a href="${ui.pageLink('referenceapplication', 'home')}">
						<i class="icon-home small"></i></a>
				</li>
				
				<li>
					<a href="${ui.pageLink('pharmacyapp', 'dashboard')}">
						<i class="icon-chevron-right link"></i>
						Pharmacy
					</a>
				</li>
				
				<li>
					<a href="${ui.pageLink('pharmacyapp', 'container', [rel:'issue-to-account'])}">
						<i class="icon-chevron-right link"></i>
						Drug List
					</a>
				</li>

				<li>
					<i class="icon-chevron-right link"></i>
					View Details
				</li>
			</ul>
		</div>
		
		<div class="patient-header new-patient-header">
			<div class="demographics">
				<h1 class="name" style="border-bottom: 1px solid #ddd;">
					<span>&nbsp; ACCOUNT DRUG ITEMS &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
				</h1>				
			</div>			
			
			<div class="show-icon">
				&nbsp;
			</div>		
		</div>
	</div>
</div>

<div id="print">
	<center class="print-only">		
		<h2>
			<img width="100" height="100" align="center" title="OpenMRS" alt="OpenMRS" src="${ui.resourceLink('billingui', 'images/kenya_logo.bmp')}"><br/>
			<b>
				<u>${userLocation}</u>
			</b>
		</h2>
		
		<h2>
			ACCOUNT: ${issueAccountName}		
		</h2>
	</center>
	
	<span class="print-only right" style="margin-right: 20px;">${issueAccountDate}</span>
	
    <table cellpadding="5" cellspacing="0" width="100%" id="queueList">
        <tr align="center">
			<thead>
				<th>#</th>
				<th>CATEGORY</th>
				<th>NAME</th>
				<th>FORMULATION</th>
				<th>DATE</th>
				<th>QUANTITY</th>			
			</thead>
        </tr>
        <% if (listDrugIssue != null || listDrugIssue != "") { %>
        <% listDrugIssue.eachWithIndex { pTransaction, index -> %>
        <tr>
            <td>${index+1}</td>
            <td>${pTransaction.transactionDetail.drug.category.name}</td>
            <td>${pTransaction.transactionDetail.drug.name}</td>
            <td>${pTransaction.transactionDetail.formulation.name}-${pTransaction.transactionDetail.formulation.dozage}</td>
            <td>${ui.formatDatePretty(pTransaction.transactionDetail.dateExpiry)}</td>
            <td>${pTransaction.quantity}</td>
		<% } %>
		<% } else { %>
			<tr align="center">
				<td colspan="6">No drug found</td>
			</tr>
        <% } %>
    </table>
	
	<div class="print-only" style="margin: 10px;">
		<span>Issuing Pharmacist: <b>${pharmacist}</b></span>
	</div>

	<div class="print-only" style="margin-top: 50px;text-align: center">
		<span>Signature of Inventory Clerk/ Stamp</span>
	</div>
</div>

<div>
    <span class="button task right" id="printButton" style="margin-top:5px;"><i class="icon-print small"></i> Print List</span>
    <span class="button cancel" id="returnToDrugList" style="margin-top:5px;">Return To List</span>
</div>