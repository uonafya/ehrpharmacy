<% ui.includeJavascript("ehrconfigs", "moment.js") %>
%>
<script>
jq(function () {
    jQuery('.date-pick').datepicker({minDate: '-100y', dateFormat: 'dd/mm/yy'});
    jq('#toDate, #fromDate').change(function(){
        pullRecords();
    });

    function IssuedDrugViewModel() {
                var self = this;
                // Editable data
                self.drugDispenseList = ko.observableArray([]);
                var mappedDrugItems = jQuery.map(receiptsData, function (item) {
                    if((item.values===0)&&(item.statuss===1)){
                        return item;
                    }else if((item.values!==0)&&(item.statuss===1)){
                        return item;
                    }else{
    //                    do nothing, the item has not been processed from the cashier side
                    }

                });

                self.drugDispenseList(mappedDrugItems);
                self.viewDetails = function (item) {
                    var url = '${ui.pageLink("pharmacyapp","printDrugOrder")}';
                    window.location.href = url + "?issueId=" + item.id;
                };
            }
    function pullRecords(){
        var issueName	= jq("#dIssuedName").val();
        var fromDate 	= moment(jq("#fromDate-field").val()).format('DD/MM/YYYY');
        var toDate 		= moment(jq("#toDate-field").val()).format('DD/MM/YYYY');
        var receiptId 	= jq("#dReceiptId").val();
        var results 	= getOrderList(issuedName, fromDate, toDate, receiptId);
        list.drugDispensedList(results);
    }
    var list = new IssuedDrugViewModel();
            ko.applyBindings(list, jq("#orderDrugList")[0]);

    		pullRecords();
});
function getOrderList(searchIssueName, fromDate, toDate, receiptId) {

        jQuery.ajax({
            type: "GET",
            url: '${ui.actionLink("pharmacyapp", "subStoreListDispense", "getDispenseList")}',
            dataType: "json",
            global: false,
            async: false,
            data: {
                searchIssueName: searchIssueName,
                fromDate: fromDate,
                toDate: toDate,
                processed: processed,
                receiptId: receiptId
            },
            success: function (data) {
                toReturn = data;
            }
        });

        return toReturn;
    }
</script>
<style>
	#divSeachProcessed{
		margin-right: 5px;
		margin-top: 23px;
	}
	#divSeachProcessed label{
		cursor: pointer;
	}
	#divSeachProcessed input{
		cursor: pointer;
	}
	.process-lozenge {
		border: 1px solid #f00;
		border-radius: 4px;
		color: #f00;
		display: inline-block;
		font-size: 0.7em;
		padding: 1px 2px;
		vertical-align: text-bottom;
	}
	.process-seen {
		background: #fff799 none repeat scroll 0 0 !important;
		color: #000 !important;
	}
	a:link {
		color: blue;
		text-decoration: none;
		cursor: pointer;
	}
</style>
<div class="clear"></div>
<div id="summary-div">
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
                    Dispensed
                </li>
            </ul>
        </div>
        <div class="patient-header new-patient-header">
            <div class="demographics">
                <h1 class="name" style="border-bottom: 1px solid #ddd;">
                    <span>DRUGS DISPENSED LIST &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
                </h1>
            </div>

            <div class="show-icon">
                &nbsp;
            </div>
            <div class="filter">
                <i class="icon-filter" style="color: rgb(91, 87, 166); float: left; font-size: 52px ! important; padding: 0px 10px 0px 0px;"></i>
                <div class="first-col">
                    <label for="dIssuedName">Patient Name</label><br/>
                    <input type="text" name="dIssuedName" id="dIssuedName" placeholder="Patient Name" class="dispenseSearch"/>
                </div>

                <div class="first-col">
                    <label for="fromDate-display">From Date</label><br/>
                    ${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'fromDate', label: 'Date', formFieldName: 'fromDate', useTime: false, defaultToday: true])}
                </div>

                <div class="first-col">
                    <label for="toDate-display">To Date</label><br/>
                    ${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'toDate',   label: 'Date', formFieldName: 'toDate',   useTime: false, defaultToday: true])}
                </div>

                <div class="first-col">
                    <label for="dReceiptId">Receipt No.</label><br/>
                    <input type="text" name="dReceiptId" id="dReceiptId" placeholder="Receipt No." class="dispenseSearch"/>
                </div>
            </div>
        </div>
    </div>
</div>
<form method="get" id="form">
    <div id="orderDrugList">
        <table width="100%" cellpadding="5" cellspacing="0">
            <thead>
				<tr>
					<th>#</th>
					<th>RECEIPT#</th>
					<th>IDENTIFIER</th>
					<th>NAME</th>
					<th>DATE</th>
					<th>ACTION</th>
				</tr>
            </thead>
            <tbody data-bind="foreach: drugDispenseList">
            <tr data-bind="css: {'process-seen': flag == 2}">
                <td data-bind="text: \$index() + 1"></td>
                <td data-bind="text: id"></td>
                <td data-bind="text: identifier"></td>
                <td>
                    <span data-bind="text: givenName"></span>&nbsp;
                    <span data-bind="text: familyName"></span>&nbsp;
                    <span data-bind="text: middleName"></span>
                    <span data-bind="visible: flag == 2" class="process-lozenge">Processed</span>
                </td>
                <td data-bind="text: moment(new Date(createdOn)).format('DD, MMM YYYY')"></td>
                <td>
                    <a class="remover" href="#" data-bind="click: \$root.viewDetails"
                       title="Detail issue drug to this patient">
						<span data-bind="visible: flag == 1">
							<i class="icon-cogs small"></i>
							PROCESS
						</span>

						<span data-bind="visible: flag == 2">
							<i class="icon-bar-chart small"></i>
							VIEW
						</span>
                    </a>
                </td>

            </tr>
            </tbody>
        </table>
    </div>
</form>

<div class="footer">&nbsp;</div>