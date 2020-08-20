<%
    ui.decorateWith("appui", "standardEmrPage", [title: "View Expired Drug Stock"])
	ui.includeCss("pharmacyapp", "views.css")
	ui.includeJavascript("ehrcashier", "moment.js")
%>

<script>
    jq(function (){

        jq.getJSON('${ui.actionLink("pharmacyapp", "ViewStockBalanceDetail", "viewStockBalanceDetail")}',{
			drugId :${drugId},
			formulationId: ${formulationId},
			expiry: ${expiry},
			"currentPage": 1
		} ).success(function (data) {
			if (data.length === 0 && data != null) {
				jq('#expiry-detail-results-table > tbody > tr').remove();

				var row = '<tr align="center">';
				row += '<td>0</td>';
				row += '<td colspan="7">No Records Found</td>';
				row += '</tr>';

				tbody.append(row);
			} else {
				updateQueueTable(data)
			}
		});

    })

</script>
<script>
    //update the queue table
    function updateQueueTable(tests) {
        jq('#expiry-detail-results-table > tbody > tr').remove();
        var tbody = jq('#expiry-detail-results-table > tbody');

        for (index in tests) {
			var row = '<tr>';
            var item = tests[index];
			var attr = 'B';

			if (item.drug.attribute == 1){
				attr = 'A';
			}

			row += '<td>' + (1+parseInt(index)) + '</td>';
			row += '<td>' + item.transaction.typeTransactionName + '</td>';
			row += '<td>' + item.openingBalance + '</td>';
			row += '<td>' + item.issueQuantity + '</td>';
			row += '<td>' + item.currentQuantity + '</td>';
			row += '<td>' + item.closingBalance + '</td>';
			row += '<td>' + item.dateManufacture.substring(0, 11).replaceAt(2, ",").replaceAt(6, " ").insertAt(3, 0, " ") + '</td>';
			row += '<td>' + item.dateExpiry.substring(0, 11).replaceAt(2, ",").replaceAt(6, " ").insertAt(3, 0, " ") + '</td>';

            row += '</tr>';
            tbody.append(row);
        }
    }
</script>

<style>
	.name {
		color: #f26522;
	}
	#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
		text-decoration: none;
	}
</style>

<div class="clear"></div>
<div id="expired" class="container">
	<div class="example">
        <ul id="breadcrumbs">
            <li>
                <a href="${ui.pageLink('referenceapplication', 'home')}">
                    <i class="icon-home small"></i></a>
            </li>
			
            <li>
                <i class="icon-chevron-right link"></i>
                <a href="${ui.pageLink('pharmacyapp', 'dashboard')}">Pharmacy</a>
            </li>
			
			<li>
                <i class="icon-chevron-right link"></i>
                <a href="${ui.pageLink('pharmacyapp', 'container', [rel:'expired-stock'])}">Expired Drugs</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                Drug Stock
            </li>
        </ul>
    </div>

	<div class="patient-header new-patient-header">
		<div class="demographics">
            <h1 class="name" style="border-bottom: 1px solid #ddd;">
                <span>VIEW EXPIRED DRUGS STOCK &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
            </h1>
        </div>

		<div class="show-icon">
			&nbsp;
		</div>

		<div class="exampler">

			<div>
				<span>Drug Name:</span><b>${drug.name}</b><br/>
				<span>Category:</span>${drug.category.name}<br/>
				<span>Formulation:</span>${formulation.name}: ${formulation.dozage}<br/>
			</div>
		</div>
	</div>
</div>

<div id="expiry-detail-results" style="display: block; margin-top:3px;">
    <div role="grid" class="dataTables_wrapper" id="expiry-detail-results-table_wrapper">
        <table id="expiry-detail-results-table" class="dataTable" aria-describedby="expiry-detail-results-table_info">
            <thead>
				<tr role="row">
					<th>#</th>
					<th>TRANSACTION</th>
					<th>OPENING</th>
					<th>ISSUED</th>
					<th>RECEIVED</th>
					<th>CLOSING</th>
					<th>MANUFACTURED</th>
					<th>EXPIRY DATE</th>
				</tr>
            </thead>

            <tbody role="alert" aria-live="polite" aria-relevant="all">
				<tr align="center">
					<td colspan="6">No Drugs found</td>
				</tr>
            </tbody>
        </table>

    </div>
</div>



