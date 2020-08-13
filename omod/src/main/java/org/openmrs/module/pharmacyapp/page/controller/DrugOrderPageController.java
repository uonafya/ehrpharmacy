package org.openmrs.module.pharmacyapp.page.controller;

import org.apache.commons.lang.StringUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.openmrs.*;
import org.openmrs.api.PatientService;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.BillingService;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.InventoryCommonService;
import org.openmrs.module.hospitalcore.PatientDashboardService;
import org.openmrs.module.hospitalcore.model.*;
import org.openmrs.module.hospitalcore.util.ActionValue;
import org.openmrs.module.hospitalcore.util.FlagStates;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.ehrinventory.util.DateUtils;
import org.openmrs.module.pharmacyapp.ReferenceApplicationWebConstants.ReferenceApplicationWebConstants;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.openmrs.ui.framework.page.PageRequest;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.logging.Logger;

/**
 * Created by Francis Githae on 3/31/16.
 */
public class DrugOrderPageController {
    private final static Logger logger = Logger.getLogger(DrugOrderPageController.class.getName());

    public void get(
            PageModel model,
            UiSessionContext sessionContext,
            PageRequest pageRequest,
            @RequestParam("patientId") Integer patientId,
            @RequestParam("encounterId") Integer encounterId,
            @RequestParam(value = "date", required = false) String dateStr,
            @RequestParam(value = "patientType", required = false) String patientType,
            UiUtils uiUtils) {

        pageRequest.getSession().setAttribute(ReferenceApplicationWebConstants.SESSION_ATTRIBUTE_REDIRECT_URL, uiUtils.thisUrl());
        sessionContext.requireAuthentication();

        InventoryService inventoryService = Context
                .getService(InventoryService.class);

        List<OpdDrugOrder> drugOrderList = inventoryService.listOfDrugOrder(
                patientId, encounterId);
        List<SimpleObject> simpleObjects = SimpleObject.fromCollection(drugOrderList, uiUtils, "inventoryDrug.name",
                "inventoryDrugFormulation.name", "inventoryDrugFormulation.dozage", "frequency.name", "noOfDays", "comments",
                "inventoryDrug.id", "inventoryDrugFormulation.id", "dosage", "dosageUnit.name");

        String toJson = SimpleObject.create("simpleObjects", simpleObjects).toJson();
        model.addAttribute("drugOrderListJson", toJson);
        model.addAttribute("drugOrderList", drugOrderList);
        model.addAttribute("patientId", patientId);
        model.addAttribute("encounterId", encounterId);

        HospitalCoreService hospitalCoreService = Context.getService(HospitalCoreService.class);
        PatientSearch patientSearch = hospitalCoreService.getPatientByPatientId(patientId);

        Patient patient = Context.getPatientService().getPatient(patientId);
        Integer prescriberId = 0;
        String doctor = "Unknown";

        if (drugOrderList.get(0).getCreator() != null) {
            prescriberId = drugOrderList.get(0).getCreator().getId();
            doctor = drugOrderList.get(0).getCreator().getGivenName();
        }

        model.addAttribute("patientCategory", patient.getAttribute(14));
        model.addAttribute("previousVisit", hospitalCoreService.getLastVisitTime(patient));
        model.addAttribute("patientSearch", patientSearch);
        model.addAttribute("patientType", patientType);
        model.addAttribute("date", dateStr);
        model.addAttribute("doctor", doctor);
        model.addAttribute("prescriberId", prescriberId);

        if (patient.getGender().equals("M")) {
            model.addAttribute("gender", "Male");
        } else {
            model.addAttribute("gender", "Female");
        }

        InventoryStoreDrugPatient inventoryStoreDrugPatient = new InventoryStoreDrugPatient();

        model.addAttribute("pharmacist", Context.getAuthenticatedUser().getGivenName());
        model.addAttribute("userLocation", Context.getAdministrationService().getGlobalProperty("hospital.location_user"));
    }

    public String post(HttpServletRequest request, UiUtils uiUtils) throws Exception {
        String order = request.getParameter("order");
        String remove = request.getParameter("remove");

        String patientType = request.getParameter("patientType");

        int encounterId = Integer.parseInt(request.getParameter("encounterId"));
        int patientId = Integer.parseInt(request.getParameter("patientId"));
        int presciberId = Integer.parseInt(request.getParameter("prescriberId"));
        int receiptId = 0;
        Context.addProxyPrivilege("View Users");
        User prescriber = Context.getUserService().getUser(presciberId);
        Context.removeProxyPrivilege("View Users");
        String totalChargesString = request.getParameter("totalCharges");
        Number number = NumberFormat.getNumberInstance(Locale.US).parse(totalChargesString);
        Double totalCharges = number.doubleValue();

        BigDecimal waiverAmount = null;
        if (StringUtils.isNotEmpty(request.getParameter("waiverAmount"))) {
            waiverAmount = new BigDecimal(request.getParameter("waiverAmount"));
        }

        String comment = request.getParameter("comment");

        JSONArray orders = new JSONArray(order);
        JSONArray removes = new JSONArray(remove);

        PatientService patientService = Context.getPatientService();
        Patient patient = patientService.getPatient(patientId);
        InventoryService inventoryService = Context.getService(InventoryService.class);
        //InventoryStore store =  inventoryService.getStoreByCollectionRole(new ArrayList<Role>(Context.getAuthenticatedUser().getAllRoles()));
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

        Date date = new Date();
        Integer formulationId = null;
        String frequencyName = null;
        String comments = null;
        Integer quantity = null;
        Integer noOfDays = null;
        Integer avlId;
        int listOfDrugQuantity = 0;

        //Declarations
        InventoryStoreDrugPatient inventoryStoreDrugPatient = new InventoryStoreDrugPatient();
        InventoryStoreDrugTransaction transaction = new InventoryStoreDrugTransaction();
        HospitalCoreService hcs = Context.getService(HospitalCoreService.class);
        //inside and if
        if (orders.length() > 0) {
            inventoryStoreDrugPatient.setStore(store);
            inventoryStoreDrugPatient.setPatient(patient);
            if (patient.getMiddleName() != null) {
                inventoryStoreDrugPatient.setName(patient.getGivenName() + " " + patient.getFamilyName() + " " + patient.getMiddleName().replace(",", " "));
            } else {
                inventoryStoreDrugPatient.setName(patient.getGivenName() + " " + patient.getFamilyName());
            }
            inventoryStoreDrugPatient.setIdentifier(patient.getPatientIdentifier().getIdentifier());
            inventoryStoreDrugPatient.setCreatedBy(Context.getAuthenticatedUser().getGivenName());
            inventoryStoreDrugPatient.setCreatedOn(date);
            inventoryStoreDrugPatient.setPrescriber(prescriber);
            inventoryStoreDrugPatient = inventoryService.saveStoreDrugPatient(inventoryStoreDrugPatient);

            receiptId = inventoryStoreDrugPatient.getId();

            transaction.setDescription("ISSUE DRUG TO PATIENT " + DateUtils.getDDMMYYYY());
            transaction.setStore(store);
            transaction.setTypeTransaction(ActionValue.TRANSACTION[1]);
            transaction.setCreatedOn(date);
            //transaction.setPaymentMode(paymentMode);
            transaction.setPaymentCategory(patient.getAttribute(14).getValue());
            transaction.setCreatedBy(Context.getAuthenticatedUser().getGivenName());

            transaction = inventoryService.saveStoreDrugTransaction(transaction);

            List<EncounterType> types = new ArrayList<EncounterType>();
            EncounterType eType = new EncounterType(10);
            types.add(eType);
            Encounter lastVisitEncounter = hcs.getLastVisitEncounter(patient, types);

            for (int i = 0; i < orders.length(); i++) {
                JSONObject incomingItem = orders.getJSONObject(i);
                try{
                    noOfDays = Integer.parseInt(incomingItem.getString("noOfDays"));
                    listOfDrugQuantity = Integer.parseInt(incomingItem.getString("listOfDrugQuantity"));
                    frequencyName = incomingItem.getString("frequencyName");
                    quantity = Integer.parseInt(incomingItem.getString("quantity"));
                    formulationId = Integer.parseInt(incomingItem.getString("formulationId"));
                    comments = incomingItem.getString("comments");
                }catch (Exception e){
                    logger.info(e.getMessage());
                }

                InventoryCommonService inventoryCommonService = Context.getService(InventoryCommonService.class);
                Concept fCon = Context.getConceptService().getConcept(frequencyName);
                if (quantity != 0) {
                    InventoryDrugFormulation inventoryDrugFormulation = inventoryCommonService.getDrugFormulationById(formulationId);
                    InventoryStoreDrugPatientDetail pDetail = new InventoryStoreDrugPatientDetail();
                    InventoryStoreDrugTransactionDetail inventoryStoreDrugTransactionDetail = inventoryService.getStoreDrugTransactionDetailById(listOfDrugQuantity);
                    Integer totalQuantity = inventoryService.sumCurrentQuantityDrugOfStore(store.getId(),
                            inventoryStoreDrugTransactionDetail.getDrug().getId(), inventoryDrugFormulation.getId());
                    int t = totalQuantity;
                    InventoryStoreDrugTransactionDetail drugTransactionDetail = inventoryService.getStoreDrugTransactionDetailById(inventoryStoreDrugTransactionDetail.getId());
                    inventoryStoreDrugTransactionDetail.setCurrentQuantity(drugTransactionDetail.getCurrentQuantity());
                    inventoryService.saveStoreDrugTransactionDetail(inventoryStoreDrugTransactionDetail);
                    //save transactiondetail first
                    InventoryStoreDrugTransactionDetail transDetail = new InventoryStoreDrugTransactionDetail();
                    transDetail.setTransaction(transaction);
                    transDetail.setCurrentQuantity(0);
                    transDetail.setIssueQuantity(quantity);
                    transDetail.setOpeningBalance(totalQuantity);
                    transDetail.setClosingBalance(t);
                    transDetail.setQuantity(0);
                    transDetail.setVAT(inventoryStoreDrugTransactionDetail.getVAT());
                    transDetail.setCostToPatient(inventoryStoreDrugTransactionDetail.getCostToPatient());
                    transDetail.setUnitPrice(inventoryStoreDrugTransactionDetail.getUnitPrice());
                    transDetail.setDrug(inventoryStoreDrugTransactionDetail.getDrug());
                    transDetail.setReorderPoint(inventoryStoreDrugTransactionDetail.getDrug().getReorderQty());
                    transDetail.setAttribute(inventoryStoreDrugTransactionDetail.getDrug().getAttributeName());
                    transDetail.setFormulation(inventoryDrugFormulation);
                    transDetail.setBatchNo(inventoryStoreDrugTransactionDetail.getBatchNo());
                    transDetail.setCompanyName(inventoryStoreDrugTransactionDetail.getCompanyName());
                    transDetail.setDateManufacture(inventoryStoreDrugTransactionDetail.getDateManufacture());
                    transDetail.setDateExpiry(inventoryStoreDrugTransactionDetail.getDateExpiry());
                    transDetail.setReceiptDate(inventoryStoreDrugTransactionDetail.getReceiptDate());
                    transDetail.setCreatedOn(date);
                    transDetail.setPatientType(patientType);
                    transDetail.setEncounter(Context.getEncounterService().getEncounter(encounterId));

                    transDetail.setFrequency(fCon);
                    transDetail.setNoOfDays(noOfDays);
                    transDetail.setComments(comments);

                    BigDecimal moneyUnitPrice = inventoryStoreDrugTransactionDetail.getCostToPatient().multiply(new BigDecimal(quantity));
                    // moneyUnitPrice = moneyUnitPrice.add(moneyUnitPrice.multiply(inventoryStoreDrugTransactionDetail.getVAT().divide(new BigDecimal(100))));
                    transDetail.setTotalPrice(moneyUnitPrice);
                    transDetail.setParent(inventoryStoreDrugTransactionDetail);
                    transDetail = inventoryService.saveStoreDrugTransactionDetail(transDetail);

                    pDetail.setQuantity(quantity);

                    pDetail.setStoreDrugPatient(inventoryStoreDrugPatient);
                    pDetail.setTransactionDetail(transDetail);
                    //save issue to patient detail
                    inventoryService.saveStoreDrugPatientDetail(pDetail);

                    BillingService billingService = Context.getService(BillingService.class);
                    IndoorPatientServiceBill bill = new IndoorPatientServiceBill();
                    bill.setActualAmount(moneyUnitPrice);
                    bill.setAmount(moneyUnitPrice);

                    bill.setEncounter(lastVisitEncounter);
                    bill.setCreatedDate(new Date());
                    bill.setPatient(patient);
                    bill.setCreator(Context.getAuthenticatedUser());


                    IndoorPatientServiceBillItem item = new IndoorPatientServiceBillItem();

                    item.setUnitPrice(pDetail.getTransactionDetail().getCostToPatient());
                    item.setAmount(moneyUnitPrice);
                    item.setQuantity(pDetail.getQuantity());
                    item.setName(pDetail.getTransactionDetail().getDrug().getName());
                    item.setCreatedDate(new Date());
                    item.setIndoorPatientServiceBill(bill);
                    item.setActualAmount(moneyUnitPrice);
                    item.setOrderType("DRUG");
                    bill.addBillItem(item);
                    bill = billingService.saveIndoorPatientServiceBill(bill);

                    OpdDrugOrder opdDrugOrder = inventoryService.getOpdDrugOrder(patientId, encounterId,
                            inventoryStoreDrugTransactionDetail.getDrug().getId(), formulationId);


                    PatientDashboardService patientDashboardService = Context.getService(PatientDashboardService.class);
                    opdDrugOrder.setOrderStatus(1);
                    patientDashboardService.saveOrUpdateOpdDrugOrder(opdDrugOrder);
                }
            }
        }

        if (removes.length() > 0) {
            for (int i = 0; i < removes.length(); i++) {
                JSONObject removeItems = removes.getJSONObject(i);
                Integer drugId = removeItems.getJSONObject("inventoryDrug").getInt("id");
                formulationId = removeItems.getJSONObject("inventoryDrugFormulation").getInt("id");

                OpdDrugOrder opdDrugOrder = inventoryService.getOpdDrugOrder(patientId, encounterId,
                        drugId, formulationId);

                PatientDashboardService patientDashboardService = Context.getService(PatientDashboardService.class);
                opdDrugOrder.setCancelStatus(1);
                patientDashboardService.saveOrUpdateOpdDrugOrder(opdDrugOrder);
            }
        }
        if (totalCharges == 0 && orders.length() > 0) {
            //Checkout the items here
            waiverAmount = new BigDecimal("0.00");

            List<InventoryStoreDrugPatientDetail> listDrugIssue = inventoryService
                    .listStoreDrugPatientDetail(receiptId);
            InventoryStoreDrugPatient inventoryStoreDrugPatient1 = null;

            if (listDrugIssue != null && listDrugIssue.size() > 0) {
                InventoryStoreDrugTransaction inventoryTransaction = new InventoryStoreDrugTransaction();
                inventoryTransaction.setDescription("ISSUE DRUG TO PATIENT " + DateUtils.getDDMMYYYY());
                inventoryTransaction.setStore(store);
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
                            .sumCurrentQuantityDrugOfStore(store.getId(), patientDetail
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
                    transactionDetail.setClosingBalance(t);
                    transactionDetail.setQuantity(0);
                    transactionDetail.setVAT(patientDetail.getTransactionDetail().getVAT());
                    transactionDetail.setCostToPatient(patientDetail.getTransactionDetail().getCostToPatient());
                    transactionDetail.setUnitPrice(patientDetail.getTransactionDetail()
                            .getUnitPrice());
                    transactionDetail.setDrug(patientDetail.getTransactionDetail().getDrug());
                    transactionDetail.setFormulation(patientDetail.getTransactionDetail()
                            .getFormulation());
                    transactionDetail.setBatchNo(patientDetail.getTransactionDetail()
                            .getBatchNo());
                    transactionDetail.setCompanyName(patientDetail.getTransactionDetail()
                            .getCompanyName());
                    transactionDetail.setDateManufacture(patientDetail.getTransactionDetail()
                            .getDateManufacture());
                    transactionDetail.setDateExpiry(patientDetail.getTransactionDetail()
                            .getDateExpiry());
                    transactionDetail.setReceiptDate(patientDetail.getTransactionDetail()
                            .getReceiptDate());
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
                    transactionDetail = inventoryService
                            .saveStoreDrugTransactionDetail(transactionDetail);
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
                inventoryStoreDrugPatient1.setComment(comment);
                inventoryService.saveStoreDrugPatient(inventoryStoreDrugPatient1);

            }
        }
        return "redirect:" + uiUtils.pageLink("pharmacyapp", "container") + "?rel=patients-queue";
    }
}

