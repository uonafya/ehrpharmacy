<script>
	jq(function () {
		getStockList();

        jq('#drugName, #attribute').on("keyup",function(){
            reloadList();
        });

        jq('#categoryId').on("change", function(){
            reloadList();
        });

        function reloadList() {
            var drugName = jq("#drugName").val();
            var categoryId = jq("#categoryId").val();
            var attribute = jq("#attribute").val();
            getStockList(drugName, categoryId, attribute);
        }
    });//end of doc ready
	
    function StockTable(tests) {
        var jq = jQuery;
        jq('#stock-list-table > tbody > tr').remove();
        var tbody = jq('#stock-list-table > tbody');
        for (index in tests) {
            var row = '<tr>';
            var c = parseInt(index) + 1;

            var item = tests[index];

            var pageLinkEdit = ui.pageLink("pharmacyapp", "viewCurrentStockBalanceDetail", {
                drugId: item.drug.id,
                formulationId: item.formulation.id,
            });

            row += '<td>' + c + '</td>'
            row += '<td><a href="'+ pageLinkEdit +'" >' + item.drug.name + '<a/></td>'
            row += '<td>'+ item.drug.category.name +'</td>';
            row += '<td>'+ item.formulation.name+"-"+item.formulation.dozage +'</td>';
            row += '<td>'+ item.currentQuantity +'</td>';
            row += '<td>'+ item.reorderPoint +'</td>';

            if (item.drug.attribute === 1){
                row += '<td>A</td>';
            }
            else {
                row += '<td>B</td>';
            }
            row += '</tr>';
            tbody.append(row);
        }
    }

    function getStockList(drugName, categoryId, attribute) {
        jq.getJSON('${ui.actionLink("pharmacyapp", "ViewDrugStock", "list")}',
        {
            drugName: drugName,
            categoryId: categoryId,
            attribute: attribute,
        }).success(function (data) {
            if (data.length === 0 && data != null) {
                jq().toastmessage('showErrorToast', "No drugs found!");
                jq('#stock-list-table > tbody > tr').remove();
                var tbody = jq('#stock-list-table > tbody');
                var row = '<tr align="center"><td colspan="7">No drugs found</td></tr>';
                tbody.append(row);

            } else {
                StockTable(data);

            }
        }).error(function () {
            jq().toastmessage('showErrorToast', "An Error Occured while Fetching List");
            jq('#stock-list-table > tbody > tr').remove();
            var tbody = jq('#stock-list-table > tbody');
            var row = '<tr align="center"><td colspan="7">No drugs found</td></tr>';
            tbody.append(row);

        });
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
		width: 80px;
	}
	th:nth-child(7){
		width: 90px;
	}
	th:last-child,
	td:last-child{
		width: 90px;
		text-align: center;
	}
</style>

<div class="clear"></div>
<div id="current-div">
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
					Current Stock
				</li>
			</ul>
		</div>
		
		<div class="patient-header new-patient-header">
			<div class="demographics">
				<h1 class="name" style="border-bottom: 1px solid #ddd;">
					<span>&nbsp; VIEW CURRENT STOCK &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
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
		
		<table id="stock-list-table">
			<thead>
				<tr>
					<th>#</th>
					<th>NAME</th>
					<th>CATEGORY</th>
					<th>FORMULATION</th>
					<th>QUANTITY</th>
					<th title="REORDER LEVEL/POINT">REORDER</th>
					<th>ATTRIBUTE</th>
				</tr>
			</thead>

			<tbody>
				<tr align="center">
					<td>&nbsp;</td>
					<td colspan="6">No drug found</td>
				</tr>
			</tbody>
		</table>
		

	</div>
</div>








<div>
    

    <div id="stock-list" style="display: block; margin-top:3px;">
        <div role="grid" class="dataTables_wrapper" id="stock-list-table_wrapper">
        </div>
    </div>
</div>