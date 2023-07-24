package org.openmrs.module.pharmacyapp.fragment.controller;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.openmrs.*;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.model.*;
import org.openmrs.module.hospitalcore.util.ActionValue;
import org.openmrs.module.hospitalcore.util.FlagStates;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.ehrinventory.util.DateUtils;
import org.openmrs.module.ehrinventory.util.PagingUtil;
import org.openmrs.module.ehrinventory.util.RequestUtil;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;

import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class ViewDrugIssuedPatientFragmentController {
    public void controller (){

    }
    public List <SimpleObject> fetchList( @RequestParam(value="pageSize",required=false)  Integer pageSize,
                        @RequestParam(value="currentPage",required=false)  Integer currentPage,
                        @RequestParam(value="issueName",required=false)  String issueName,
                        @RequestParam(value="fromDate",required=false)  String fromDate,
                        @RequestParam(value="toDate",required=false)  String toDate,
                        @RequestParam(value="receiptId",required=false)  Integer receiptId,
                        UiUtils uiUtils, HttpServletRequest request
    ) {

        InventoryService inventoryService = (InventoryService) Context.getService(InventoryService.class);


        List<Role> role=new ArrayList<Role>(Context.getAuthenticatedUser().getAllRoles());

        InventoryStoreRoleRelation srl=null;
        Role rl = null;
        for(Role r: role){
            if(inventoryService.getStoreRoleByName(r.toString())!=null){
                srl = inventoryService.getStoreRoleByName(r.toString());
                rl=r;
            }
        }
        InventoryStore store =null;

        if(srl!=null){
            store = inventoryService.getStoreById(4);

        }

        int total = inventoryService.countStoreDrugPatient(4, issueName, fromDate, toDate);


        String temp = "";


        if(issueName != null){
            if(StringUtils.isBlank(temp)){
                temp = "?issueName="+issueName;
            }else{
                temp +="&issueName="+issueName;
            }
        }
        if(!StringUtils.isBlank(fromDate)){
            if(StringUtils.isBlank(temp)){
                temp = "?fromDate="+fromDate;
            }else{
                temp +="&fromDate="+fromDate;
            }
        }
        if(!StringUtils.isBlank(toDate)){
            if(StringUtils.isBlank(temp)){
                temp = "?toDate="+toDate;
            }else{
                temp +="&toDate="+toDate;
            }
        }
        if(receiptId != null){
            if(StringUtils.isBlank(temp)){
                temp = "?receiptId="+receiptId;
            }else{
                temp +="&receiptId="+receiptId;
            }
        }

        PagingUtil pagingUtil = new PagingUtil( RequestUtil.getCurrentLink(request)+temp , pageSize, currentPage, total );
        List<InventoryStoreDrugPatient> listIssue = inventoryService.listStoreDrugPatient(4,receiptId, issueName,fromDate, toDate, pagingUtil.getStartPos(), pagingUtil.getPageSize());

        for(InventoryStoreDrugPatient in :listIssue)
        {

            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
            String created =  sdf.format(in.getCreatedOn());
            String changed = sdf.format(new Date());
            int  value= changed.compareTo(created);
            in.setValues(value);
            in=inventoryService.saveStoreDrugPatient(in);

        }
        return SimpleObject.fromCollection(listIssue,uiUtils,"id","patient","identifier","patient.age","patient.gender","createdOn","name");

    }

    public SimpleObject fetchDrugIssuedData(@RequestParam(value="id",required=false)  Integer issueId,
                                    UiUtils uiUtils,
                                    HttpServletRequest request)
    {
        SimpleObject drugData;
        Date issueDate = null;
        InventoryStoreDrugPatient inventoryStoreDrugPatient1= new InventoryStoreDrugPatient();
         List<OpdDrugOrder> listOfNotDispensedOrder = null;
        String paymentCategory = "";

        InventoryService inventoryService = (InventoryService) Context
                .getService(InventoryService.class);
        //InventoryStore store =  inventoryService.getStoreByCollectionRole(new ArrayList<Role>(Context.getAuthenticatedUser().getAllRoles()));
        List <Role>role=new ArrayList<Role>(Context.getAuthenticatedUser().getAllRoles());

        InventoryStoreRoleRelation srl=null;
        Role rl = null;
        for(Role r: role){
            if(inventoryService.getStoreRoleByName(r.toString())!=null){
                srl = inventoryService.getStoreRoleByName(r.toString());
                rl=r;
            }
        }
        InventoryStore store =null;
        if(srl!=null){
            store = inventoryService.getStoreById(4);

        }

        List<InventoryStoreDrugPatientDetail> listDrugIssue = inventoryService
                .listStoreDrugPatientDetail(issueId);
        InventoryStoreDrugPatient inventoryStoreDrugPatient = new InventoryStoreDrugPatient();


        if ( inventoryStoreDrugPatient != null && listDrugIssue != null && listDrugIssue.size() > 0) {


            InventoryStoreDrugTransaction transaction = new InventoryStoreDrugTransaction();
            transaction.setDescription("ISSUE DRUG TO PATIENT "+ DateUtils.getDDMMYYYY());
            transaction.setStore(store);
            transaction.setTypeTransaction(ActionValue.TRANSACTION[1]);

            transaction.setCreatedBy(Context.getAuthenticatedUser().getGivenName());

            transaction = inventoryService.saveStoreDrugTransaction(transaction);
            for (InventoryStoreDrugPatientDetail pDetail : listDrugIssue) {

                Date date1 = new Date();
                try {
                    Thread.sleep(2000);
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
                Integer totalQuantity = inventoryService
                        .sumCurrentQuantityDrugOfStore(4, pDetail
                                        .getTransactionDetail().getDrug().getId(),
                                pDetail.getTransactionDetail().getFormulation()
                                        .getId());
                int t = totalQuantity;

                Integer receipt=pDetail.getStoreDrugPatient().getId();

                InventoryStoreDrugTransactionDetail inventoryStoreDrugTransactionDetail  = inventoryService
                        .getStoreDrugTransactionDetailById(pDetail.getTransactionDetail().getParent().getId());

                InventoryStoreDrugTransactionDetail drugTransactionDetail = inventoryService.getStoreDrugTransactionDetailById(inventoryStoreDrugTransactionDetail.getId());

                inventoryStoreDrugTransactionDetail.setCurrentQuantity(drugTransactionDetail.getCurrentQuantity());

                Integer flags =pDetail.getTransactionDetail().getFlag();
                inventoryService.saveStoreDrugTransactionDetail( inventoryStoreDrugTransactionDetail);
                // save transactiondetail first
                InventoryStoreDrugTransactionDetail transDetail = new InventoryStoreDrugTransactionDetail();
                transDetail.setTransaction(transaction);
                transDetail.setCurrentQuantity(0);
                transDetail.setIssueQuantity(pDetail.getQuantity());
                transDetail.setOpeningBalance( totalQuantity);
                transDetail.setClosingBalance(t);
                transDetail.setQuantity(0);
                transDetail.setVAT(pDetail.getTransactionDetail().getVAT());
                transDetail.setCostToPatient(pDetail.getTransactionDetail().getCostToPatient());
                transDetail.setUnitPrice(pDetail.getTransactionDetail()
                        .getUnitPrice());
                transDetail.setDrug(pDetail.getTransactionDetail().getDrug());
                transDetail.setFormulation(pDetail.getTransactionDetail()
                        .getFormulation());
                transDetail.setBatchNo(pDetail.getTransactionDetail()
                        .getBatchNo());
                transDetail.setCompanyName(pDetail.getTransactionDetail()
                        .getCompanyName());
                transDetail.setDateManufacture(pDetail.getTransactionDetail()
                        .getDateManufacture());
                transDetail.setDateExpiry(pDetail.getTransactionDetail()
                        .getDateExpiry());
                transDetail.setReceiptDate(pDetail.getTransactionDetail()
                        .getReceiptDate());
                transDetail.setCreatedOn(date1);
                transDetail.setReorderPoint(pDetail.getTransactionDetail().getDrug().getReorderQty());
                transDetail.setAttribute(pDetail.getTransactionDetail().getDrug().getAttributeName());
                transDetail.setFrequency(pDetail.getTransactionDetail().getFrequency());transDetail.setNoOfDays(pDetail.getTransactionDetail().getNoOfDays());
                transDetail.setComments(pDetail.getTransactionDetail().getComments());
                transDetail.setFlag(FlagStates.PARTIALLY_PROCESSED);


                BigDecimal moneyUnitPrice = pDetail.getTransactionDetail().getCostToPatient().multiply(new BigDecimal(pDetail.getQuantity()));

                transDetail.setTotalPrice(moneyUnitPrice);


                transDetail.setParent(pDetail.getTransactionDetail());
                transDetail = inventoryService
                        .saveStoreDrugTransactionDetail(transDetail);



            }

        }

        if (CollectionUtils.isNotEmpty(listDrugIssue)) {

            inventoryStoreDrugPatient1 = listDrugIssue.get(0).getStoreDrugPatient();
            PatientIdentifier pi = listDrugIssue.get(0).getStoreDrugPatient().getPatient().getPatientIdentifier();

            int patientId = pi.getPatient().getPatientId();
            issueDate = listDrugIssue.get(0).getStoreDrugPatient().getCreatedOn();
            Encounter encounterId = listDrugIssue.get(0).getTransactionDetail().getEncounter();


            if(encounterId!= null )
            {
                listOfNotDispensedOrder = inventoryService.listOfNotDispensedOrder(patientId,issueDate,encounterId);

            }

            HospitalCoreService hcs = Context.getService(HospitalCoreService.class);
            List<PersonAttribute> pas = hcs.getPersonAttributes(listDrugIssue.get(0)
                    .getStoreDrugPatient().getPatient().getId());
            for (PersonAttribute pa : pas) {
                PersonAttributeType attributeType = pa.getAttributeType();
                PersonAttributeType personAttributePCT=hcs.getPersonAttributeTypeByName("Paying Category Type");
                PersonAttributeType personAttributeNPCT=hcs.getPersonAttributeTypeByName("Non-Paying Category Type");
                PersonAttributeType personAttributeSSCT=hcs.getPersonAttributeTypeByName("Special Scheme Category Type");
                paymentCategory = pa.getValue();
            }
        }

        Patient patientInfo = inventoryStoreDrugPatient1.getPatient();
        String name =  patientInfo.getGivenName() + " " + patientInfo.getFamilyName() + " " + patientInfo.getMiddleName();

        List<SimpleObject> listDrugIssueObj = SimpleObject.fromCollection(listDrugIssue, uiUtils, "transactionDetail.drug.name","transactionDetail.formulation.name","transactionDetail.frequency.name","transactionDetail.noOfDays","transactionDetail.comments","transactionDetail.dateExpiry","quantity");

         List<SimpleObject> listDrugNotIssuedObj = SimpleObject.fromCollection(listOfNotDispensedOrder, uiUtils, "transactionDetail.drug.name","transactionDetail.formulation.name","transactionDetail.frequency.name","transactionDetail.noOfDays","transactionDetail.comments","transactionDetail.dateExpiry","quantity");

        drugData = SimpleObject.create("issueDate",issueDate, "name",name, "age", patientInfo.getAge(),
                "gender", patientInfo.getGender(),"paymentCategory", paymentCategory, "listDrugIssue", listDrugIssueObj,"listDrugNotIssuedObj", listDrugNotIssuedObj);

        return drugData;

    }

}
