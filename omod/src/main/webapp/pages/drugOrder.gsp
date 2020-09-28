<%
    ui.decorateWith("kenyaemr", "standardPage")
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
    ui.includeJavascript("ehrcashier", "jq.print.js")
%>

<script>
	var list;
    var drugOrders = [];

    var confirmdrugdialog;
    var processdrugdialog;

    var listOfDrugQuantity = "";
    var focusItem;
    var processedOrders = [];

    jq(function () {
        var isError = false;

        jq.extend({
            toDictionary: function (query) {
                var parms = {};
                var items = query.split("&"); // split
                for (var i = 0; i < items.length; i++) {
                    var values = items[i].split("=");
                    var key = decodeURIComponent(values.shift());
                    var value = values.join("=")
                    parms[key] = decodeURIComponent(value);
                }
                return (parms);
            }
        });
		
		jq('.title').on('click', 'a', function(){
			jq("#print-section").print({
				globalStyles: false,
				mediaPrint: false,
				stylesheet: '${ui.resourceLink("pharmacyapp", "styles/print-out.css")}',
				iframe: false,
				width: 700,
				height: 500
			});
		});
		
		jq('#remove-items').on('click', 'a', function(){
			list.pRemove.push(focusItem);
			list.listItems.remove(focusItem);
			processdrugdialog.close();
		});
		
		
		
		jq('#processDrugOrderFormTable').on('click', 'td a', function(){
			list.pRemove.push(focusItem);
			list.listItems.remove(focusItem);
			processdrugdialog.close();
		});

        jq.fn.serializeFormJSON = function () {
            var o = [];
            jq(this).find('tr').each(function () {
                var elements = jq(this).find('input, textarea, select')
                if (elements.size() > 0) {
                    var serialized = jq(this).find('input, textarea, select').serialize();
                    var item = jq.toDictionary(serialized);
                    o.push(item);
                }
            });
            return o;
        };

        var jSonOrders = ${drugOrderListJson};
        var orderList = jSonOrders.simpleObjects;
        processdrugdialog = ui.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#processDrugDialog',
            actions: {
                confirm: function () {
                    //empty for now
                },
                cancel: function () {

                    processdrugdialog.close();
                }
            }
        });

        confirmdrugdialog = ui.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#confirmDrugDialog',
            actions: {
                confirm: function () {
                    confirmdrugdialog.close();
                    jq("#drugsForm").submit();
                },
                cancel: function () {
                    confirmdrugdialog.close();
                }
            }
        });

        jq(".dashboard-tabs").tabs();


        jq('#agename').html('${patient.age} years (' + moment('${patient.birthdate}').format('DD,MMM YYYY') + ')');
        jq('#lstdate').html('Last Visit: ' + moment('${previousVisit}').format('DD, MMM YYYY'));


        function OrderListViewModel() {
            var self = this;
            // Editable data
            self.listItems = ko.observableArray([]);
            self.pItems = ko.observableArray([]);
            self.pRemove = ko.observableArray([]);
			
            var mappedStockItems = jQuery.map(orderList, function (item) {
                return item;
            });

            self.viewDetails = function (item) {
                window.location.replace("viewCurrentStockBalanceDetail.page?drugId=" + item.drug.id + "&formulationId=" + item.formulation.id);

            }
            self.listItems(mappedStockItems);


            self.processDrugItem = function (item) {
                processDrug(item.inventoryDrug.id, item.inventoryDrugFormulation.id, item.frequency.name, item.noOfDays, item.comments, item);
            }

            self.issueDrugItem = function () {
                var totalIssue = 0;
                isError = false;
                jq('.klazz').each(function (i, obj) {
                    var v = obj.value;
                    if (!jq.isNumeric(v)) {
                        jq().toastmessage('showErrorToast', "Please Enter Correct Quantity For all Fields!");
                        isError = true;
                    } else {
                        totalIssue = parseInt(totalIssue) + parseInt(v);
                    }
                });
                if (totalIssue === 0) {
                    jq().toastmessage('showErrorToast', "Total Quantities to Dispense Must be greater than zero!");
                    isError = true;
                }

                if (!isError) {
                    var jsonString = jq("#processDrugOrderForm").serializeFormJSON();					
                    jq.each(jsonString, function (index, item) {
                        if (item.quantity > 0) {
                            self.pItems.push(item);//add the item to the processed array for display
                        }
                    });
                    self.listItems.remove(focusItem);
                    processdrugdialog.close();
                    listOfDrugQuantity = "";
                }
            }

            self.computedTotal = ko.computed(function () {
                var total = 0;
                for (var i = 0; i < self.pItems().length; i++) {
                    total += (self.pItems()[i].quantity * self.pItems()[i].price);
                }
                return total.toString().formatToAccounting();
            });

            self.removeItem = function (item) {
                if (self.pItems().length > 1) {
                    self.pItems.remove(item);
                } else {
                    jq().toastmessage('showErrorToast', "Process List Must Have at least 1 item");
                }

            }
            self.finishDrugOrder=function(){
                if (self.pItems().length < 1 && self.pRemove().length < 1) {
                    jq().toastmessage('showErrorToast', "Please Process At least One Drug!");
                    return false;
                }
				
				confirmdrugdialog.show();
                return false;

            }
        }


        list = new OrderListViewModel();
        ko.applyBindings(list, jq("#indent-search-result")[0]);
    });//end of doc ready

    function cancelDrugProcess() {
        window.location.href = ui.pageLink("pharmacyapp", "container", {
            "rel": "patients-queue",
            "date": '${date}'
        });
    }

    function printDiv2() {
        jq("#printDiv").print({
            globalStyles: false,
            mediaPrint: false,
            stylesheet: '${ui.resourceLink("pharmacyapp", "styles/print-out.css")}',
            iframe: false,
            width: 600,
            height: 700
        });
    }

    function checkValueExt(thiz, value) {
        if (parseInt(jq(thiz).val()) > parseInt(value)) {
            jq().toastmessage('showNoticeToast', "Issue Quantity is greater that available quantity!");
            jq(thiz).val("");
            jq(thiz).focus();
        }
    }

    function processDrug(drugId, formulationId, frequencyName, days, comments, item) {
        focusItem = item;
        jq.ajax({
            url: '${ ui.actionLink("pharmacyapp", "drugOrder", "listReceiptDrugAvailable") }',
            dataType: 'json',
            async: false,
            data: {
                drugId: drugId,
                formulationId: formulationId,
                frequencyName: frequencyName,
                days: days,
                comments: comments
            },
            success: function (data) {
                if (data.length === 0) {
                    jq('#processDrugOrderFormTable > tbody > tr').remove();
                    var tbody = jq('#processDrugOrderFormTable > tbody');
                    var row = '<tr>';
                    row += '<td></td><td colspan="6" style="padding: 5px 20px"> This drug is empty in your store, please order it. <a style="float: right;" class="red remove-item"><i class="icon-remove small"></i>Remove Drug from List</a></td>'
                    row += '<input id="' + drugId + '" name="' + drugId + '" type="hidden" />';
                    row += '</tr>';
                    tbody.append(row);
                    jq("#drugIssue").attr("disabled", true);
                    jq("#drugIssue").addClass("disabled");
					
					jq('#remove-items').hide();

                } else {
                    jq("#drugIssue").removeClass('disabled');
                    jq("#drugIssue").attr("disabled", false);
                    jq('#processDrugOrderFormTable > tbody > tr').remove();
                    var tbody = jq('#processDrugOrderFormTable > tbody');
                    var row = "";
                    jq.each(data, function (i, item) {
                        listOfDrugQuantity = item.id;
                        row += '<tr>' +
                                '<td>' + (i + 1) + '</td>' +
                                '<td>' + item.dateExpiry.substring(0, 11).replaceAt(2, ",").replaceAt(6, " ").insertAt(3, 0, " ") + '</td>' +
                                '<td>' + item.dateManufacture.substring(0, 11).replaceAt(2, ",").replaceAt(6, " ").insertAt(3, 0, " ") + '</td>' +
                                '<td title="' + item.companyName + '">' + item.companyNameShort + '</td>' +
                                '<td>' + item.batchNo + '</td>' +
                                '<td>' + item.currentQuantity + '</td>';
                        if (i === 0) {
                            row += '<td><input class="klazz" type="text" onchange="checkValueExt(this,' + item.currentQuantity + ')" value="" type="text" size="3" name="quantity" id="' + item.id + '_quantity" /></td>';
                        } else {
                            row += '<td><input class="klazz" type="text" onchange="checkValueExt(this,' + item.currentQuantity + ')" value="0" type="text" size="3" id="' + item.id + '_quantity" name="quantity" style="color:red;"/></td>';
                        }
                        row += '<input id="' + item.id + '_drugName" name="drugName" type="hidden" value="' + item.drug.name + '" />';
                        row += '<input id="' + item.id + '_formulation" name="formulation" type="hidden" value="' + item.formulation.name + "-" + item.formulation.dozage + '" />';
                        row += '<input id="' + item.id + '_formulationId" name="formulationId" type="hidden" value="' + item.formulation.id + '" />';
                        row += '<input id="' + item.id + '_frequencyName" name="frequencyName" type="hidden" value="' + frequencyName + '" />';
                        row += '<input id="' + item.id + '_noOfDays" name="noOfDays" type="hidden" value="' + days + '" />';
                        row += '<input id="' + item.id + '_comments" name="comments" type="hidden" value="' + comments + '" />';
                        row += '<input id="' + item.id + '_price" name="price" type="hidden" value="' + item.costToPatient + '" />';
                        row += '<input id="listOfDrugQuantity" name="listOfDrugQuantity" type="hidden" value="' + listOfDrugQuantity + '" />';
                        row += '</tr>';
                    });
					
                    tbody.append(row);
					jq('#remove-items').show();
                }
            },
            error: function (xhr, status, err) {
                jq().toastmessage('showNoticeToast', "AJAX error!" + err);
            }
        });
        processdrugdialog.show();
    }
</script>


<style>
	.name {
		color: #f26522;
	}
	input[type="text"],
	input[type="password"],
	select {
		border: 1px solid #aaa;
		border-radius: 0px !important;
		box-shadow: none !important;
		box-sizing: border-box !important;
		height: 38px !important;
		line-height: 18px !important;
		padding: 8px 10px !important;
		width: 100% !important;
	}

	input[type="text"]:focus, textarea:focus {
		outline: 2px solid #007fff !important;
	}

	textarea {
		width: 97%;
	}
	
	.toast-item {
        background-color: #222;
    }

	.append-to-value {
		color: #999;
		float: right;
		left: auto;
		margin-left: -50px;
		margin-top: 5px;
		padding-right: 10px;
		position: relative;
	}

	form h2 {
		margin: 10px 0 0;
		padding: 0 5px
	}

	.col1, .col2, .col3, .col4, .col5, .col6, .col7, .col8, .col9, .col10, .col11, .col12 {
		float: left;
	}

	form label, .form label {
		margin: 5px 0 0;
		padding: 0 5px
	}

	#datetime label {
		display: none;
	}
	#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
		color: #555;
		text-decoration: none;
	}
	.add-on {
		float: right;
		left: auto;
		margin-left: -29px;
		margin-top: 10px;
		position: absolute;
	}

	.dashboard .info-section {
		margin: 0 5px 5px;
	}

	.dashboard .info-body li {
		padding-bottom: 2px;
	}

	.dashboard .info-body li span {
		margin-right: 10px;
	}

	.dashboard .info-body li small {

	}

	.dashboard .info-body li div {
		width: 150px;
		display: inline-block;
	}

	.info-body ul li {
		display: none;
	}

	.simple-form-ui section.focused {
		width: 75%;
	}

	.new-patient-header .demographics .gender-age {
		font-size: 14px;
		margin-left: -55px;
		margin-top: 12px;
	}
	.new-patient-header .demographics .gender-age span {
		border-bottom: 1px none #ddd;
	}
	.new-patient-header .identifiers {
		margin-top: 10px;
	}
	.tag {
		padding: 2px 10px;
	}

	.tad {
		background: #666 none repeat scroll 0 0;
		border-radius: 1px;
		color: white;
		display: inline;
		font-size: 0.8em;
		padding: 2px 10px;
	}

	.status-container {
		padding: 5px 10px 5px 5px;
	}

	.catg {
		color: #363463;
		margin: 35px 10px 0 0;
	}

	.ui-tabs {
		margin-top: 5px;
	}

	.simple-form-ui section.focused {
		width: 74.6%;
		min-height: 400px;
	}

	.col15 {
		min-width: 22%;
		max-width: 22%;
		float: left;
		display: inline-block;
	}

	.col16 {
		min-width: 56%;
		max-width: 56%;
		float: left;
		display: inline-block;
	}
	.title{
		border: 	1px solid #eee;
		margin: 	3px 0;
		padding:	5px;
	}
	.title i{
		font-size: 1.5em;
		padding: 0;
	}
	
	.title a i{
		font-size: 16px;
	}
	
	.title a{
		color: #f26522;
		cursor: pointer;
		font-family: Arial,sans-serif;
		font-size: 16px;
		margin: 7px 5px;
	}
	
	.title a:hover{
		text-decoration: none;
	}
	
	.title span{
		font-size: 20px;
	}
	.title em{
		border-bottom: 1px solid #ddd;
		color: #888;
		display: inline-block;
		font-size: 0.5em;
		margin-right: 10px;
		width: 200px;
	}
	th:first-child{
		width: 5px;
	}
	th:last-child{
		width: 110px;
	}
	
	#orderListTable td:nth-child(4),
	#orderListTable td:nth-child(5),
	#orderListTable td:nth-child(6){
		width: 110px;
		text-align: right;
	}
	
	#processDrugOrderFormTable th:nth-child(2),
	#processDrugOrderFormTable th:nth-child(3){
		width: 110px;
	}
	#processDrugOrderFormTable td:nth-child(4){
		text-transform: capitalize;
	}
	#processDrugOrderFormTable th:nth-child(6),
	#processDrugOrderFormTable th:nth-child(7){
		width: 80px;
	}
	.buttons-div{
		margin-top: 5px;
	}
	#modal-overlay {
		background: #000 none repeat scroll 0 0;
		opacity: 0.4!important;
	}
	.dialog-content h3{
		border: 1px solid #eee;
		color: #363463;
		margin-top: 5px;
		padding: 10px;
		text-align: center;
	}
	td a,
	td a:hover{
		text-decoration: none;
	}
	.red{
		color: #f00;
		cursor: pointer;
	}
	
	#remove-items{
		display: table; 
		width: 100%; 
	}	
	
	#remove-items a:hover{
		text-decoration: none;
	}
	
	.dialog button{
		margin-top: 10px;
	}
	.print-only{
		display: none;
	}
</style>

<div class="clear"></div>

<div id="content">
    <div class="example">
        <ul id="breadcrumbs">
            <li>
                <a href="${ui.pageLink('kenyaemr', 'userHome')}">
                    <i class="icon-home small"></i></a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                <a href="${ui.pageLink('pharmacyapp', 'dashboard')}">Pharmacy</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                <a href="${ui.pageLink('pharmacyapp', 'container', [rel: 'patients-queue', date: date])}">Queue</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                <a href="${ui.pageLink('pharmacyapp', 'listOfOrder', [patientId: patientId, date: date])}">Orders</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                Process
            </li>
        </ul>
    </div>

    <div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name">
                <span id="surname">${patient.familyName},<em>surname</em></span>
                <span id="othname">${patient.givenName} ${patient.middleName ? patient.middleName : ''}&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<em>other names</em>
                </span>

            </span>

                <span class="gender-age">
                    <span>
                        <% if (patient.gender == "F") { %>
                        Female
                        <% } else { %>
                        Male
                        <% } %>
                    </span>
                    <span id="agename">${patient.age} years (15.Oct.1996)</span>

                </span>
            </h1>

            <br/>

            <div id="stacont" class="status-container">
                <span class="status active"></span>
                Visit Status
            </div>

            <div class="tag">Outpatient</div>

            <div class="tad" id="lstdate">Last Visit: ${ui.formatDatePretty(previousVisit)}</div>
        </div>

        <div class="identifiers">
            <em>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Patient ID</em>
            <span>${patient.getPatientIdentifier()}</span>
            <br>

            <div class="catg">
                <i class="icon-tags small" style="font-size: 16px"></i><small>Category:</small> ${patientCategory}
            </div>
        </div>

        <div class="close"></div>
    </div>

    <div class="title">
        <i class="icon-time"></i>
        <span>${date} <em style="width: 80px;">&nbsp; order date</em></span>

        <i class="icon-quote-left"></i>
        <span>${encounterId} <em>&nbsp; order number</em></span>
    </div>

    <div id="indent-search-result" style="display: block; margin-top:3px;">
        <table id="orderList" data-bind="visible: \$root.listItems().length > 0">
            <thead>
            <tr role="row">
                <th>#</th>
                <th>DRUG NAME</th>
                <th>FORMULATION</th>
                <th>DOSAGE</th>
                <th>FREQUENCY</th>
                <th>DAYS</th>
                <th>COMMENTS</th>
                <th>ACTIONS</th>
            </tr>
            </thead>

            <tbody data-bind="foreach: listItems">
            <tr>
                <td data-bind="text: \$index() + 1"></td>
                <td data-bind="text: inventoryDrug.name"></td>
                <td>
                    <span data-bind="text: inventoryDrugFormulation.name"></span> - <span
                        data-bind="text: inventoryDrugFormulation.dozage"></span>
                </td>
                <td>
                    <span data-bind="text: dosage"></span> - <span
                        data-bind="text: dosageUnit.name"></span>

                </td>
                <td data-bind="text: frequency.name"></td>
                <td data-bind="text: noOfDays"></td>
                <td data-bind="text: comments"></td>
                <td style="text-align: center;">
                    <a class="remover" href="#" data-bind="click: \$root.processDrugItem">
                        <i class="icon-circle-arrow-right small"></i>PROCESS
                    </a>
                </td>
            </tr>
            </tbody>
        </table>


        <div role="grid" class="dataTables_wrapper" id="processedOrderList"
             data-bind="visible: \$root.pItems().length > 0" style="display: none;">
            <div class="title">
                <i class="icon-bookmark"></i>
                <span>
                    PROCESSED
                    <em style="width: 80px;">&nbsp; processed drugs</em>
                </span>
            </div>

            <table id="orderListTable">
                <thead>
                <tr role="row">
                    <th>#</th>
                    <th>DRUG NAME</th>
                    <th>FORMULATION</th>
                    <th>QUANTITY</th>
                    <th>UNIT PRICE</th>
                    <th>TOTAL COST</th>
                </tr>
                </thead>

                <tbody data-bind="foreach: pItems">
                <tr>
                    <td data-bind="text: \$index() + 1"></td>
                    <td data-bind="text: drugName"></td>
                    <td data-bind="text: formulation"></td>
                    <td data-bind="text: quantity"></td>
                    <td data-bind="text: price.toString().formatToAccounting()"></td>
                    <td data-bind="text: (price*quantity).toString().formatToAccounting()"></td>
                </tr>
                </tbody>

                <tbody>
                <tr>
                    <td></td>
                    <td colspan="4"><b>SUB TOTALS (KES)</b></td>
                    <td data-bind="text: \$root.computedTotal()" style="text-align: right; font-weight: bold;"></td>
                </tr>
                </tbody>
            </table>
        </div>
		
        <div role="grid" class="dataTables_wrapper" id="notProcessedOrderList" data-bind="visible: \$root.pRemove().length > 0" style="display: none;">
			<div class="title">
				<i class="icon-retweet"></i>
				<span>
					NOT PROCESSED
					<em style="width: 180px;">&nbsp; to purchase elsewhere</em>
				</span>
				
				<a style="float: right">
					<i class="icon-print small"></i>
					Print Unprocessed
				</a>
			</div>
			
			<div id="print-section">
				<div class="print-only">
					<center>
						<img width="100" height="100" align="center" title="AfyaEHMS" alt="AfyaEHMS" src="${ui.resourceLink('billingui', 'images/kenya_logo.bmp')}">
						<h2>
							${userLocation}<br/>
							PRESCRIBED DRUGS						
						</h2>
					</center>

					<div>
						<label>
							<span class='status active'></span>
							Full Names:
						</label>
						<span>${patient.givenName} ${patient.familyName} ${patient.middleName ? patient.middleName : ''}</span>
						<br/>

						<label>
							<span class='status active'></span>
							Age:
						</label>
						<span>${patient.age} (${ui.formatDatePretty(patient.birthdate)})</span>
						<br/>

						<label>
							<span class='status active'></span>
							Gender:
						</label>
						<span>${gender}</span>
						<br/>

						<label>
							<span class='status active'></span>
							Print Date:
						</label>
						<span>${date}</span>
					</div>				
				</div>			
			
				<table id="orderNotListTable" class="font-ten">
					<thead>
						<tr role="row">
							<th>#</th>
							<th>DRUG NAME</th>
							<th>FORMULATION</th>
							<th>DOSAGE</th>
							<th>FREQUENCY</th>
							<th>DAYS</th>
							<th>COMMENTS</th>
						</tr>
					</thead>

					<tbody data-bind="foreach: pRemove">
						<tr>
							<td data-bind="text: \$index() + 1"></td>
							<td data-bind="text: inventoryDrug.name"></td>
							<td>
								<span data-bind="text: inventoryDrugFormulation.name"></span> - <span
									data-bind="text: inventoryDrugFormulation.dozage"></span>
							</td>
							<td>
								<span data-bind="text: dosage"></span> - <span
									data-bind="text: dosageUnit.name"></span>

							</td>
							<td data-bind="text: frequency.name"></td>
							<td data-bind="text: noOfDays"></td>
							<td data-bind="text: comments"></td>
						</tr>
					</tbody>
				</table>			
			</div>			
		</div>

        <form method="post" id="drugsForm" style="display: none;">
            <input name="submvalue" type="text" value="Finish"/>
            <input name="patientId" type="text" value="${patientId}"/>
            <input name="encounterId" type="text" value="${encounterId}"/>
            <input name="patientType" type="text" value="${patientType}"/>
            <input name="prescriberId" type="text" value="${prescriberId}"/>
            <input name="totalCharges" type="text" data-bind="value: \$root.computedTotal()"/>

            <textarea name="order" data-bind="value: ko.toJSON(\$root.pItems)"></textarea>
            <textarea name="remove" data-bind="value: ko.toJSON(\$root.pRemove)"></textarea>
        </form>

        <div class="buttons-div">
            <input type="button" value="Cancel" onclick="cancelDrugProcess();" class="cancel"/>
            <input type="submit" id="subm" name="subm" value="Finish Order" class="confirm"
                   style="float: right; margin-right: 0px" data-bind="click: \$root.finishDrugOrder"/>
            <input type="button" id="print" name="print" value="Print Order" onClick="printDiv2();" class="task"
                   style="float: right; margin-right: 5px"/>
        </div>

        <div id="processDrugDialog" class="dialog" style="display: none; width: 900px">
            <div class="dialog-header">
                <i class="icon-folder-open"></i>

                <h3>Process Drug Order</h3>
            </div>


            <div class="dialog-content">
                <form method="post" id="processDrugOrderForm" class="box">
                    <table class="box" id="processDrugOrderFormTable">
                        <thead>
                        <tr>
                            <th>#</th>
                            <th>Expiry</th>
                            <th title="Date of manufacturing">DM</th>
                            <th>Company</th>
                            <th>Batch No.</th>
                            <th title="Quantity available">Available</th>
                            <th title="Issue quantity">Issue</th>
                        </tr>
                        </thead>
                        <tbody>

                        </tbody>
                    </table>
					
					<div id="remove-items">
						<a style="float: right;" class="red remove-item"><i class="icon-remove small"></i>Remove Drug from List</a>
					</div>
					
					<span>
						<button class="button confirm right" data-bind="click: \$root.issueDrugItem"
								id="drugIssue" style="margin-right:0;">Issue Drug</button>
						<button class="button cancel">Cancel</button>					
					</span>
					
                </form>
            </div>

        </div>
    </div>

    <div id="confirmDrugDialog" class="dialog" style="display: none;">
        <div class="dialog-header">
            <i class="icon-save"></i>

            <h3>Confirm</h3>
        </div>


        <div class="dialog-content">
            <h3>Confirm finalizing and posting the order <b>#${encounterId}</b>?</h3>

            <button class="button confirm right" style="margin-right: 0px">Confirm</button>
            <span class="button cancel">Cancel</span>
        </div>
    </div>



    <!--PRINT DIV  -->
    <div id="printDiv" class="hidden">

        <center>

            <img width="100" height="100" align="center" title="OpenMRS" alt="OpenMRS"
                 src="${ui.resourceLink('billingui', 'images/kenya_logo.bmp')}">
        </center>

        <h2>
            <center>${userLocation}</center>
        </h2>

        <br><br>

        <div>
            <label>
                <span class='status active'></span>
                Identifier:
            </label>
            <span>${patient.getPatientIdentifier()}</span>
            <br/>

            <label>
                <span class='status active'></span>
                Full Names:
            </label>
            <span>${patient.givenName} ${patient.familyName} ${patient.middleName ? patient.middleName : ''}</span>
            <br/>

            <label>
                <span class='status active'></span>
                Age:
            </label>
            <span>${patient.age} (${ui.formatDatePretty(patient.birthdate)})</span>
            <br/>

            <label>
                <span class='status active'></span>
                Gender:
            </label>
            <span>${gender}</span>
            <br/>

            <label>
                <span class='status active'></span>
                Print Date:
            </label>
            <span>${date}</span>
            <br/>
        </div>

        <table id="myTablee" class="tablesorter" class="thickbox" style="width:100%; margin-top:30px">
            <thead>
            <tr>
                <th>#</th>
                <th>Drug Name</th>
                <th>Formulation</th>
                <th>Days</th>
                <th>Frequency</th>
                <th>Comments</th>
                <!-- <th style="text-align: center;">Quantity</th> -->
            </tr>
            </thead>
            <tbody>
            <% drugOrderList.eachWithIndex { drug, idx -> %>
            <tr class="class" id="${drug.inventoryDrug.name}">
                <td>${idx + 1}</td>
                <td>${drug.inventoryDrug.name}</td>
                <td>${drug.inventoryDrugFormulation.name}-${drug.inventoryDrugFormulation.dozage}</td>
                <td>${drug.noOfDays}</td>
                <td>${drug.frequency.name}</td>
                <td>${drug.comments}</td>
            </tr>
            <% } %>

            </tbody>
        </table>

        <div style="margin-top: 20px;">
            <span style="margin-left: 10px;">
                Prescribed By: <b>${doctor}</b>
            </span>

            <span class="right" style="margin-right: 10px;">
                Attending Pharmacist: <b>${pharmacist}</b>
            </span>
        </div>
    </div>
</div>
