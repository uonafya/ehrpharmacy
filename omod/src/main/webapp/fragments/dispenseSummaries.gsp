<% ui.includeJavascript("ehrconfigs", "moment.js") %>
<script stype="text/javascript">
    jQuery(function () {
        jq("#ptabs").tabs();
        populateData();
        jq("#filter").click(function () {
            populateData();
        });
        var redirectLink = '';

        jq('#pending, #dispense, #queue').on('click', function () {
            if (jq(this).attr('id') == 'queue'){
                redirectLink = 'patients-queue';
            }else if (jq(this).attr('id') == 'dispense') {
                redirectLink = 'dispense-drugs';
            } else if (jq(this).attr('id') == 'pending') {
                redirectLink = 'dispense-drugs';
            } else {
                return false;
            }

            window.location.href = ui.pageLink("pharmacyapp", "container", {
                rel: redirectLink
            });
        });

        jq(window).resize(function () {
            var d = jq('#main-dashboard');
            var m = 0.5306122;

            d.height((d.width() * m));
        }).resize();
    })


    function populateData() {
        const summaryFromDate = jq('#summaryFromDate-field').val(), summaryToDate = jq('#summaryToDate-field').val();
        console.log(summaryFromDate, "####", summaryToDate)
        jq.getJSON('${ui.actionLink("ehrcashier", "subStoreIssueDrugList", "getOrderList")}',
            {
                "fromDate": summaryFromDate,
                "toDate": summaryToDate,
                "issueName":"",
                "processed":0,
                "receiptId":""

            }
        ).success(function (data) {
            jq('.stat-digit').eq(0).html(data.length)
        })
        jq.getJSON('${ui.actionLink("pharmacyapp", "queue", "searchPatient")}',
            {
                "date": summaryFromDate,
                "toDate": summaryToDate,
                "searchKey":"",
                "currentPage":""

            }
        ).success(function (data) {
            jq('.stat-digit').eq(0).html(data.length)
        })
        jq.getJSON('${ui.actionLink("pharmacyapp", "subStoreListDispense", "getDispenseAggregateSummary")}',
            {
                "fromDate": summaryFromDate,
                "toDate": summaryToDate,
            }
        ).success(function (data) {
            console.log("Data received:", data);
            jq('.stat-digit').eq(1).html(data.pendingConfirmation)
            jq('.stat-digit').eq(2).html(data.totalDispenced)
            jq('.stat-digit').eq(3).html(data.pendingDispensation)
        });
    }
</script>
<style>
#divSeachProcessed {
    margin-right: 5px;
    margin-top: 23px;
}

#divSeachProcessed label {
    cursor: pointer;
}

#divSeachProcessed input {
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

html, body, #graph-container {
    width: 100%;
    height: 100%;
    margin: 0;
    padding: 0;
}

.card-counter {
    box-shadow: 2px 2px 10px #DADADA;
    margin: 5px;
    padding: 20px 10px;
    background-color: #fff;
    height: 100px;
    border-radius: 5px;
    transition: .3s linear all;
}

.card-counter:hover {
    box-shadow: 4px 4px 20px #DADADA;
    transition: .3s linear all;
}

.card-counter.primary {
    background-color: #B0E0E6;
    color: black;
}

.card-counter.danger {
    background-color: #E6E6FA;
    color: black;
}

.card-counter.pham {
    background-color: #E0FFFF;
    color: black;
}

.card-counter.success {
    background-color: #A9FF96;
    color: black;
}

.card-counter.info {
    background-color: #FFA07A;
    color: black;
}

.card-counter i {
    font-size: 2.5em;
    opacity: 0.2;
}

.card-counter .count-numbers {
    position: absolute;
    right: 35px;
    top: 20px;
    font-size: 20px;
    display: block;
}

.card-counter .count-name {
    position: absolute;
    right: 35px;
    top: 65px;
    font-style: italic;
    text-transform: capitalize;
    opacity: 0.5;
    display: block;
    font-size: 15px;
}
</style>
<link href="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.css"/>
<script src="//maxcdn.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js"></script>

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
                    <span>PHARMACY SUMMARIES  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
                </h1>
            </div>

            <div class="show-icon">
                &nbsp;
            </div>
        </div>
    </div>
</div>

<div class="ke-panel-frame">
    <div class="ke-panel-content">
        <br/>

        <div class="row">
            <div class="col-12">
                <div style="margin-top: -1px " class="onerow">
                    <i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>
                    <label>&nbsp;&nbsp;From&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'fromDate', id: 'summaryFromDate', label: '', useTime: false, defaultToday: false, class: ['newdtp']])}
                    <label>&nbsp;&nbsp;To&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'toDate', id: 'summaryToDate', label: '', useTime: false, defaultToday: false, class: ['newdtp']])}
                    <button id="filter" type="button" class=" btn task right">${ui.message("Filter")}</button>
                </div>
            </div>
        </div>

        <div id="ptabs">
            <ul>
                <li><a href="#orders">Orders Summary</a></li>
            </ul>
            <div class="ke-panel-frame" id="orders">
            <div class="row">
                <div class="col-md-12">
                    <hr/>
                </div>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="row">

                        <div class="col-md-4">
                            <div class="card-counter pham">
                                <i class="fa fa-plus-circle"></i>
                                <span class="count-name stat-text">Cashpoint</span>
                                <span class="count-numbers stat-digit"></span>
                            </div>
                        </div>

                        <div class="col-md-4" id="queue">
                            <div class="card-counter danger">
                                <i class="fa fa-users"></i>
                                <span class="count-name stat-text">Pending Confirmation</span>
                                <span class="count-numbers stat-digit"></span>
                            </div>
                        </div>

                        <div class="col-md-4" id="dispense">
                            <div class="card-counter danger">
                                <i class="icon-exchange"></i>
                                <span class="count-name stat-text">Dispensed</span>
                                <span class="count-numbers stat-digit"></span>
                            </div>
                        </div>

                        <div class="col-md-4" id="pending">
                            <div class="card-counter primary">
                                <i class="icon-retweet"></i>
                                <span class="count-name stat-text">Pending Dispensation</span>
                                <span class="count-numbers stat-digit"></span>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
            </div>

        </div>
    </div>
</div>