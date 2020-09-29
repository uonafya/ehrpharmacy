<%
	ui.decorateWith("kenyaemr", "standardPage")
	ui.includeJavascript("ehrcashier", "jq.print.js")
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
<style>
	@media print {
		.donotprint {
			display: none;
		}

		.spacer {
			margin-top: 100px;
			font-family: "Dot Matrix Normal", Arial, Helvetica, sans-serif;
			font-style: normal;
			font-size: 14px;
		}

		.printfont {
			font-family: "Dot Matrix Normal", Arial, Helvetica, sans-serif;
			font-style: normal;
			font-size: 14px;
		}
	}

	.name {
		color: #f26522;
	}

	#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
		text-decoration: none;
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
		margin-top: 5px;
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

	.title {
		border: 1px solid #eee;
		margin: 3px 0;
		padding: 5px;
	}

	.title i {
		font-size: 1.5em;
		padding: 0;
	}

	.title span {
		font-size: 20px;
	}

	.title em {
		border-bottom: 1px solid #ddd;
		color: #888;
		display: inline-block;
		font-size: 0.5em;
		margin-right: 10px;
		text-transform: lowercase;
		width: 200px;
	}

	table {
		font-size: 14px;
	}
	.retired {
		text-decoration: line-through;
		color: darkgrey;
	}
</style>

<script>
    jq(function () {
        var listOfDrugToIssue =
        ${listDrugIssue}.
        listDrugIssue;
        var wAmount = ${waiverAmount};
        var wComment = "${waiverComment}";
        var listNonDispensed =
        ${listOfNotDispensedOrder}.
        listOfNotDispensedOrder;

        function DrugOrderViewModel() {
            var self = this;
            self.availableOrders = ko.observableArray([]);
            self.nonDispensed = ko.observableArray([]);
            var mappedOrders = jQuery.map(listOfDrugToIssue, function (item) {
                return new DrugOrder(item);
            });
            var mappedNonDispensed = jQuery.map(listNonDispensed, function (item) {
                return new NonDrugOrder(item);
            });

            self.availableOrders(mappedOrders);
            self.nonDispensed(mappedNonDispensed);
            //observable waiver
            self.waiverAmount = ko.observable(wAmount);

            //observable comment
            self.comment = ko.observable(wComment);

            //observable drug
            self.flag = ko.observable(${flag});

            // Computed data
            self.totalSurcharge = ko.computed(function () {
                var total = 0;
                for (var i = 0; i < self.availableOrders().length; i++) {
                    total += self.availableOrders()[i].orderTotal();
                }
                return total.toFixed(2);
            });

            self.runningTotal = ko.computed(function () {
                var rTotal = self.totalSurcharge() - self.waiverAmount();
                return rTotal.toFixed(2);
            });


            //submit bill
            self.submitBill = function () {  
                var flag = ${flag};
                var ids  = ${receiptid};
                if (flag === 1) {
                    var data = jQuery.ajax({
                        type: "GET"
                        , url: '${ ui.actionLink("pharmacyapp", "drugOrder", "subStoreIssueDrugDeduct") }'
                        , data: ({receiptid: ids, flag: flag})
                        , async: false
                        , cache: false
                    }).responseText;

                    var savingMessage = jq().toastmessage('showSuccessToast', 'Please wait as Transaction is being Posted');
                }
				
				window.location.href = ui.pageLink ("pharmacyapp", "container", { "rel" : "dispense-drugs"});
            };

			self.printBill = function () {				
				jq("#printSection").print({
					globalStyles: 	false,
					mediaPrint: 	false,
					stylesheet: 	'${ui.resourceLink("pharmacyapp", "styles/print-out.css")}',
					iframe: 		false,
					width: 			1000,
					height:			700
				});
				
				var flag = ${flag};				
				if (flag !== 1) {
					window.location.href = ui.pageLink ("pharmacyapp", "container", { "rel" : "dispense-drugs"});
				}
			};

			
            self.isNonPaying = ko.computed(function () {
                var cat = "${paymentSubCategory}";
                var catArray = ["GENERAL", "EXPECTANT MOTHER", "TB PATIENT", "CCC PATIENT"];
                var exists = jq.inArray(cat, catArray);
                if (exists >= 0) {
                    return false;
                } else {
                    return true;
                }
            });
        }

        function DrugOrder(item) {
            var self = this;
            self.initialBill = ko.observable(item);
            self.orderTotal = ko.computed(function () {
                var quantity = self.initialBill().quantity;
                var price = self.initialBill().transactionDetail.costToPatient;
                return quantity * price;
            });
        }

        function NonDrugOrder(item) {
            var self = this;
            self.initialNonBill = ko.observable(item);
        }

        var orders = new DrugOrderViewModel();
        ko.applyBindings(orders, jq("#dispensedDrugs")[0]);
    });//end of document ready
</script>

<div class="container">
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
                <a href="${ui.pageLink('pharmacyapp', 'container', [rel: 'dispense-drugs'])}">Dispense</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                Pharmacy Order
            </li>
        </ul>
    </div>

    <div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name">
                <span id="surname">${familyName},<em>surname</em></span>
                <span id="othname">${givenName} ${middleName}  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<em>other names</em>
                </span>

                <span class="gender-age">
                    <span>
                        ${gender}
                    </span>
                    <span id="agename">${age} years (${ui.formatDatePretty(birthdate)})</span>

                </span>
            </h1>

            <br/>

            <div id="stacont" class="status-container">
                <span class="status active"></span>
                Visit Status
            </div>

            <div class="tag">Outpatient</div>

            <div class="tad" id="lstdate">Last Visit: ${ui.formatDatetimePretty(lastVisit)}</div>
        </div>

        <div class="identifiers">
            <em>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Patient ID</em>
            <span>${identifier}</span>
            <br>

            <div class="catg">
                <i class="icon-tags small" style="font-size: 16px"></i><small>Category:</small>${paymentSubCategory}
            </div>
        </div>

        <div class="close"></div>
    </div>
	
	<div class="title">
		<i class="icon-time"></i>
		<span style="text-transform: uppercase;">
			${ui.formatDatetimePretty(date)}
			<em style="width: 80px;">  order date</em>
		</span>
		
		<i class="icon-quote-left"></i>
		<span>
			${receiptid}
			<em>  receipt number</em>
		</span>
	</div>

    <div class="dashboard clear" id="dispensedDrugs">
        <table width="100%" id="orderBillingTable" class="tablesorter thickbox">
            <thead>
            <tr align="center">
                <th>#</th>
                <th>DRUG</th>
                <th>FORMULATION</th>
                <th>FREQUENCY</th>
                <th>DAYS</th>
                <th>COMMENT</th>
                <th>EXPIRY</th>
                <th>QNTY</th>
                <th>PRICE</th>
                <th>TOTAL</th>
            </tr>
            </thead>

            <tbody data-bind="foreach: availableOrders, visible: availableOrders().length > 0">
            <tr>
                <td data-bind="text: \$index()+1"></td>
                <td data-bind="text: initialBill().transactionDetail.drug.name"></td>
                <td>
                    <span data-bind="text: initialBill().transactionDetail.formulation.name"></span> -
                    <span data-bind="text: initialBill().transactionDetail.formulation.dozage"></span>
                </td>
                <td data-bind="text: initialBill().transactionDetail.frequency.name"></td>
                <td data-bind="text: initialBill().transactionDetail.noOfDays"></td>
                <td data-bind="text: initialBill().transactionDetail.comments"></td>
                <td data-bind="text: (initialBill().transactionDetail.dateExpiry.toString().substring(0,11))"></td>
                <td data-bind="text: initialBill().quantity"></td>
                <td data-bind="text: initialBill().transactionDetail.costToPatient.toFixed(2)"></td>
                <td data-bind="text: orderTotal().toFixed(2)"></td>
            </tr>
            </tbody>

            <tbody>
            <tr>
                <td></td>
                <td colspan="8">
                    <b>TOTAL AMOUNT PAID</b>
                </td>
                <td>
                    <span data-bind="text: totalSurcharge, css:{'retired': isNonPaying()}"></span>
                    <span data-bind="visible: isNonPaying()">0.00</span>
                </td>
            </tr>
            <tr>
                <td></td>
                <td colspan="8">
                    <b>WAIVER AMOUNT</b>
                </td>
                <td>
                    <span data-bind="text: waiverAmount, css:{'retired': isNonPaying()}"></span>
                    <span data-bind="visible: isNonPaying()">0.00</span>
                </td>
            </tr>
            <tr>
                <td></td>
                <td colspan="8">
                    <b>NET PAID</b>
                </td>
                <td>
                    <span data-bind="text: runningTotal, css:{'retired': isNonPaying()}"></span>
                    <span data-bind="visible: isNonPaying()">0.00</span>
                </td>
            </tr>
            </tbody>
        </table>

        <div id="nonDispensedDrugs" data-bind="visible: nonDispensed().length > 0">
            <center><h3>Drugs Not Issued</h3></center>
            <table width="100%" id="nonDispensedDrugsTable" class="tablesorter thickbox">
                <thead>
                <tr align="center">
                    <th>#</th>
                    <th>Drug</th>
                    <th>Formulation</th>
                    <th>Frequency</th>
                    <th>Days</th>
                    <th>Comments</th>
                </tr>
                </thead>

                <tbody data-bind="foreach: nonDispensed">
                <tr>
                    <td data-bind="text: \$index()+1"></td>
                    <td data-bind="text: initialNonBill().inventoryDrug.name"></td>
                    <td>
                        <span data-bind="text: initialNonBill().inventoryDrugFormulation.name"></span> -
                        <span data-bind="text: initialNonBill().inventoryDrugFormulation.dozage"></span> -
                    </td>
                    <td data-bind="text: initialNonBill().frequency.name"></td>
                    <td data-bind="text: initialNonBill().noOfDays"></td>
                    <td data-bind="text: initialNonBill().comments"></td>
                </tr>
                </tbody>
            </table>
        </div>

        <div style="margin: 2px 0 15px 8px;">
            <i class=" icon-user-md small"></i>
            <span style="color: #777;" class="small">Attending Pharmacist:</span>
            <span>${cashier} &nbsp;&nbsp;</span>
        </div>


        <input type="button" class="button cancel"
               onclick="javascript:window.location.href = 'container.page?rel=dispense-drugs'"
               value="Cancel"/>
			   
        <span id="finishOrder" style="margin-right: 0px;" class="button task right" data-bind="visible: flag() == 1, click: submitBill">
			<i class="icon-save small"></i>
			Finish
		</span>
			   
		<span id="printOrder" style="margin-right: 5px;" class="button task right" data-bind="click: printBill">
			<i class="icon-print small"></i>
			<span data-bind="visible: flag() == 1">Print</span>
			<span data-bind="visible: flag() == 2">Reprint</span>
		</span>

        <!-- PRINT DIV -->
        <div id="printDiv" style="display: none;">
			<div id="printSection">
				<center>				
					<img width="100" height="100" align="center" title="OpenMRS" alt="OpenMRS" src="${ui.resourceLink('billingui', 'images/kenya_logo.bmp')}">
				
					<h2>
						<b>
							<u>${userLocation}</u>
						</b>
					</h2>
		
					<h2>
						<b>
							CASH RECEIPT<br/>00${receiptid}
						</b>
					</h2>
				</center>
				
				<div>
					<label>
							<span class='status active'></span>
							Identifier:
						</label>
						<span>${identifier}</span>
						<br/>
						
						<label>
							<span class='status active'></span>
							Full Names:
						</label>
						<span>${givenName} ${familyName} ${middleName?middleName:''}</span>
						<br/>
						
						<label>
							<span class='status active'></span>
							Age:
						</label>
						<span>${age} (${ui.formatDatePretty(birthdate)})</span>
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
						
						<label>
							<span class='status active'></span>
							Payment Catg:
						</label>
						<span>${paymentCategory} / ${paymentSubCategory}</span>
						<br/>
						<br/>
				</div>
				
				<table width="100%" class="tablesorter thickbox" style="border: 1px solid #eee">
					<thead>
					<tr>
						<th>#</th>
						<th>Drug</th>
						<th>Formulation</th>
						<th>Frequency</th>
						<th>Days</th>
						<th>Comments</th>
						<th>Expiry</th>
						<th>Qnty</th>
						<th>Unit Price</th>
						<th>Item Total</th>
					</tr>
					</thead>

					<tbody data-bind="foreach: availableOrders, visible: availableOrders().length > 0">
						<tr>
							<td data-bind="text: \$index()+1"></td>
							<td data-bind="text: initialBill().transactionDetail.drug.name"></td>
							<td>
								<span data-bind="text: initialBill().transactionDetail.formulation.name"></span> -
								<span data-bind="text: initialBill().transactionDetail.formulation.dozage"></span>
							</td>
							<td data-bind="text: initialBill().transactionDetail.frequency.name"></td>
							<td data-bind="text: initialBill().transactionDetail.noOfDays"></td>
							<td data-bind="text: initialBill().transactionDetail.comments"></td>
							<td data-bind="text: (initialBill().transactionDetail.dateExpiry.toString().substring(0,11))"></td>
							<td data-bind="text: initialBill().quantity"></td>
							<td data-bind="text: initialBill().transactionDetail.costToPatient.toFixed(2)"></td>
							<td data-bind="text: orderTotal().toFixed(2)"></td>
						</tr>
					</tbody>
					
					<tbody>
						<tr>
							<td></td>
							<td colspan="8">
								<b>TOTAL AMOUNT PAID</b>
							</td>
							<td>
								<span data-bind="text: totalSurcharge, css:{'retired': isNonPaying()}"></span>
								<span data-bind="visible: isNonPaying()">0.00</span>
							</td>
						</tr>
						<tr>
							<td></td>
							<td colspan="8">
								<b>WAIVER AMOUNT</b>
							</td>
							<td>
								<span data-bind="text: waiverAmount, css:{'retired': isNonPaying()}"></span>
								<span data-bind="visible: isNonPaying()">0.00</span>
							</td>
						</tr>
						<tr>
							<td></td>
							<td colspan="8">
								<b>NET PAID</b>
							</td>
							<td>
								<span data-bind="text: runningTotal, css:{'retired': isNonPaying()}"></span>
								<span data-bind="visible: isNonPaying()">0.00</span>
							</td>
						</tr>
					</tbody>
				</table>

				<div data-bind="visible: nonDispensed().length > 0">
					<center><h2>Drugs Not Issued</h2></center>
					<table width="100%" class="tablesorter thickbox">
						<thead>
							<tr align="center">
								<th>#</th>
								<th>DRUG</th>
								<th>Formulation</th>
								<th>FREQUENCY</th>
								<th>DAYS</th>
								<th>COMMENTS</th>
							</tr>
						</thead>

						<tbody data-bind="foreach: nonDispensed">
							<tr>
								<td data-bind="text: \$index()+1"></td>
								<td data-bind="text: initialNonBill().inventoryDrug.name"></td>
								<td>
									<span data-bind="text: initialNonBill().inventoryDrugFormulation.name"></span> -
									<span data-bind="text: initialNonBill().inventoryDrugFormulation.dozage"></span> -
								</td>
								<td data-bind="text: initialNonBill().frequency.name"></td>
								<td data-bind="text: initialNonBill().noOfDays"></td>
								<td data-bind="text: initialNonBill().comments"></td>
							</tr>
						</tbody>
					</table>

				</div>

				<div style="margin: 10px;">
					<span>Attending Pharmacist: <b>${cashier}</b></span>
				</div>
				<div style="margin-top: 50px;text-align: center">
					<span>Signature of Inventory Clerk/ Stamp</span>
				</div>
			
			</div>
        </div>
        <!-- END PRINT DIV -->

    </div>

</div>