<%
    def props = ["name", "createdOn", "subStoreStatusName", "action"]
%>
<script>
    jq(function () {
        jQuery('.date-pick').datepicker({minDate: '-100y', dateFormat: 'dd/mm/yy'});
        getIndentList();

        //action when the searchField change occurs
        jq("#indentName").on("keyup", function () {
            reloadList();
        });

        jq("#statusId, #fromDate-display, #toDate-display").on("change", function () {
            reloadList();
        });

        function reloadList() {
            var statusId = jq("#statusId").val();
            var indentName = jq("#indentName").val();
            var fromDate = moment(jq("#fromDate-field").val()).format('DD/MM/YYYY');
            var toDate = moment(jq("#toDate-field").val()).format('DD/MM/YYYY');

            getIndentList(statusId, indentName, fromDate, toDate);
        }

        jq('#issue-button').click(function () {
            window.location.href = ui.pageLink("pharmacyapp", "subStoreIndentDrug");
        });
    });//end of doc ready


    function detailDrugIndentPrint(indentId) {
        window.location.href = ui.pageLink("pharmacyapp", "indentDrugDetail", {
            "indentId": indentId
        });
    }


    function getIndentList(statusId, indentName, fromDate, toDate) {
        jq.getJSON('${ui.actionLink("pharmacyapp", "indentDrugList", "showList")}',
                {
                    statusId: statusId,
                    indentName: indentName,
                    fromDate: fromDate,
                    toDate: toDate,
                }).success(function (data) {
                    if (data.length === 0 && data != null) {
                        jq().toastmessage('showNoticeToast', "No drug found!");
                        jq('#indent-search-result-table > tbody > tr').remove();
                        var tbody = jq('#indent-search-result-table > tbody');
                        var row = '<tr align="center"><td colspan="5">No Drugs found</td></tr>';
                        tbody.append(row);
                    } else {
                        updateQueueTable(data);
                    }
                }).error(function () {
                    jq().toastmessage('showNoticeToast', "An Error Occured while Fetching List");
                    jq('#indent-search-result-table > tbody > tr').remove();
                    var tbody = jq('#indent-search-result-table > tbody');
                    var row = '<tr align="center"><td colspan="5">No Drugs found</td></tr>';
                    tbody.append(row);
                });
    }


    //update the queue table
    function updateQueueTable(tests) {
        var jq = jQuery;
        jq('#indent-search-result-table > tbody > tr').remove();
        var tbody = jq('#indent-search-result-table > tbody');
        for (index in tests) {
            var row = '<tr>';
            var c = parseInt(index) + 1;
            var item = tests[index];

            row += '<td>' + c + '</td>'
            row += '<td>' + item.createdOn.substring(0, 11).replaceAt(2, ",").replaceAt(6, " ").insertAt(3, 0, " ") + '</td>'
            row += '<td><a  href="#" onclick="detailDrugIndentPrint(' + item.id + ');">' + item.name + ' </a></td>'
            row += '<td>' + item.subStoreStatusName + '</td>'
            var link = "";
            if (item.subStoreStatus == 1) {
                link += '<a href="#" title="Send Order" onclick="processSendIndent(' + item.id + ');" >Send Order</a>';
            } else if (item.subStoreStatus == 3) {
                link += '<a href="#" title="Process Order" onclick="processDrugIndent(' + item.id + ');" >Process Order</a>';
            }

            row += '<td>' + link + '</td>'
            row += '</tr>';
            tbody.append(row);
        }
    }

    function processDrugIndent(indentId) {
        window.location.href = ui.pageLink("pharmacyapp", "subStoreDrugProcessIndent", {
            "indentId": indentId
        });
    }
    function processSendIndent(indentId) {
        window.location.href = ui.pageLink("pharmacyapp", "sendDrugIndentToMainStore", {
            "indentId": indentId
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

.filter #indentName {
    padding-left: 30px;
    width: 100%;
}

.second-col {
    width: 32%;
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

td a {
    text-transform: uppercase;
}

#issue-drug-account-list-table td:first-child {
    width: 5px;
}

#issue-drug-account-list-table td:nth-child(2) {
    width: 105px;
}

#issue-drug-account-list-table th:last-child,
#issue-drug-account-list-table td:last-child {
    text-align: center;
    width: 70px;
}

th:first-child {
    width: 5px;
}

th:nth-child(2) {
    width: 110px;
}

th:last-child {
    width: 70px;
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
                    <i class="icon-chevron-right link"></i>
                    Drugs Order
                </li>
            </ul>
        </div>

        <div class="patient-header new-patient-header">
            <div class="demographics">
                <h1 class="name" style="border-bottom: 1px solid #ddd;">
                    <span>&nbsp;DRUGS ORDER &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
                </h1>
            </div>

            <div class="show-icon">
                &nbsp;
            </div>

            <span id='issue-button' class="button confirm" id="getOrders" style="float: right; margin: 12px 5px 0 0;">
                <i class="icon-plus-sign small"></i>
                Add Order Slip
            </span>

            <div class="filter">
                <i class="icon-filter"
                   style="color: rgb(91, 87, 166); float: left; font-size: 52px ! important; padding: 0px 10px 0px 0px;"></i>

                <div class="second-col">
                    <label for="indentName">Filter Account</label><br/>
                    <input type="text" id="indentName" name="indentName" placeholder="Enter Drug Name"/>
                    <i class="icon-search"
                       style="color: rgb(170, 170, 170); float: right; position: absolute; font-size: 16px ! important; margin-left: -31%; margin-top: 3px;"></i>
                </div>

                <div class="first-col">
                    <label for="fromDate-display">From Date</label><br/>
                    ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'fromDate', id: 'fromDate', label: '', useTime: false, defaultToday: false, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
                </div>

                <div class="first-col">
                    <label for="toDate-display">To Date</label><br/>
                    ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'toDate', id: 'toDate', label: '', useTime: false, defaultToday: false, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
                </div>

                <div class="first-col">
                    <label for="toDate-display">To Date</label><br/>
                    <select name="statusId" id="statusId" class="searchFieldChange" title="Select Status">
                        <option value="">Select Status</option>
                        <% listSubStoreStatus.each { %>
                        <option value="${it.id}" title="${it.name}">
                            ${it.name}
                        </option>
                        <% } %>
                    </select>
                </div>
            </div>
        </div>

        <table id="indent-search-result-table">
            <thead>
            <tr role="row">
                <th>#</th>
                <th>DATE</th>
                <th>RECEIPT NAME</th>
                <th>STATUS</th>
                <th>ACTION</th>
            </tr>
            </thead>

            <tbody>
            <tr align="center">
                <td>&nbsp;</td>
                <td colspan="5">No Order Found</td>
            </tr>
            </tbody>
        </table>
    </div>
</div>