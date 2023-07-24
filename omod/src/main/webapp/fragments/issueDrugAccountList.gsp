<%
    ui.includeJavascript("ehrconfigs", "moment.js")
%>


<script>
    jq(function () {
        var date = jq("#referred-date-field").val();
        jq.getJSON('${ui.actionLink("pharmacyapp", "IssueDrugAccountList", "fetchList")}',{
			"date": moment(date).format('DD/MM/YYYY'),
			"currentPage": 1
		}).success(function (data) {
			if (data.length === 0) {
				jq().toastmessage('showNoticeToast', "No drug found!");
			} else {
				QueueTable(data)
			}

		});
		
		jq('#issue-button').click(function(){
			window.location.href = ui.pageLink("pharmacyapp", "subStoreIssueAccountDrug");
		});		

        jq("#fromDate-display, #toDate-display").on("change", function () {
            reloadmyList();
        });

        jq('#issueName').on("keyup", function () {
            reloadmyList();
        });
		
        function reloadmyList() {
            var issueName = jq("#issueName").val();
            var fromDate = moment(jq("#fromDate-field").val()).format('DD/MM/YYYY');
            var toDate = moment(jq("#toDate-field").val()).format('DD/MM/YYYY');
            getAccountList(issueName, fromDate, toDate);
        }

        getAccountList();
    });

    //update the queue table
    function QueueTable(tests) {
        var jq = jQuery;
        jq('#issue-drug-account-list-table > tbody > tr').remove();
        var tbody = jq('#issue-drug-account-list-table > tbody');
        for (index in tests) {
            var item = tests[index];
            var row = '<tr>';

            row += '<td>' + (parseInt(index)+1) + '</td>'
            row += '<td>' + item.createdOn.toString().substring(0, 11).replaceAt(2, ",").replaceAt(6, " ").insertAt(3, 0, " ") + '</td>'
            row += '<td><a href="#" onclick="accountDetail(' + item.id + ');"' +
                    'accountDetail(id);' +
                    '">' + item.name + '  <a/></td>'
            row += '<td>N/A</td>'
            row += '<td><a onclick="accountDetail(' + item.id + ');"><i class="icon-bar-chart small"></i>VIEW</a></td>'

            row += '</tr>';
            tbody.append(row);
        }
    }

    function accountDetail(id) {
        window.location.href = emr.pageLink("pharmacyapp", "issueDrugAccountDetail", {
            "issueId": id
        });
    }
	
    function getAccountList(issueName, fromDate, toDate) {
        jq.getJSON('${ui.actionLink("pharmacyapp", "issueDrugAccountList", "fetchList")}',{
			issueName: issueName,
			fromDate: fromDate,
			toDate: toDate,
		}).success(function (data) {
			if (data.length === 0 && data != null) {
				jq().toastmessage('showNoticeToast', "No account found!");
				jq('#issue-drug-account-list-table > tbody > tr').remove();
				var tbody = jq('#issue-drug-account-list-table > tbody');
				var row = '<tr align="center"><td colspan="5">No accounts found</td></tr>';
				tbody.append(row);

			} else {
				QueueTable(data);

			}
		}).error(function () {
			jq().toastmessage('showNoticeToast', "An Error occurred while Fetching List");
			jq('#issue-drug-account-list-table > tbody > tr').remove();
			var tbody = jq('#issue-drug-account-list-table > tbody');
			var row = '<tr align="center"><td colspan="5">No Accounts found</td></tr>';
			tbody.append(row);

		});
    }
</script>

<style>
	.dashboard {
		border: 1px solid #eee;
		padding: 2px 0 0;
		margin-bottom: 5px;
	}

	.dashboard .info-header i {
		font-size: 2.5em !important;
		margin-right: 0;
		padding-right: 0;
	}

	.info-header div {
		display: inline-block;
		float: right;
		margin-top: 7px;
	}

	.info-header div label {
		color: #f26522;
	}

	.add-on {
		color: #f26522;
		left: auto;
		margin-left: -29px;
		margin-top: 4px !important;
		position: absolute;
	}

	#fromDate,
	#toDate {
		float: none;
		margin-bottom: -9px;
		margin-top: 12px;
		padding-right: 0;
	}
	
	td a{
		text-transform: uppercase;
	}
	
	#issue-drug-account-list-table td:first-child{
		width: 5px;
	}
	
	#issue-drug-account-list-table td:nth-child(2){
		width: 105px;
	}
	
	#issue-drug-account-list-table th:last-child,
	#issue-drug-account-list-table td:last-child{
		text-align: center;
		width: 70px;
	}

	 a:link {
		 color: blue;
		 text-decoration: none;
		 cursor: pointer;
	 }
</style>

<div class="clear"></div>
<div id="accounts-div">
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
					<i class="icon-chevron-right link"></i>
					Issue Lists
				</li>
			</ul>
		</div>
		
		<div class="patient-header new-patient-header">
			<div class="demographics">
				<h1 class="name" style="border-bottom: 1px solid #ddd;">
					<span>&nbsp;ISSUE TO ACCOUNT &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
				</h1>				
			</div>			
			
			<div class="show-icon">
				&nbsp;
			</div>
			
			<span id='issue-button' class="button confirm" id="getOrders" style="float: right; margin: 12px 5px 0 0;">
				<i class="icon-plus-sign small"></i>
				Issue Drugs
			</span>
			
			<div class="filter">
				<i class="icon-filter" style="color: rgb(91, 87, 166); float: left; font-size: 52px ! important; padding: 0px 10px 0px 0px;"></i>				
				
				<div class="second-col">
					<label for="phrase">Filter Account</label><br/>
                    <input type="text" id="issueName" name="issueName" placeholder="Enter Account Name" title="Enter account Name"/>
					<i class="icon-search" style="color: rgb(170, 170, 170); float: right; position: absolute; font-size: 16px ! important; margin-left: -505px; margin-top: 3px;"></i>
				</div>
				
				<div class="first-col">
					<label for="fromDate-display">From Date</label><br/>
					${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'fromDate', id: 'fromDate', label: '', useTime: false, defaultToday: false, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
				</div>
				
				<div class="first-col">
					<label for="toDate-display">To Date</label><br/>
					${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'toDate', id: 'toDate', label: '', useTime: false, defaultToday: false, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
				</div>				
			</div>
		</div>
	</div>

	<table id="issue-drug-account-list-table">
		<thead>
			<tr>
				<th>#</th>
				<th>DATE</th>
				<th>ACCOUNT NAME</th>
				<th>NOTES</th>
				<th>ACTION</th>
			</tr>
		</thead>

		<tbody>
			<tr align="center">
				<td colspan="5">No drug found</td>
			</tr>
		</tbody>
	</table>
</div>