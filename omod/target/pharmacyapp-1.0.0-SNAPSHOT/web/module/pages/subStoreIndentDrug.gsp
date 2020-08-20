<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Add Drug Order"])
	ui.includeCss("pharmacyapp", "container.css")
%>

<script>
    var drugOrder = [];
    var selectDrug;
    jq(function () {
        var cleared = false;
        var selectedDrugId;
		
        jq("#drugSelection").hide();
        jq("#addDrugsButton").on("click", function (e) {
			jq('#drugCategory option').eq(0).prop('selected', true).change();
            adddrugdialog.show();
        });
		
        var indentName = [];
        var adddrugdialog = ui.setupConfirmationDialog({
			dialogOpts: {
				overlayClose: false,
				close: true
			},
            selector: '#addDrugDialog',
            actions: {
                confirm: function () {
                    var sDrugCategory = jq("#drugCategory").val();
                    var sDrug = jq("#drugName").val();
                    var sDrugName;
                    if (sDrug == 0) {
                        sDrug = selectedDrugId;
                        sDrugName = selectDrug;
                    } else {
                        sDrugName = jq('#drugName :selected').text();
                    }
                    
                    if (sDrugCategory == 0) {
                        jq().toastmessage('showErrorToast', "Select a Drug Category!");
                    } else if (sDrug == 0 || sDrug == null) {
                        jq().toastmessage('showErrorToast', "Select a Drug Name!");
                    } else if (jq("#drugFormulation").val() == 0) {
                        jq().toastmessage('showErrorToast', "Select a Formulation!");
                    } else if (isNaN(parseInt(jq("#quantity").val()))) {
                        jq().toastmessage('showErrorToast', "Enter correct quantity!");
                    } else {
                        if (cleared) {
                            jq('#addDrugsTable > tbody > tr').remove();
                            var tbody = jq('#addDrugsTable > tbody');
                            cleared = false;
                        }
                        var tbody = jq('#addDrugsTable').children('tbody');
                        var table = tbody.length ? tbody : jq('#addDrugsTable');
                        var index = drugOrder.length;
                        table.append('<tr><td>' + (index + 1) + '</td><td>' + jq("#drugCategory :selected").text() + '</td><td>' + sDrugName +
                                '</td><td>' + jq("#drugFormulation option:selected").text() + '</td><td>' + jq("#quantity").val() +
                                '</td><td>' + '<a class="remover" href="#" onclick="removeListItem(' + index + ');"><i class="icon-remove small" style="color:red"></i></a>' + '</td></tr>');
                        drugOrder.push(
                                {
                                    drugCategoryId: jq("#drugCategory").children(":selected").attr("id"),
                                    drugId: sDrug + "",
                                    drugFormulationId: jq("#drugFormulation").children(":selected").attr("id"),
                                    quantity: jq("#quantity").val(),
                                    drugCategoryName: jq('#drugCategory :selected').text(),
                                    drugName: sDrugName,
                                    drugFormulationName: jq('#drugFormulation :selected').text()
                                }
                        );

                        jq("#quantity").val('');
                        jQuery("#drugKey").show();
                        jQuery("#drugSelection").hide();
                        adddrugdialog.close();
                    }

                },
                cancel: function () {
                    jq("#quantity").val('');
                    jQuery("#drugKey").show();
                    jQuery("#drugSelection").hide();
                    adddrugdialog.close();
                }
            }
        });


        var addnameforindentslipdialog = ui.setupConfirmationDialog({
			dialogOpts: {
				overlayClose: false,
				close: true
			},
            selector: '#addNameForIndentSlip',
            actions: {
                confirm: function () {
                    if (jq("#indentName").val() == '') {
                        jq().toastmessage('showErrorToast', "Enter Order Name!");
                    } else if (jq("#mainstore").val() == 0) {
                        jq().toastmessage('showErrorToast', "Select a Main Store!");
                    } else {
                        indentName.push(
                                {
                                    indentName: jq("#indentName").val(),
                                    mainstore: jq("#mainstore").children(":selected").attr("id")
                                }
                        );
						
                        drugOrder = JSON.stringify(drugOrder);
                        indentName = JSON.stringify(indentName);

                        var addDrugsData = {
                            'drugOrder': drugOrder,
                            'indentName': indentName,
                            'send': 1,
                            'action': 2,
                            'keepThis': false
                        };
                        jq.getJSON('${ ui.actionLink("pharmacyapp", "subStoreIndentDrug", "saveIndentSlip") }', addDrugsData)
                                .success(function (data) {
                                    jq().toastmessage('showErrorToast', "Save Order Successful!");
                                    window.location.href = ui.pageLink("pharmacyapp", "container", {
                                        "rel": "indent-drugs"
                                    });

                                })
                                .error(function (xhr, status, err) {
                                    jq().toastmessage('showErrorToast', "AJAX error!" + err);
                                })
                        addnameforindentslipdialog.close();
                        jq("#dialogForm").reset();
                    }
                },
                cancel: function () {
                    addnameforindentslipdialog.close();
                    
					jq("#indentName").val('');
                    jq("#mainstore").val(0);
                }
            }
        });
		
        jq("#clearIndent").on("click", function (e) {
            if (drugOrder.length === 0) {
                jq().toastmessage('showErrorToast', "Order List has no Drug!");
            } else {
                if (confirm("Are you sure about this?")) {
                    drugOrder = [];
                    jq('#addDrugsTable > tbody > tr').remove();
                    var tbody = jq('#addDrugsTable > tbody');
                    var row = '<tr align="center"><td colspan="5">No Drugs Listed</td></tr>';
                    tbody.append(row);
                    cleared = true;
                } else {
                    return false;
                }
            }

        });
        jq("#returnToDrugList").on("click", function (e) {
            window.location.href = ui.pageLink("pharmacyapp", "container", {
                "rel": "indent-drugs"
            });
        });

        jq("#printIndent").on("click", function (e) {
            if (drugOrder.length === 0) {
                jq().toastmessage('showErrorToast', "Order List has no Drug!");
            } else {
                jq('#printList > tbody > tr').remove();
                var tbody = jq('#printList > tbody');

                jq.each(drugOrder, function (index, value) {
                    tbody.append('<tr><td>' + (index + 1) + '</td><td>' + value.drugCategoryName + '</td><td>' + value.drugName + '</td><td>' + value.drugFormulationName + '</td><td>' + value.quantity + '</td></tr>');
                });


                var printDiv = jQuery("#printDiv").html();
                var printWindow = window.open('', '', 'height=400,width=800');
                printWindow.document.write('<html><head><title>Order Slip :-Support by KenyaEHRS</title>');
                printWindow.document.write('</head>');
                printWindow.document.write(printDiv);
                printWindow.document.write('</body></html>');
                printWindow.document.close();
                printWindow.print();
            }

        });

        jq("#drugCategory").on("change", function (e) {
            var categoryId = jq(this).children(":selected").attr("value");
            var drugNameData = "";
            jq('#drugName').empty();

            if (categoryId === "0") {
                jq('<option value="">Select Drug</option>').appendTo("#drugName");
                jq('#drugName').change();

            } else {
                jq.getJSON('${ ui.actionLink("pharmacyapp", "addReceiptsToStore", "fetchDrugNames") }', {
                    categoryId: categoryId
                }).success(function (data) {
                    jQuery("#drugKey").hide();
                    jQuery("#drugSelection").show();


                    for (var key in data) {
                        if (data.hasOwnProperty(key)) {
                            var val = data[key];
                            for (var i in val) {
                                if (val.hasOwnProperty(i)) {
                                    var j = val[i];
                                    if (i == "id") {
                                        drugNameData = drugNameData + '<option id="' + j + '"' + ' value="' + j + '"';
                                    }
                                    else {
                                        drugNameData = drugNameData + 'name="' + j + '">' + j + '</option>';
                                    }
                                }
                            }
                        }
                    }

                    jq(drugNameData).appendTo("#drugName");
                    jq('#drugName').change();
                }).error(function (xhr, status, err) {
                    jq().toastmessage('showErrorToast', "AJAX error!" + err);
                });

            }

        });

        jq("#drugName").on("change", function (e) {
            var drugName = jq(this).children(":selected").attr("name");
            var drugFormulationData = "";
            jq('#drugFormulation').empty();

            if (jq(this).children(":selected").attr("value") === "") {
                jq('<option value="">Select Formulation</option>').appendTo("#drugFormulation");
            } else {
                jq.getJSON('${ ui.actionLink("pharmacyapp", "addReceiptsToStore", "getFormulationByDrugName") }', {
                    drugName: drugName
                }).success(function (data) {
                    for (var key in data) {
                        if (data.hasOwnProperty(key)) {
                            var val = data[key];
                            for (var i in val) {
                                var name, dozage;
                                if (val.hasOwnProperty(i)) {
                                    var j = val[i];
                                    if (i == "id") {
                                        drugFormulationData = drugFormulationData + '<option id="' + j + '">';
                                    } else if (i == "name") {
                                        name = j;
                                    }
                                    else {
                                        dozage = j;
                                        drugFormulationData = drugFormulationData + (name + "-" + dozage) + '</option>';
                                    }
                                }
                            }
                        }
                    }
                    jq(drugFormulationData).appendTo("#drugFormulation");
                }).error(function (xhr, status, err) {
                    jq().toastmessage('showErrorToast', "AJAX error!" + err);
                });
            }

        });

        jq("#searchPhrase").autocomplete({
            minLength: 3,
            source: function (request, response) {
                jq.getJSON('${ ui.actionLink("pharmacyapp", "addReceiptsToStore", "fetchDrugListByName") }',
                        {
                            searchPhrase: request.term
                        }
                ).success(function (data) {
                            var results = [];
                            for (var i in data) {
                                var result = {label: data[i].name, value: data[i]};
                                results.push(result);
                            }
                            response(results);
                        });
            },
            focus: function (event, ui) {
                jq("#searchPhrase").val(ui.item.value.name);
                return false;
            },
            select: function (event, ui) {
                event.preventDefault();
                selectDrug = ui.item.value.name;
                selectedDrugId = ui.item.value.id;

                jQuery("#searchPhrase").val(selectDrug);

                //set parent category
                var catId = ui.item.value.category.id;
                jq("#drugCategory").val(catId);


                var drugName = selectDrug;
                var drugFormulationData = "";
                jq('#drugFormulation').empty();

                if (drugName === "") {
                    jq('<option value="">Select Formulation</option>').appendTo("#drugFormulation");
                } else {
                    jq.getJSON('${ ui.actionLink("pharmacyapp", "addReceiptsToStore", "getFormulationByDrugName") }', {
                        drugName: drugName
                    }).success(function (data) {
                        for (var key in data) {
                            if (data.hasOwnProperty(key)) {
                                var val = data[key];
                                for (var i in val) {
                                    var name, dozage;
                                    if (val.hasOwnProperty(i)) {
                                        var j = val[i];
                                        if (i == "id") {
                                            drugFormulationData = drugFormulationData + '<option id="' + j + '">';
                                        } else if (i == "name") {
                                            name = j;
                                        }
                                        else {
                                            dozage = j;
                                            drugFormulationData = drugFormulationData + (name + "-" + dozage) + '</option>';
                                        }
                                    }
                                }
                            }

                        }

                        jq(drugFormulationData).appendTo("#drugFormulation");
                    }).error(function (xhr, status, err) {
                        jq('<option value="">Select Formulation</option>').appendTo("#drugFormulation");
                        jq().toastmessage('showErrorToast', "AJAX error!" + err);
                    });
                }


            }
        });

        jq("#addDrugsSubmitButton").click(function (event) {
            if (drugOrder.length < 1) {
                jq().toastmessage('showErrorToast', "Order List has no Drug!");
            } else {
                addnameforindentslipdialog.show();
            }
        });

    });//end of doc ready

    function removeListItem(counter) {
        if (confirm("Are you sure about this?")) {
            drugOrder = jq.grep(drugOrder, function (item, index) {
                return (counter !== index);
            });
            jq('#addDrugsTable > tbody > tr').remove();
            var tbody = jq('#addDrugsTable > tbody');
            jq.each(drugOrder, function (counter, item) {
                tbody.append('<tr><td>' + (counter + 1) + '</td><td>' + item.drugCategoryName + '</td><td>' + item.drugName +
                        '</td><td>' + item.drugFormulationName + '</td><td>' + item.quantity +
                        '</td><td>' + '<a class="remover" href="#" onclick="removeListItem(' + counter + ');"><i class="icon-remove small" style="color:red"></i></a>' + '</td></tr>');
            });

        } else {
            return false;
        }

    }

    function loadDrugFormulations() {

    }

</script>

<style>
	th:first-child{
		width: 5px;
	}
	th:last-child {
		width: 30px;
	}
	th:nth-child(5){
		width: 85px;
	}
	.dialog .dialog-content {
		padding: 20px 30px 50px;
	}
	.dialog .dialog-content li {
		margin-bottom: 0px;
	}
	.dialog label{
		display: inline-block;
		width: 115px;
	}
	.dialog select option {
		font-size: 1.0em;
	}
	.dialog select{
		display: inline-block;
		margin: 4px 0 0;
		width: 270px;
		height: 38px;
	}
	.dialog input {
		display: inline-block;
		width: 248px;
		min-width: 10%;
		margin: 4px 0 0;
	}
	.dialog ul {
		margin-bottom: 10px;
	}
	form input:focus, form select:focus, form textarea:focus, form ul.select:focus, .form input:focus, .form select:focus, .form textarea:focus, .form ul.select:focus{
		outline: 1px none #007fff;
	}
	#modal-overlay {
		background: #000 none repeat scroll 0 0;
		opacity: 0.4 !important;
	}
</style>

<div class="clear"></div>
<div id="indents-div">
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
					Add Drugs
				</li>
			</ul>
		</div>
		
		<div class="patient-header new-patient-header">
			<div class="demographics">
				<h1 class="name" style="border-bottom: 1px solid #ddd;">
					<span>&nbsp; ADD DRUG ORDERS &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
				</h1>				
			</div>			
			
			<div class="show-icon">
				&nbsp;
			</div>
			
			<span class="button confirm right" id="addDrugsButton" style="margin-top:15px;">
				<i class="icon-plus-sign small"></i>
				Add Drug		   
			</span>
		</div>
		
		<table id="addDrugsTable" class="dataTable">
			<thead>
				<tr>
					<th>#</th>
					<th>CATEGORY</th>
					<th>NAME</th>
					<th>FORMULATION</th>
					<th>QUANTITY</th>
					<th>&nbsp;</th>
				</tr>
			</thead>

			<tbody>
			</tbody>
		</table>
		
		<div style="margin-top: 10px">
            <span class="button confirm right" id="addDrugsSubmitButton" style="margin-right: 0px; margin-left: 5px;">
				<i class="icon-save small"> </i>
				Finish
			</span>
			
            <span class="button task right" id="printIndent">
				<i class="icon-print small"> </i>
				Print
			</span>
			
            <span class="button cancel" id="returnToDrugList">
				Return To List
			</span>
				   
				   
		</div>		
	</div>
</div>

<div class="container">
    <div id="addDrugDialog" class="dialog">
        <div class="dialog-header">
            <i class="icon-folder-open"></i>

            <h3>Drug Information</h3>
        </div>

        <form id="dialogForm">

            <div class="dialog-content">
                <ul>
                    <li>
                        <label for="drugCategory">Drug Category</label>
                        <select name="drugCategory" id="drugCategory">
                            <option value="0">Select Category</option>
                            <% if (listCategory != null || listCategory != "") { %>
                            <% listCategory.each { drugCategory -> %>
                            <option id="${drugCategory.id}" value="${drugCategory.id}">${drugCategory.name}</option>
                            <% } %>
                            <% } %>
                        </select>
                    </li>
                    <li>
                        <div id="drugKey">
                            <label for="searchPhrase">Drug Name</label>
                            <input id="searchPhrase" name="searchPhrase" onblur="loadDrugFormulations();"/>
                        </div>

                        <div id="drugSelection">
                            <label for="drugName">Drug Name</label>
                            <select name="drugName" id="drugName">
                                <option value="0">Select Drug</option>
                            </select>
                        </div>
                    </li>
                    <li>
                        <label for="drugFormulation">Formulation</label>
                        <select name="drugFormulation" id="drugFormulation">
                            <option value="0">Select Formulation</option>
                        </select>
                    </li>

                    <li>
                        <label for="quantity">Quantity</label>
                        <input name="quantity" id="quantity"/>
                    </li>

                </ul>

                <span class="button confirm right" style="margin-right: 0px">Confirm</span>
                <span class="button cancel">Cancel</span>
            </div>
        </form>
    </div>

    <div id="addNameForIndentSlip" class="dialog">
        <div class="dialog-header">
            <i class="icon-folder-open"></i>

            <h3>Add Name For Order Slip</h3>
            
        </div>
		
		<form id="finalizeForm">
			<div class="dialog-content">
				<ul>
					<li>
						<label for="indentName">Name</label>
						<input name="indentName" id="indentName"/>
					</li>
					<li>
						<label for="mainstore">Select Store</label>
						<select name="mainstore" id="mainstore">
							<option value="0">Select Store</option>
							<% if (store != null || store != "") { %>
							<% store.parentStores.each { vparent -> %>
							<option id="${vparent.id}">${vparent.name}</option>
							<% } %>
							<% } %>
						</select>
					</li>
				</ul>

				<span class="button confirm right">Confirm</span>
				<span class="button cancel">Cancel</span>
			</div>		
		</form>

    </div>


    <!-- PRINT DIV -->
    <div id="printDiv" style="display: none;">
        <div style="margin: 10px auto; font-size: 1.0em;font-family:'Dot Matrix Normal',Arial,Helvetica,sans-serif;">
            <br/>
            <br/>
            <center style="font-size: 2.2em">Order From ${store.name}</center>
            <br/>
            <br/>
            <span style="float:right;font-size: 1.7em">Date: ${date}</span>
            <br/>
            <br/>
            <table border="1" id="printList">
                <thead>
                <tr role="row">
                    <th style="width: 5%">#</th>
                    <th style="width: 5%">CATEGORY</th>
                    <th style="width: 5%">NAME</th>
                    <th style="width: 5%">FORMULATION</th>
                    <th style="width: 5%">QUANTITY</th>
                </tr>
                </thead>

                <tbody>
                </tbody>

            </table>
            <br/><br/><br/><br/><br/><br/>
            <span style="float:left;font-size: 1.5em">Signature of sub-store/ Stamp</span><span
                style="float:right;font-size: 1.5em">Signature of inventory clerk/ Stamp</span>
            <br/><br/><br/><br/><br/><br/>
            <span style="margin-left: 13em;font-size: 1.5em">Signature of Medical Superintendent/ Stamp</span>
        </div>
    </div>
    <!-- END PRINT DIV -->
</div>
