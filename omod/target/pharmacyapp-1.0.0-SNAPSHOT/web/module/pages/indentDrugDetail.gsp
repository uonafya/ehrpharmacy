<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Pharmacy Module"])
	ui.includeCss("pharmacyapp", "container.css")
	ui.includeJavascript("ehrcashier", "jq.print.js")
    ui.includeJavascript("ehrconfigs", "jquery-1.12.4.min.js")
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
    jq(function(){

    });//end of doc ready
    function printDiv(){
		jq("#printDiv").print({
			globalStyles: 	false,
			mediaPrint: 	false,
			stylesheet: 	'${ui.resourceLink("pharmacyapp", "styles/print-out.css")}',
			iframe: 		false,
			width: 			1000,
			height:			700
		});
    }
    function mainPage() {
        window.location.href = ui.pageLink("pharmacyapp", "container", {
            "rel": "indent-drugs"
        });
    }

</script>

<style>
	table{
		font-size: 14px;
	}
	#printDiv,
	.print-only{
		display: none;
	}
</style>

<div id="indents-div">
	<div class="container">
		<div class="example">
			<ul id="breadcrumbs">
				<li>
					<a href="${ui.pageLink('kenyaemr', 'userHome')}">
						<i class="icon-home small"></i></a>
				</li>
				
				<li>
					<a href="${ui.pageLink('pharmacyapp', 'dashboard')}">
						<i class="icon-chevron-right link"></i>
						Pharmacy
					</a>
				</li>
				
				<li>
					<a href="${ui.pageLink('pharmacyapp', 'container',['rel':'indent-drugs'])}">
						<i class="icon-chevron-right link"></i>
						Order List
					</a>
				</li>

				<li>
					<i class="icon-chevron-right link"></i>
					Ident Details
				</li>
			</ul>
		</div>
		
		<div class="patient-header new-patient-header">
			<div class="demographics" style="margin-bottom: 2px;">
				<h1 class="name" style="border-bottom: 1px solid #ddd;">
					<span>&nbsp;DRUG ORDER DETAILS &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
				</h1>				
			</div>			
			
			<div class="show-icon">
				&nbsp;
			</div>
		</div>
		
	</div>
</div>

<% if (listTransactionDetail == null) { %>
<table width="100%" cellpadding="5" cellspacing="0">
    <tr>
        <th>S.No</th>
        <th>Category</th>
        <th>Drug Name</th>
        <th>Formulation</th>
        <th>Quantity</th>
        <th>Transfer Quantity</th>
    </tr>

    <% if (listIndentDetail != null) { %>
    <% listIndentDetail.eachWithIndex { indent, varStatus -> %>
    <tr align="center" class='${varStatus.index % 2 == 0 ? "oddRow" : "evenRow"} '>
        <td>${varStatus +1}</td>
        <td>${indent.drug.category.name}</td>
        <td>${indent.drug.name}</td>
        <td>${indent.formulation.name}-${indent.formulation.dozage}</td>
        <td>${indent.quantity}</td>
        <td>${indent.mainStoreTransfer}</td>
    </tr>

    <% }
    } %>
</table>

<div style="margin-top: 10px;">
	<span class="button task right" onClick="printDiv();">
		<i class="icon-print small"> </i>Print		
	</span>
	
	<span class="button cancel" onClick="mainPage();">
		Return to List  
	</span>
</div>
	   
	   
	   
<!-- PRINT DIV -->
<div id="printDiv" class="print-only">
    <div>
        <center class="print-only">		
			<h2>
				<img width="100" height="100" align="center" title="OpenMRS" alt="OpenMRS" src="${ui.resourceLink('ehrcashier', 'images/kenya_logo.bmp')}"><br/>
				<b>
					<u>${userLocation}</u>
				</b>
			</h2>
			
			<h2><b>ORDER FROM: ${store.name}</b></h2>
		</center>
		
		<span class="print-only right" style="margin-right: 20px;">${date}</span>
		
        <table border="1">
            <tr>
                <th>S.No</th>
                <th>Category</th>
                <th>Drug Name</th>
                <th>Formulation</th>
                <th>Quantity</th>
                <th>Transfer Quantity</th>
            </tr>

            <% if (listIndentDetail != null) { %>
            <% listIndentDetail.eachWithIndex { indent, varStatus -> %>
            <tr align="center" class='${varStatus % 2 == 0 ? "oddRow" : "evenRow"} '>
                <td>${varStatus+1}</td>
                <td>${indent.drug.category.name}</td>
                <td>${indent.drug.name}</td>
                <td>${indent.formulation.name}-${indent.formulation.dozage}</td>
                <td>${indent.quantity}</td>
                <td>${indent.mainStoreTransfer}</td>
            </tr>

            <% }
            } %>

        </table>

        <div style="margin-top: 40px;">
			<span>Signature of sub-store/ Stamp</span>
			<span style="float:right;">Signature of inventory clerk/ Stamp</span>		
		</div>
        
        <br/><br/>
		<center>
			<span>Signature of Medical Superintendent/ Stamp</span>		
		</center>
    </div>
</div>
<!-- END PRINT DIV -->


<% } else { %>

<table width="100%" cellpadding="5" cellspacing="0">
			<tr>
				<thead>
					<th>#</th>
					<th>CATEGORY</th>
					<th>DRUG</th>
					<th>FORMULATION</th>
					<th>QUANTITY</th>
					<th>BATCH#</th>
					<th>EXPIRY</th>
					<th>COMPANY</th>
					<th>TRANSFER</th>
				</thead>
            </tr>

<% if (listIndentDetail != null) {
    def count = 0;
    def check = 0;
    listIndentDetail.eachWithIndex { indent, varStatus -> %>
<tr class='${varStatus % 2 == 0 ? "oddRow" : "evenRow"} '>
    <td>${varStatus +1}</td>
    <td>${indent.drug.category.name}</td>
    <td>${indent.drug.name}</td>
    <td>${indent.formulation.name}-${indent.formulation.dozage}</td>
    <td>${indent.quantity}</td>
    <% listTransactionDetail.each { trDetail -> %>
    <% if (trDetail.drug.id == indent.drug.id && trDetail.formulation.id == indent.formulation.id) {
        check = 1; %>
    <% if (count > 0) { %>
	
    <td>${trDetail.batchNo}</td>
    <td>${ui.formatDatePretty(trDetail.dateExpiry)}</td>
    <td>${trDetail.companyName}</td>
    <td>${trDetail.issueQuantity}</td>
</tr>

<% } else { %>
<td>${trDetail.batchNo}</td>
<td>${ui.formatDatePretty(trDetail.dateExpiry)}</td>
<td>${trDetail.companyName}</td>
<td>${trDetail.issueQuantity}</td>
</tr>

<% }
    count++;
} %>

<% } %>
<% if (check == 0) { %>
<td>N/A</td>
<td>N/A</td>
<td>N/A</td>
<td>0</td>
</tr>
<% } %>

<% }
} %>

</table>

<div style="margin-top: 10px;">
	<span class="button task right" onClick="printDiv();">
		<i class="icon-print small"> </i>Print		
	</span>
	
	<span class="button cancel" onClick="mainPage();">
		Return to List  
	</span>
</div>

<!-- PRINT DIV -->
<div id="printDiv" class="print-only">
    <div>
        <center class="print-only">		
			<h2>
				<img width="100" height="100" align="center" title="OpenMRS" alt="OpenMRS" src="${ui.resourceLink('ehrcashier', 'images/kenya_logo.bmp')}"><br/>
				<b>
					<u>${userLocation}</u>
				</b>
			</h2>
			
			<h2><b>ORDER FROM: ${store.name}</b></h2>
		</center>
		
		<span class="print-only right" style="margin-right: 20px;">${date}</span>
		
        <table border="1">
            <tr>
				<thead>
					<th>#</th>
					<th>CATEGORY</th>
					<th>DRUG</th>
					<th>FORMULATION</th>
					<th>QUANTITY</th>
					<th>BATCH#</th>
					<th>EXPIRY</th>
					<th>COMPANY</th>
					<th>TRANSFER</th>
				</thead>
            </tr>

            <% if (listIndentDetail != null) {
                def count = 0;
                def check = 0;
                listIndentDetail.eachWithIndex { indent, varStatus -> %>
            <tr align="center" class='${varStatus % 2 == 0 ? "oddRow" : "evenRow"} '>
                <td>${varStatus+1}</td>
                <td>${indent.drug.category.name}</td>
                <td>${indent.drug.name}</td>
                <td>${indent.formulation.name}-${indent.formulation.dozage}</td>
                <td>${indent.quantity}</td>
                <% listTransactionDetail.each { trDetail -> %>
                <% if (trDetail.drug.id == indent.drug.id && trDetail.formulation.id == indent.formulation.id) {
                    check = 1; %>
                <% if (count > 0) { %>
           
                <td>${trDetail.batchNo}</td>
                <td>${ui.formatDatePretty(trDetail.dateExpiry)}</td>
                <td>${trDetail.companyName}</td>
                <td>${trDetail.issueQuantity}</td>
            </tr>

            <% } else { %>
            <td>${trDetail.batchNo}</td>
            <td>${ui.formatDatePretty(trDetail.dateExpiry)}</td>
            <td>${trDetail.companyName}</td>
            <td>${trDetail.issueQuantity}</td>
        </tr>

            <% }
                count++;
            } %>

            <% } %>
            <% if (check == 0) { %>
            <td>N/A</td>
            <td>N/A</td>
            <td>N/A</td>
            <td>0</td>
        </tr>
            <% } %>

            <% }
            } %>

        </table>
		
		<div style="margin-top: 40px;">
			<span>Signature of sub-store/ Stamp</span>
			<span style="float:right;">Signature of inventory clerk/ Stamp</span>		
		</div>
        
        <br/><br/>
		<center>
			<span>Signature of Medical Superintendent/ Stamp</span>		
		</center>
    </div>
</div>
<!-- END PRINT DIV -->


<% } %>
