<script>
    jq(function () {
        jq("#drugName, #attribute").on("keyup", function () {
            reloadExpiredDrugs();
        });

        jq("#categoryId").change(function() {
            reloadExpiredDrugs();
        });

        function reloadExpiredDrugs() {
            var categoryId 	= jq("#categoryId").val();
            var drugName 	= jq("#drugName").val();
            var attribute 	= jq("#attribute").val();
			
            getExpiredDrugs(categoryId, drugName, attribute);
        }
		
		reloadExpiredDrugs();
    });

    function getExpiredDrugs(categoryId, drugName, attribute) {
        jq.getJSON('${ui.actionLink("pharmacyapp", "ViewExpiredDrugs", "viewStockBalanceExpired")}',{
			categoryId: categoryId,
			drugName: drugName,
			attribute: attribute
		}).success(function (data) {
			if (data.length === 0 && data != null) {
				jq().toastmessage('showErrorToast', "Criteria did not match any drugs drugs found!");
				
				jq('#expiry-list-table > tbody > tr').remove();
				var tbody = jq('#expiry-list-table > tbody');
				var row = '<tr align="center"><td></td><td colspan="7">No Drugs found</td></tr>';
				tbody.append(row);

			} else {
				ExpiryTable(data);
			}
		}).error(function () {
			jq().toastmessage('showErrorToast', "An Error Occurred while Fetching List");
			
			jq('#expiry-list-table > tbody > tr').remove();
			var tbody = jq('#expiry-list-table > tbody');
			var row = '<tr align="center"><td></td><td colspan="7">No drugs found</td></tr>';
			tbody.append(row);
		});
    }

    function ExpiryTable(tests) {
        var jq = jQuery;
        jq('#expiry-list-table > tbody > tr').remove();
        var tbody = jq('#expiry-list-table > tbody');
        for (index in tests) {
            var row = '<tr>';
            var c = parseInt(index) + 1;

            var item = tests[index];

            var pageLinkEdit = ui.pageLink("pharmacyapp", "viewStockBalanceDetail", {
                drugId: item.drug.id,
                formulationId: item.formulation.id,
                expiry: 1
            });

            row += '<td>' + c + '</td>'
            row += '<td><a href="' + pageLinkEdit + '">' + item.drug.name + '</a></td>';
            row += '<td>'+ item.drug.category.name +'</td>';
            row += '<td>'+ item.formulation.name+"-"+item.formulation.dozage +'</td>';
            row += '<td>'+ item.currentQuantity +'</td>';

            if (item.drug.attribute === 1){
                row += '<td>A</td>';
            }
            else {
                row += '<td>B</td>';
            }

            row += '<td><a href="' + pageLinkEdit + '"><i class="icon-caret-right small"></i>VIEW</a></td>';


            row += '</tr>';
            tbody.append(row);
        }
    }
</script>

<style>
	.zero-col{
		width: 52%;
	}
	th:first-child{
		width: 5px;
	}
	th:nth-child(5){
		width: 85px;
	}
	th:nth-child(6){
		width: 90px;
	}
	th:last-child,
	td:last-child{
		width: 65px;
		align: center;
	}

</style>

<div class="clear"></div>
<div id="expired-div">
	<div class="container">
		<div class="example">
			<ul id="breadcrumbs">
				<li>
					<a href="${ui.pageLink('kenyaemr', 'userHome')}">
						<i class="icon-home small"></i></a>
				</li>
				
				<li>
					<a href="${ui.pageLink('pharmacyapp', 'dashboard')}">
						<i class="icon-chevron-right link"></i>Pharmacy
					</a>
				</li>

				<li>
					<i class="icon-chevron-right link"></i>
					Expired Drugs
				</li>
			</ul>
		</div>
		
		<div class="patient-header new-patient-header">
			<div class="demographics">
				<h1 class="name" style="border-bottom: 1px solid #ddd;">
					<span>&nbsp; VIEW EXPIRED STOCK &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
				</h1>
			</div>
			
			<div class="show-icon">
				&nbsp;
			</div>
			
			<div class="filter">
				<i class="icon-filter" style="color: rgb(91, 87, 166); float: left; font-size: 52px ! important; padding: 0px 10px 0px 0px;"></i>
				<div class="zero-col">
					<label for="drugName">Drug Name</label><br/>
					<input type="text" id="drugName" class="searchFieldChange" name="drugName" placeholder="Enter Drug Name" title="Enter Drug Name" style="width: 100%; padding-left: 30px;" >
					<i class="icon-search" style="color: rgb(170, 170, 170); font-size: 16px ! important; margin-top: 3px; position: relative; margin-left: -99.5%; float: inherit;"></i>
				</div>
				
				<div class="first-col">
					<label for="categoryId">Category</label><br/>
					<select  id="categoryId" class="searchFieldChange" title="Select Category" style="width: 250px;">
						<option value>Select Category</option>
						<% listCategory.each { %>
							<option value="${it.id}" title="${it.name}">${it.name}</option>								
						<% } %>
					</select>
				</div>
				
				<div class="first-col">
					<label for="dReceiptId">Attribute</label><br/>
					<input type="text" id="attribute" name="attribute" placeholder="Enter Attribute" title="Enter Attribute" style="width: 130px;">
				</div>				
			</div>
		</div>
		
		<table id="expiry-list-table">
			<thead>
				<tr>
					<th>#</th>
					<th>NAME</th>
					<th>CATEGORY</th>
					<th>FORMULATION</th>
					<th>QUANTITY</th>
					<th>ATTRIBUTE</th>
					<th>ACTION</th>
				</tr>
			</thead>

			<tbody>
				<tr align="center">
					<td>&nbsp;</td>
					<td colspan="7">No drug found</td>
				</tr>
			</tbody>
		</table>
		
		
	</div>
</div>
<div id="expiry-list" style="display: block; margin-top:3px;">
        <div role="grid" class="dataTables_wrapper" id="expiry-list-table_wrapper">

        </div>
    </div>
