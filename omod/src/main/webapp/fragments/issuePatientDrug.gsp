<%
    def props = ["wrapperIdentifier", "names", "age", "gender", "formartedVisitDate", "action"]	
	ui.includeCss("ehrcashier", "onepcssgrid.css")
%>

<script>

    jq(document).ready(function () {
        jq('.col4 select').bind('change keyup', function() {
            ADVSEARCH.delay();
        });
		
        jq('input').keydown(function (e) {
            var key = e.keyCode || e.which;
            if ((key == 9 || key == 13) && jq(this).attr('id') != 'searchPhrase') {
                ADVSEARCH.delay();
            }
        });
		
        jq('#lastDayOfVisit-display').on("change", function (dateText) {
            ADVSEARCH.delay();
        });
    });

    jq.fn.clearForm = function() {
        return this.each(function() {
            var type = this.type, tag = this.tagName.toLowerCase();
            if (tag == 'form')
                return jq(':input',this).clearForm();
            if ((type == 'text' || type == 'hidden') && jq(this).attr('id') != 'searchPhrase')
                this.value = '';
            else if (type == 'checkbox' || type == 'radio')
                this.checked = false;
            else if (tag == 'select')
                this.selectedIndex = -1;
        });
    };

    function strReplace(word) {
        var res = word.replace("[", "");
        res=res.replace("]","");
        return res;
    }

    ADVSEARCH = {
        timeoutId: 0,
        showing: false,
        params: "",
        delayDuration: 1,
        pageSize: 10,
        beforeSearch: function () {
        },
        // search patient
        searchPatient: function (currentPage, pageSize) {
            this.beforeSearch();
            var phrase = jq("#searchPhrase").val();

            if (phrase.length >= 1) {
                jq("#ajaxLoader").show();
                getPatientQueue(1);
            }
            else{
                jq().toastmessage('showNoticeToast', "Specify atleast one character to Search");
            }
        },
        // start searching patient
        startSearch: function (e) {
            e = e || window.event;
            ch = e.which || e.keyCode;
            if (ch != null) {
                if ((ch >= 48 && ch <= 57) || (ch >= 96 && ch <= 105)
                        || (ch >= 65 && ch <= 90)
                        || (ch == 109 || ch == 189 || ch == 45) || (ch == 8)
                        || (ch == 46)) {
                } else if (ch == 13) {
                    clearTimeout(this.timeoutId);
                    this.timeoutId = setTimeout("ADVSEARCH.delay()",
                            this.delayDuration);
                }
            }
        },
        // delay before search
        delay: function () {
            this.searchPatient(0, this.pageSize);
        },
        visitaddIssueSlip: function(patientId){
            window.location.href = ui.pageLink("pharmacyapp", "issueDrug", {
                "patientId": patientId
            });
        }
    };

    // get queue
    function getPatientQueue(currentPage) {
        this.currentPage = currentPage;
        var phrase = jq("#searchPhrase").val();
        var pgSize = 1000;
        var gender = jq("#gender").val();
        var age = jq("#age").val();
        var ageRange = jq("#ageRange").val();
        var patientMaritalStatus = jq("#patientMaritalStatus").val();
        var lastDayOfVisit = jq('#lastDayOfVisit-field').val() && moment(jq('#lastDayOfVisit-field').val()).format('DD/MM/YYYY');
        var lastVisit = jq('#lastVisit').val();
        var phoneNumber = jq("#phoneNumber").val();
        var relativeName = jq("#relativeName").val();
        var nationalId = jq("#nationalId").val();
        var fileNumber = jq("#fileNumber").val();
        jq.ajax({
            type: "POST",
            url: "${ui.actionLink('pharmacyapp','issuePatientDrug','searchSystemPatient')}",
            dataType: "json",
            data: ({
                gender: gender,
                phrase: phrase,
                currentPage: currentPage,
                pageSize: pgSize,
                age: age,
                ageRange: ageRange,
                patientMaritalStatus: patientMaritalStatus,
                lastVisit: lastVisit,
                phoneNumber: phoneNumber,
                relativeName: relativeName,
                nationalId: nationalId,
                fileNumber: fileNumber,
                lastDayOfVisit: lastDayOfVisit
            }),
            success: function (data) {
                jq("#ajaxLoader").hide();
                pData = data;
                updateSystemQueueTable(data);
            },
            error: function (xhr, ajaxOptions, thrownError) {
                alert(xhr);
                jq("#ajaxLoader").hide();
            }
        });
    }
    function HideDashboard() {
        jq('#dashboard').hide();
        jq('#patientSystemSearchForm').clearForm();
    }
    function ShowDashboard() {
        jq('#dashboard').toggle(500);
        jq('#patientSystemSearchForm').clearForm();
    }

    //update the queue table
    function updateSystemQueueTable(data) {
        jq('#patient-search-results-table > tbody > tr').remove();
        var tbody = jq('#patient-search-results-table > tbody');
        for (index in data) {
            var item = data[index];
            var rows 		= '<tr>';
			var rowsClass 	= '';
			var gender 		= item.gender;
			var lastVisit 	= moment(item.formartedVisitDate, 'DD/MM/YYYY HH:mm:ss').fromNow();
			var names 		= stringReplace(item.names);
			var visit 		= moment(item.formartedVisitDate,'DD/MM/YYYY HH:mm:ss');
			var today 		= moment();

			var hours 	= Math.round(moment.duration(today - visit).asHours());
			
			console.log(hours +'hrs - >'+ lastVisit);
			
			if (hours <= 24){
				rowsClass	= 'recent-seen';
				names	   += ' <span class="recent-lozenge">Within 24hrs</span>'
			}
			
			if (gender === 'M'){
				gender = 'Male';
			}
			else {
				gender = 'Female'
			}
			
            rows = '<tr class=' + rowsClass + '><td>' + (1+parseInt(index)) + '</td>';
			rows += '<td>'+item.wrapperIdentifier+'</td>';
			rows += '<td>'+names+'</td>';
			rows += '<td>'+item.age+'</td>';
			rows += '<td>'+gender+'</td>';
			rows += '<td>'+lastVisit+'</td>';
			rows += '<td><a title="Issue Slip" onclick="ADVSEARCH.visitaddIssueSlip('+item.patientId +');">ISSUE <i class="icon-arrow-right small" ></i></a></td>';											
            rows += '</tr>';
			
            tbody.append(rows);
            
        }
        if (jq('#patient-search-results-table tr').length <= 1){
            tbody.append('<tr align="center"><td>&nbsp;</td><td colspan="6">No patients found</td></tr>');
        }        
    }
    
</script>

<style>
	body {
		margin-top: 20px;
	}
	.col1, .col2, .col3, .col4, .col5, .col6, .col7, .col8, .col9, .col10, .col11, .col12 {
		color: #555;
		text-align: left;
	}
	form input,
	form select {
		margin: 0px;
		display: inline-block;
		min-width: 50px;
		padding: 2px 10px;
		height: 32px !important;
	}
	.info-header span {
		cursor: pointer;
		display: inline-block;
		float: right;
		margin-top: -2px;
		padding-right: 5px;
	}
	.dashboard .info-section {
		margin: 2px 5px 5px;
	}
	.toast-item {
		background-color: #222;
	}
	@media all and (max-width: 768px) {
		.onerow {
			margin: 0 0 100px;
		}
	}
	form .advanced {
		background: #363463 none repeat scroll 0 0;
		border-color: #dddddd;
		border-style: solid;
		border-width: 1px;
		color: #fff;
		cursor: pointer;
		float: right;
		padding: 6px 0;
		text-align: center;
		width: 27%;
	}
	form .advanced i {
		font-size: 22px;
	}
	.col4 label {
		width: 110px;
		display: inline-block;
	}
	.col4 input[type=text] {
		display: inline-block;
		padding: 4px 10px;
	}
	.col4 select {
		padding: 4px 10px;
	}
	form select {
		min-width: 50px;
		display: inline-block;
	}
	
	.identifiers span {
		border-radius: 50px;
		color: white;
		display: inline;
		font-size: 0.8em;
		letter-spacing: 1px;
		margin: 5px;
	}
	table.dataTable thead th, table.dataTable thead td {
		padding: 5px 10px;
	}
	form input:focus,
	form select:focus {
		outline: 2px none #007fff;
	}
	input[type="text"], select {
		border: 1px solid #aaa;
		border-radius: 2px !important;
		box-shadow: none !important;
		box-sizing: border-box !important;
		height: 32px;
	}
	.newdtp {
		width: 166px;
	}
	#lastDayOfVisit label, 
	#referred-date label{
		display: none;
	}
	#lastDayOfVisit input {
		width: 160px;
	}
	.add-on {
		color: #f26522;
		float: right;
		left: auto;
		margin-left: -29px;
		margin-top: 10px;
		position: absolute;
	}
	.chrome .add-on {
	  margin-left:-31px;
	  margin-top:-27px !important;
	  position:relative !important;
	}
	#lastDayOfVisit-wrapper .add-on{
		margin-top: 5px;
	}
	.ui-widget-content a {
		color: #007fff;
	}
	#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
		text-decoration: none;
	}
	.new-patient-header .identifiers {
		margin-top: 5px;
	}
	.name {
		color: #f26522;
	}
	#inline-tabs {
		background: #f9f9f9 none repeat scroll 0 0;
	}
	.formfactor{
		background: #f3f3f3 none repeat scroll 0 0;
		border: 1px solid #ddd;
		margin-bottom: 5px;
		padding: 5px 10px;
		text-align: left;
		width: auto;
	}
	.formfactor .lone-col{
		display: inline-block;
		margin-top: 5px;
		overflow: hidden;
		width: 100%;
	}
	.formfactor .first-col{
		display: inline-block;
		margin-top: 5px;
		overflow: hidden;
		width: 300px;
	}
	.formfactor .second-col{
		display: inline-block;
		float: right;
		margin-top: 5px;
		overflow: hidden;
		width: 600px;
	}
	
	.formfactor .lone-col input,
	.formfactor .first-col input,
	.formfactor .second-col input{
		margin-top: 5px;
		padding: 5px 15px;
		width: 100%;
	}
	.formfactor .lone-col label,
	.formfactor .first-col label,
	.formfactor .second-col label{
		padding-left: 5px;
		color: #363463;
		cursor: pointer;
	}
	.ui-tabs-panel h2{
		display: inline-block;
	}
	.recent-seen{
		background: #fff799 none repeat scroll 0 0!important;
		color: #000 !important;
	}
	.recent-lozenge {
		border: 1px solid #f00;
		border-radius: 4px;
		color: #f00;
		display: inline-block;
		font-size: 0.7em;
		padding: 1px 2px;
		vertical-align: text-bottom;
	}
</style>

<div class="clear"></div>
<div class="container" id="patients-div">
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
				Find Patient
			</li>
		</ul>
	</div>
	
	<div class="patient-header new-patient-header">
		<div class="demographics">
			<h1 class="name" style="border-bottom: 1px solid #ddd;">
				<span>ISSUE DRUGS TO PATIENT &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
			</h1>
		</div>
		
		<div class="show-icon">
			&nbsp;
		</div>			
	</div>

	<form onsubmit="return false" id="patientSystemSearchForm" method="get" style="margin-top: 5px;">
		<input autocomplete="off" placeholder="Search by Name / Identifier / Receipt Number" id="searchPhrase" style="float:left; width:70%; padding:6px 10px -1px; height: 38px!important" onkeyup="ADVSEARCH.startSearch(event);">
			   
		<img id="ajaxLoader" style="display:none; float:left; margin: 3px -4%;"
			 src="/openmrs/ms/uiframework/resource/registration/images/ajax-loader.gif"/>
			 <div class="info-section">
				

		<div id="advanced" class="advanced" onclick="ShowDashboard();"><i class="icon-filter"></i>ADVANCED SEARCH
		</div>

		<div id="dashboard" class="dashboard" style="display:none;">
			<div class="info-section">
				<div class="info-header">
					<i class="icon-diagnosis"></i>

					<h3>ADVANCED SEARCH</h3>
					<span id="as_close" onclick="HideDashboard();">
						<div class="identifiers">
							<span style="background:#00463f; padding: 1px 8px 5px;">x</span>
						</div>
					</span>
				</div>

				<div class="info-body" style="min-height: 140px;">
					<ul>
						<li>
							<div class="onerow">
								<div class="col4">
									<label for="gender">Gender</label>
									<select style="width: 160px" id="gender" name="gender">
										<option value="Any">Any</option>
										<option value="M">Male</option>
										<option value="F">Female</option>
									</select>
								</div>

								<div class="col4">
									<label>Last Visit</label>
									${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'lastDayOfVisit', id: 'lastDayOfVisit', label: '', useTime: false, defaultToday: false, class: ['newdtp'], endDate: new Date()])}
								</div>

								<div class="col4 last">
									<label for="relativeName">Relative Name</label>
									<input type="text" id="relativeName" name="relativeName" style="width: 160px"
										   placeholder="Relative Name">
								</div>
							</div>

							<div class="onerow" style="padding-top: 2px;">
								<div class="col4">
									<label for="age">Age</label>
									<input type="text" id="age" name="age" style="width: 160px" placeholder="Patient Age">
								</div>

								<div class="col4">
									<label for="gender">Previous Visit</label>
									<select style="width: 160px" id="lastVisit">
										<option value="Any">Anytime</option>
										<option value="31">Last month</option>
										<option value="183">Last 6 months</option>
										<option value="366">Last year</option>
									</select>
								</div>

								<div class="col4 last">
									<label for="nationalId">National ID</label>
									<input type="text" id="nationalId" name="nationalId" style="width: 160px"
										   placeholder="National ID">
								</div>
							</div>

							<div class="onerow" style="padding-top:2px;">
								<div class="col4">
									<label for="ageRange">Range &plusmn;</label>
									<select id="ageRange" name="ageRange" style="width: 160px">
										<option value="0">Exact</option>
										<option value="1">1</option>
										<option value="2">2</option>
										<option value="3">3</option>
										<option value="4">4</option>
										<option value="5">5</option>
									</select>
								</div>

								<div class="col4">
									<label for="phoneNumber">Phone No.</label>
									<input type="text" id="phoneNumber" name="phoneNumber" style="width: 160px"
										   placeholder="Phone No.">
								</div>

								<div class="col4 last">
									<label for="fileNumber">File Number</label>
									<input type="text" id="fileNumber" name="fileNumber" style="width: 160px"
										   placeholder="File Number">
								</div>
							</div>

							<div class="onerow" style="padding-top: 1px;">
								<div class="col4">
									<label for="patientMaritalStatus">Marital Status</label>
									<select id="patientMaritalStatus" style="width: 160px">
										<option value="">Any</option>
										<option value="Single">Single</option>
										<option value="Married">Married</option>
										<option value="Divorced">Divorced</option>
										<option value="Widow">Widow</option>
										<option value="Widower">Widower</option>
										<option value="Separated">Separated</option>
									</select>
								</div>

								<div class="col4">
									&nbsp;
								</div>

								<div class="col4 last">&nbsp;</div>
							</div>
						</li>
					</ul>
				</div>
			</div>
		</div>
	</form>

</div>





<div id="patient-search-results" style="display: block; margin-top:3px;">
    <div role="grid" class="dataTables_wrapper" id="patient-search-results-table_wrapper">
        <table id="patient-search-results-table" class="dataTable"
               aria-describedby="patient-search-results-table_info">
            <thead>
            <tr role="row">
				<th style="width: 5px;"		>#</th>
                <th style="width: 220px;"	>Identifier</th>
                <th width="*"				>Name</th>
                <th style="width: 60px;"	>Age</th>
                <th style="width: 60px;"	>Gender</th>
                <th style="width: 130px;"	>Last Visit</th>
                <th style="width: 80px;"	>Action</th>
            </tr>
            </thead>

            <tbody role="alert" aria-live="polite" aria-relevant="all">
            <tr align="center">
                <td></td>
                <td colspan="6">No patients found</td>
            </tr>
            </tbody>
        </table>

    </div>
</div>

