<%
    def props = ["identifier", "fullname", "age", "gender","action"]
	ui.includeJavascript("billingui", "moment.js")
%>

<script>
    jq(function () {
        jq("#getOrders").on("click", function () {
            fetchValues();
        });
		
		jq('#referred-date-display').change(function(){
			fetchValues();
		});
		
		jq('#phrase').on('keyup', function(){
			fetchValues(false);
		});
		
		function fetchValues(showNotification){
			if (typeof showNotification === 'undefined'){
				showNotification = true;
			}
			
			var date = jq("#referred-date-field").val();
            var phrase = jq("#phrase").val();
			
            jq.getJSON('${ui.actionLink("pharmacyapp", "Queue", "searchPatient")}', {
				"date": moment(date).format('DD/MM/YYYY'),
				"searchKey": phrase,
				"currentPage": 1
			}).success(function (data) {
				var tbody = jq('#pharmacyPatientSearch > tbody');
				jq('#pharmacyPatientSearch > tbody > tr').remove();
				
				if (data.length === 0) {
					tbody.append('<tr align="center"><td>&nbsp;</td><td colspan="6">No patients found</td></tr>');
					
					if (showNotification){
						jq().toastmessage('showErrorToast', "No match found!");					
					}
				} else {
					updatePharmacyTable(data)
				}
			});
		}
		
		
		if ('${date}' != ''){
			var from = '${date}'.split("/");
			var f = new Date(from[2], from[1] - 1, from[0]);
			
			jq('#referred-date-field').val(moment(f).format('YYYY-MM-DD'));
			jq('#referred-date-display').val(moment(f).format('DD MMM YYYY')).change();
		}
		else {
			fetchValues(false);		
		}
		
		//End of Document Ready
    });

    //update the queue table
    function updatePharmacyTable(tests) {
        var jq = jQuery;
        var dateField = jq("#referred-date-field");
        
        var tbody = jq('#pharmacyPatientSearch > tbody');
        var date = dateField.val();

        for (index in tests) {
            var item = tests[index];
            var rows = '<tr>';
			
            rows += '<td>' + (1+parseInt(index)) + '</td>';
            rows += '<td>' + item.identifier + '</td>';
            rows += '<td>' + item.fullname + '</td>';
            rows += '<td>' + item.age + '</td>';
            rows += '<td>' + item.gender + '</td>';
            rows += '<td align="center"><a title="Prescriptions" href="listOfOrder.page?patientId=' +
                    item.patientId + '&date='+moment(date).format('DD/MM/YYYY')+'"><i class="icon-stethoscope small" ></i></a>';         
			
            rows += '</tr>';
            tbody.append(rows);
        }
    }
</script>

<div class="clear"></div>
<div id="queue-div">
	<div class="container">
		<div class="example">
			<ul id="breadcrumbs">
				<li>
					<a href="${ui.pageLink('referenceapplication', 'home')}">
						<i class="icon-home small"></i></a>
				</li>
				
				<li>
					<a href="${ui.pageLink('pharmacyapp', 'dashboard')}">
						<i class="icon-chevron-right link"></i>Pharmacy
					</a>
				</li>

				<li>
					<i class="icon-chevron-right link"></i>
					Queue
				</li>
			</ul>
		</div>
		
		<div class="patient-header new-patient-header">
			<div class="demographics">
				<h1 class="name" style="border-bottom: 1px solid #ddd;">
					<span>PATIENTS QUEUE LIST &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
				</h1>
			</div>
			
			<div class="show-icon">
				&nbsp;
			</div>
			
			<div class="filter">
				<i class="icon-filter" style="color: rgb(91, 87, 166); float: left; font-size: 52px ! important; padding: 0px 10px 0px 0px;"></i>
				<div class="first-col">
					<label for="referred-date-display">Date</label><br/>
					${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'referred-date', label: 'Date', formFieldName: 'referredDate', useTime: false, defaultToday: true])}
				</div>
				
				<div class="second-col">
					<label for="phrase">Filter Patient in Queue:</label><br/>
					<input id="phrase" type="text" name="phrase" placeholder="Enter Patient Name / Identifier">
					<i class="icon-search" style="color: #aaa; float: right; position: absolute; font-size: 16px ! important; margin-left: -495px; margin-top: 3px;"></i>
				</div>
				
				<a class="button confirm" id="getOrders" style="float: right; margin: 15px 5px 0 0;">
					Get Patients
				</a>
			</div>
		</div>
	</div>
	
	
	<table id="pharmacyPatientSearch">
		<thead>
			<tr role="row">
				<th>#</th>
				<th>IDENTIFIER</th>
				<th>NAMES</th>
				<th>AGE</th>
				<th>GENDER</th>
				<th>ACTIONS</th>
			</tr>
		</thead>

		<tbody role="alert" aria-live="polite" aria-relevant="all">
		<tr align="center">
			<td>&nbsp;</td>
			<td colspan="6">No patients found</td>
		</tr>
		</tbody>
	</table>

</div>

<div class="footer">&nbsp;</div>




