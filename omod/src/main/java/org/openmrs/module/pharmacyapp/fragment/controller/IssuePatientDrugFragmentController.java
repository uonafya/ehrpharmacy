package org.openmrs.module.pharmacyapp.fragment.controller;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.NumberUtils;
import org.hibernate.cfg.NotYetImplementedException;
import org.json.JSONArray;
import org.json.JSONObject;
import org.openmrs.Concept;
import org.openmrs.Patient;
import org.openmrs.Role;
import org.openmrs.api.ConceptService;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.InventoryCommonService;
import org.openmrs.module.hospitalcore.model.*;
import org.openmrs.module.hospitalcore.util.ActionValue;
import org.openmrs.module.hospitalcore.util.FlagStates;
import org.openmrs.module.hospitalcore.util.HospitalCoreConstants;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.ehrinventory.model.InventoryStoreDrugIndentDetail;
import org.openmrs.module.ehrinventory.util.DateUtils;
import org.openmrs.module.pharmacyapp.PatientWrapper;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;


public class IssuePatientDrugFragmentController {
    public void controller() {

    }

    public String saveIndentSlip(HttpServletRequest request) {
        String drugOrderString = request.getParameter("drugOrder");
        String indentString = request.getParameter("indentName");
        List<String> errors = new ArrayList<String>();
        InventoryDrug drug = null;
        int drugIdMain = -1;

        JSONArray indentArray = new JSONArray(indentString);
        JSONObject indentObject = indentArray.getJSONObject(0);
        String indentName = indentObject.getString("indentName");
        int mainStoreId = Integer.parseInt(indentObject.getString("mainstore"));

        InventoryService inventoryService = (InventoryService) Context.getService(InventoryService.class);
        Date date = new Date();
        int userId = Context.getAuthenticatedUser().getId();
        List<Role> role = new ArrayList<Role>(Context.getAuthenticatedUser().getAllRoles());
        InventoryStoreRoleRelation srl = null;
        Role rl = null;
        for (Role r : role) {
            if (inventoryService.getStoreRoleByName(r.toString()) != null) {
                srl = inventoryService.getStoreRoleByName(r.toString());
                rl = r;
            }
        }
        InventoryStore store = null;
        if (srl != null) {
            store = inventoryService.getStoreById(srl.getStoreid());

        }
        InventoryStore mainStore = inventoryService.getStoreById(mainStoreId);
        InventoryStoreDrugIndent indent = new InventoryStoreDrugIndent();
        indent.setName(indentName);
        indent.setCreatedOn(date);
        indent.setStore(store);
        indent.setMainStore(mainStore);

        if (!StringUtils.isBlank(request.getParameter("send"))) {
            indent.setMainStoreStatus(1);
            indent.setSubStoreStatus(2);
        } else {
            indent.setMainStoreStatus(0);
            indent.setSubStoreStatus(1);
        }
//        String fowardParam = "subStoreIndentDrug_"+userId;
//        List<InventoryStoreDrugIndentDetail> list = (List<InventoryStoreDrugIndentDetail> ) StoreSingleton.getInstance().getHash().get(fowardParam);
//        if(list != null && list.size() > 0){
//            indent = inventoryService.saveStoreDrugIndent(indent);
//            for(int i=0;i< list.size();i++){
//                InventoryStoreDrugIndentDetail indentDetail = list.get(i);
//                indentDetail.setCreatedOn(date);
//                indentDetail.setIndent(indent);
//                inventoryService.saveStoreDrugIndentDetail(indentDetail);
//            }
//            StoreSingleton.getInstance().getHash().remove(fowardParam);
//            return "success";
//        }else{
//            return "Sorry don't have any indents to save";
//        }

        JSONArray drugArray = new JSONArray(drugOrderString);
        List<InventoryStoreDrugIndentDetail> list = new ArrayList<InventoryStoreDrugIndentDetail>();
//        loop over the incoming items
        for (int i = 0; i < drugArray.length(); i++) {

            JSONObject incomingItem = drugArray.getJSONObject(i);
            System.out.println(incomingItem);
            String drugCategoryId = incomingItem.getString("drugCategoryId");
            String quantity = incomingItem.getString("quantity");
            String drugId = incomingItem.getString("drugId");
            String drugFormulationId = incomingItem.getString("drugFormulationId");
            if (StringUtils.isNotBlank(drugId)) {
                drug = inventoryService.getDrugById(Integer.parseInt(drugId));
            }
            if (drug == null) {
                errors.add("Drug is Required!");

            } else {
                drugIdMain = drug.getId();
            }
            int formulation = Integer.parseInt(drugFormulationId);

            InventoryDrugFormulation formulationO = inventoryService.getDrugFormulationById(formulation);
            if (formulationO == null) {
                errors.add("Formulation is Required.");
            }
            if (formulationO != null && drug != null && !drug.getFormulations().contains(formulationO)) {
                errors.add("Formulation is not correct.");
            }

            if (CollectionUtils.isNotEmpty(errors)) {
                return "error";
            }


            InventoryStoreDrugIndentDetail indentDetail = new InventoryStoreDrugIndentDetail();
            indentDetail.setDrug(drug);
            indentDetail.setFormulation(inventoryService.getDrugFormulationById(formulation));
            indentDetail.setQuantity(Integer.parseInt(quantity));
            list.add(indentDetail);

        }

        if (list != null && list.size() > 0) {
            indent = inventoryService.saveStoreDrugIndent(indent);
            for (int i = 0; i < list.size(); i++) {
                InventoryStoreDrugIndentDetail indentDetail = list.get(i);
                indentDetail.setCreatedOn(date);
                indentDetail.setIndent(indent);
                inventoryService.saveStoreDrugIndentDetail(indentDetail);
            }
        }
        return "success";
    }

    public String processIssueDrug(HttpServletRequest request) {
        String patientType = request.getParameter("patientType");
        String selectedDrugs = request.getParameter("selectedDrugs");
        Integer patientId = Integer.parseInt(request.getParameter("patientId"));
        Double totalAmount = Double.parseDouble(request.getParameter("totalAmount"));
        int receiptId = 0;

        JSONArray jsonArray = new JSONArray(selectedDrugs);
        List<InventoryStoreDrugPatientDetail> list = new ArrayList<InventoryStoreDrugPatientDetail>();

        InventoryService inventoryService = Context.getService(InventoryService.class);
        int userId = Context.getAuthenticatedUser().getId();
        List<Role> role = new ArrayList<Role>(Context.getAuthenticatedUser().getAllRoles());

        InventoryStoreRoleRelation srl = null;
        Role rl = null;
        for (Role r : role) {
            if (inventoryService.getStoreRoleByName(r.toString()) != null) {
                srl = inventoryService.getStoreRoleByName(r.toString());
                rl = r;
            }
        }
        InventoryStore subStore = null;
        if (srl != null) {
            subStore = inventoryService.getStoreById(srl.getStoreid());

        }
        InventoryStoreDrugPatient issueDrugPatient = new InventoryStoreDrugPatient();
        if (patientId != null && patientId > 0) {
            Patient patient = Context.getPatientService().getPatient(patientId);
            if (patient != null) {

                issueDrugPatient.setCreatedBy(Context.getAuthenticatedUser().getGivenName());
                issueDrugPatient.setCreatedOn(new Date());
                issueDrugPatient.setStore(subStore);
                issueDrugPatient.setIdentifier(patient.getPatientIdentifier().getIdentifier());
                if (patient.getMiddleName() != null) {
                    issueDrugPatient.setName(patient.getGivenName() + " " + patient.getFamilyName() + " " + patient.getMiddleName().replace(",", " "));
                } else {
                    issueDrugPatient.setName(patient.getGivenName() + " " + patient.getFamilyName());
                }
                issueDrugPatient.setPatient(patient);
            }

        }
        //process the incoming json string
        ConceptService conceptService = Context.getConceptService();
        InventoryCommonService inventoryCommonService = Context.getService(InventoryCommonService.class);

        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject object = jsonArray.getJSONObject(i);

            Integer noOfDays = NumberUtils.toInt(object.getString("noOfDays"), 0);
            Integer frequency = NumberUtils.toInt(object.getString("drugPatientFrequencyId"), 0);
            Integer drugQuantity = NumberUtils.toInt(object.getString("drugQuantity"), 0);
            Integer category = NumberUtils.toInt(object.getString("issueDrugCategoryId"), 0);
            String drugName = object.getString("drugPatientName");
            String comments = object.getString("issueComment");
            Concept freCon = conceptService.getConcept(frequency);

            InventoryStoreDrugTransactionDetail transactionDetail = inventoryService.getStoreDrugTransactionDetailById(object.getInt("id"));

            transactionDetail.setFrequency(freCon.getName().getConcept());
            transactionDetail.setNoOfDays(noOfDays.intValue());
            transactionDetail.setComments(comments);
            InventoryStoreDrugPatientDetail issueDrugDetail = new InventoryStoreDrugPatientDetail();
            issueDrugDetail.setTransactionDetail(transactionDetail);
            issueDrugDetail.setQuantity(drugQuantity);
            list.add(issueDrugDetail);
        }

        if (issueDrugPatient != null && list != null && list.size() > 0) {
            Date date = new Date();
            // create transaction issue from substore
            InventoryStoreDrugTransaction transaction = new InventoryStoreDrugTransaction();
            transaction.setDescription("ISSUE DRUG TO PATIENT "
                    + DateUtils.getDDMMYYYY());
            transaction.setStore(subStore);
            transaction.setTypeTransaction(ActionValue.TRANSACTION[1]);
            transaction.setCreatedOn(date);
            //transaction.setPaymentMode(paymentMode);
            transaction.setPaymentCategory(String.valueOf(issueDrugPatient.getPatient().getAttribute(Context.getPersonService().getPersonAttributeTypeByUuid("09cd268a-f0f5-11ea-99a8-b3467ddbf779"))));
            transaction.setCreatedBy(Context.getAuthenticatedUser().getGivenName());
            transaction = inventoryService.saveStoreDrugTransaction(transaction);

            //Finally Saved Here
            issueDrugPatient = inventoryService.saveStoreDrugPatient(issueDrugPatient);
            receiptId = issueDrugPatient.getId();

            for (InventoryStoreDrugPatientDetail pDetail : list) {
                Date date1 = new Date();
                try {
                    Thread.sleep(2000);
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
                Integer totalQuantity = inventoryService.sumCurrentQuantityDrugOfStore(subStore.getId(), pDetail.getTransactionDetail().getDrug().getId(), pDetail.getTransactionDetail().getFormulation().getId());
                InventoryStoreDrugTransactionDetail drugTransactionDetail = inventoryService.getStoreDrugTransactionDetailById(pDetail.getTransactionDetail().getId());

                pDetail.getTransactionDetail().setCurrentQuantity(drugTransactionDetail.getCurrentQuantity());
                inventoryService.saveStoreDrugTransactionDetail(pDetail.getTransactionDetail());

                // save transactiondetail first
                InventoryStoreDrugTransactionDetail transDetail = new InventoryStoreDrugTransactionDetail();
                transDetail.setTransaction(transaction);
                transDetail.setCurrentQuantity(0);
                transDetail.setIssueQuantity(pDetail.getQuantity());
                transDetail.setOpeningBalance(totalQuantity);
                transDetail.setClosingBalance(totalQuantity);
                transDetail.setQuantity(0);
                transDetail.setVAT(pDetail.getTransactionDetail().getVAT());
                transDetail.setCostToPatient(pDetail.getTransactionDetail().getCostToPatient());
                transDetail.setUnitPrice(pDetail.getTransactionDetail().getUnitPrice());
                transDetail.setDrug(pDetail.getTransactionDetail().getDrug());
                transDetail.setFormulation(pDetail.getTransactionDetail().getFormulation());
                transDetail.setBatchNo(pDetail.getTransactionDetail().getBatchNo());
                transDetail.setCompanyName(pDetail.getTransactionDetail().getCompanyName());
                transDetail.setDateManufacture(pDetail.getTransactionDetail().getDateManufacture());
                transDetail.setDateExpiry(pDetail.getTransactionDetail().getDateExpiry());
                transDetail.setReceiptDate(pDetail.getTransactionDetail().getReceiptDate());
                transDetail.setCreatedOn(date1);
                transDetail.setReorderPoint(pDetail.getTransactionDetail().getDrug().getReorderQty());
                transDetail.setAttribute(pDetail.getTransactionDetail().getDrug().getAttributeName());
                transDetail.setPatientType(patientType);

                transDetail.setFrequency(pDetail.getTransactionDetail().getFrequency());
                transDetail.setNoOfDays(pDetail.getTransactionDetail().getNoOfDays());
                transDetail.setComments(pDetail.getTransactionDetail().getComments());
                BigDecimal moneyUnitPrice = pDetail.getTransactionDetail().getCostToPatient().multiply(new BigDecimal(pDetail.getQuantity()));
                transDetail.setTotalPrice(moneyUnitPrice);
                transDetail.setParent(pDetail.getTransactionDetail());
                transDetail = inventoryService.saveStoreDrugTransactionDetail(transDetail);

                pDetail.setStoreDrugPatient(issueDrugPatient);
                pDetail.setTransactionDetail(transDetail);
                // save issue to patient detail
                inventoryService.saveStoreDrugPatientDetail(pDetail);
                // save issues transaction detail
            }
        }

        if (totalAmount == 0){
            BigDecimal waiverAmount = new BigDecimal("0.00");

            List<InventoryStoreDrugPatientDetail> listDrugIssue = inventoryService.listStoreDrugPatientDetail(receiptId);
            InventoryStoreDrugPatient inventoryStoreDrugPatient1 = null;

            if (listDrugIssue != null && listDrugIssue.size() > 0) {
                InventoryStoreDrugTransaction inventoryTransaction = new InventoryStoreDrugTransaction();
                inventoryTransaction.setDescription("ISSUE DRUG TO PATIENT " + DateUtils.getDDMMYYYY());
                inventoryTransaction.setStore(subStore);
                inventoryTransaction.setTypeTransaction(ActionValue.TRANSACTION[1]);
                inventoryTransaction.setCreatedBy(Context.getAuthenticatedUser().getGivenName());
                inventoryTransaction = inventoryService.saveStoreDrugTransaction(inventoryTransaction);

                for (InventoryStoreDrugPatientDetail patientDetail : listDrugIssue) {
                    Date date1 = new Date();
                    try {
                        Thread.sleep(2000);
                    } catch (InterruptedException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                    Integer totalQuantity = inventoryService
                            .sumCurrentQuantityDrugOfStore(subStore.getId(), patientDetail
                                            .getTransactionDetail().getDrug().getId(),
                                    patientDetail.getTransactionDetail().getFormulation()
                                            .getId());
                    int t = totalQuantity - patientDetail.getQuantity();

                    InventoryStoreDrugTransactionDetail inventoryStoreDrugTransactionDetail = inventoryService
                            .getStoreDrugTransactionDetailById(patientDetail.getTransactionDetail().getParent().getId());
                    InventoryStoreDrugTransactionDetail drugTransactionDetail = inventoryService.getStoreDrugTransactionDetailById(inventoryStoreDrugTransactionDetail.getId());
                    inventoryStoreDrugTransactionDetail.setCurrentQuantity(drugTransactionDetail.getCurrentQuantity() - patientDetail.getQuantity());
                    inventoryService.saveStoreDrugTransactionDetail(inventoryStoreDrugTransactionDetail);

                    // save transactiondetail first
                    InventoryStoreDrugTransactionDetail transactionDetail = new InventoryStoreDrugTransactionDetail();
                    transactionDetail.setTransaction(inventoryTransaction);
                    transactionDetail.setCurrentQuantity(0);

                    transactionDetail.setIssueQuantity(patientDetail.getQuantity());
                    transactionDetail.setOpeningBalance(totalQuantity);
                    transactionDetail.setClosingBalance(totalQuantity - patientDetail.getQuantity());
                    transactionDetail.setQuantity(0);
                    transactionDetail.setVAT(patientDetail.getTransactionDetail().getVAT());
                    transactionDetail.setCostToPatient(patientDetail.getTransactionDetail().getCostToPatient());
                    transactionDetail.setUnitPrice(patientDetail.getTransactionDetail().getUnitPrice());
                    transactionDetail.setDrug(patientDetail.getTransactionDetail().getDrug());
                    transactionDetail.setFormulation(patientDetail.getTransactionDetail().getFormulation());
                    transactionDetail.setBatchNo(patientDetail.getTransactionDetail().getBatchNo());
                    transactionDetail.setCompanyName(patientDetail.getTransactionDetail().getCompanyName());
                    transactionDetail.setDateManufacture(patientDetail.getTransactionDetail().getDateManufacture());
                    transactionDetail.setDateExpiry(patientDetail.getTransactionDetail().getDateExpiry());
                    transactionDetail.setReceiptDate(patientDetail.getTransactionDetail().getReceiptDate());
                    transactionDetail.setCreatedOn(date1);
                    transactionDetail.setReorderPoint(patientDetail.getTransactionDetail().getDrug().getReorderQty());
                    transactionDetail.setAttribute(patientDetail.getTransactionDetail().getDrug().getAttributeName());
                    transactionDetail.setFrequency(patientDetail.getTransactionDetail().getFrequency());
                    transactionDetail.setNoOfDays(patientDetail.getTransactionDetail().getNoOfDays());
                    transactionDetail.setComments(patientDetail.getTransactionDetail().getComments());
                    transactionDetail.setFlag(1);

                    BigDecimal moneyUnitPrice = patientDetail.getTransactionDetail().getCostToPatient().multiply(new BigDecimal(patientDetail.getQuantity()));

                    transactionDetail.setTotalPrice(moneyUnitPrice);
                    transactionDetail.setParent(patientDetail.getTransactionDetail());
                    transactionDetail = inventoryService.saveStoreDrugTransactionDetail(transactionDetail);

                    patientDetail.setQuantity(patientDetail.getQuantity());

                    patientDetail.setTransactionDetail(transactionDetail);


                    // save issue to patient detail
                    inventoryService.saveStoreDrugPatientDetail(patientDetail);
                    inventoryStoreDrugPatient1 = inventoryService.getStoreDrugPatientById(patientDetail.getStoreDrugPatient().getId());
                    if (transactionDetail.getFlag() == FlagStates.PARTIALLY_PROCESSED) {
                        inventoryStoreDrugPatient1.setStatuss(1);
                    }
                    Integer flags = patientDetail.getTransactionDetail().getFlag();
                }
                // update patient detail
                inventoryStoreDrugPatient1.setWaiverAmount(waiverAmount);
                inventoryStoreDrugPatient1.setComment("");
                inventoryService.saveStoreDrugPatient(inventoryStoreDrugPatient1);

            }

            //End of If
        }


        return "success";
    }

    public String processIssueDrugForIpdPatient() {
        throw new NotYetImplementedException("Not Yet Implemented for IPD");
    }


    /**
     * Searches for and returns a list of patients given thePatient Identifier or Patient details(firstname,lastname.gender...e.t.c)
     *
     * @param phrase
     * @param currentPage
     * @param pageSize
     * @param uiUtils
     * @param request
     * @return
     */
    public List<SimpleObject> searchSystemPatient(
            @RequestParam(value = "phrase", required = false) String phrase,
            @RequestParam(value = "currentPage", required = false) Integer currentPage,
            @RequestParam(value = "pageSize", required = false) Integer pageSize,
            UiUtils uiUtils, HttpServletRequest request) {
        String prefix = Context.getAdministrationService().getGlobalProperty(
                HospitalCoreConstants.PROPERTY_IDENTIFIER_PREFIX);

        String gender = request.getParameter("gender");
        if (gender.equalsIgnoreCase("any")) {
            gender = null;
        }
        Integer age = getInt(request.getParameter("age"));
        Integer ageRange = getInt(request.getParameter("ageRange"));
        String relativeName = request.getParameter("relativeName");
        String lastDayOfVisit = request.getParameter("lastDayOfVisit");
        Integer lastVisitRange = getInt(request.getParameter("lastVisit"));
        String maritalStatus = request.getParameter("patientMaritalStatus");
        String phoneNumber = request.getParameter("phoneNumber");
        String nationalId = request.getParameter("nationalId");
        String fileNumber = request.getParameter("fileNumber");
        HospitalCoreService hcs = (HospitalCoreService) Context
                .getService(HospitalCoreService.class);
        List<Patient> patients = hcs.searchPatient(phrase, gender, age, ageRange, lastDayOfVisit, lastVisitRange, relativeName
                , maritalStatus, phoneNumber, nationalId, fileNumber);


        List<PatientWrapper> wrapperList = patientsWithLastVisit(patients);

        return SimpleObject.fromCollection(wrapperList, uiUtils, "patientId", "wrapperIdentifier", "names", "age", "gender", "formartedVisitDate");
    }

    /**
     * Converts a String representation of a number to its Integer equivalent, otherwise returns 0
     *
     * @param value - the String to parse
     * @return the integer equivalent of the string, otherwise returns a 0
     */
    private Integer getInt(String value) {
        try {
            Integer number = Integer.parseInt(value);
            return number;
        } catch (Exception e) {
            return 0;
        }
    }

    private List<PatientWrapper> patientsWithLastVisit(List<Patient> patients) {
        HospitalCoreService hcs = Context.getService(HospitalCoreService.class);
        List<PatientWrapper> wrappers = new ArrayList<PatientWrapper>();
        for (Patient patient : patients) {
            wrappers.add(new PatientWrapper(patient, hcs.getLastVisitTime(patient)));
        }
        return wrappers;
    }


}
