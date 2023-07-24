package org.openmrs.module.pharmacyapp.page.controller;

import org.apache.commons.collections.CollectionUtils;
import org.openmrs.*;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.model.*;
import org.openmrs.module.hospitalcore.util.ActionValue;
import org.openmrs.module.hospitalcore.util.FlagStates;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.ehrinventory.util.DateUtils;
import org.openmrs.module.kenyaui.annotation.AppPage;
import org.openmrs.module.pharmacyapp.PharmacyAppConstants;
import org.openmrs.module.pharmacyapp.ReferenceApplicationWebConstants.ReferenceApplicationWebConstants;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.openmrs.ui.framework.page.PageRequest;
import org.springframework.web.bind.annotation.RequestParam;
import org.openmrs.module.kenyaemr.api.KenyaEmrService;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 *
 */
@AppPage(PharmacyAppConstants.APP_PHARMACY)
public class PrintDrugOrderPageController {

    public void get(@RequestParam(value = "issueId", required = false) Integer issueId,
                    PageModel model,
                    UiSessionContext sessionContext,
                    PageRequest pageRequest,
                    UiUtils uiUtils) {

        model.addAttribute("userLocation", Context.getService(KenyaEmrService.class).getDefaultLocation());
        InventoryService inventoryService = Context.getService(InventoryService.class);
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
            store = inventoryService.getStoreById(4);

        }
        List<InventoryStoreDrugPatientDetail> listDrugIssue = inventoryService
                .listStoreDrugPatientDetail(issueId);
        if (listDrugIssue != null && listDrugIssue.size() > 0) {
            InventoryStoreDrugTransaction transaction = new InventoryStoreDrugTransaction();
            transaction.setDescription("ISSUE DRUG TO PATIENT " + DateUtils.getDDMMYYYY());
            transaction.setStore(store);
            transaction.setTypeTransaction(ActionValue.TRANSACTION[1]);

            transaction.setCreatedBy(Context.getAuthenticatedUser().getGivenName());

            transaction = inventoryService.saveStoreDrugTransaction(transaction);
            model.addAttribute("patientId", listDrugIssue.get(0).getStoreDrugPatient().getPatient().getPatientId());
            for (InventoryStoreDrugPatientDetail pDetail : listDrugIssue) {

                Date date1 = new Date();
                try {
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
                Integer totalQuantity = inventoryService.sumCurrentQuantityDrugOfStore(4, pDetail
                        .getTransactionDetail().getDrug().getId(), pDetail.getTransactionDetail().getFormulation().getId());
                int t = totalQuantity;

                Integer receipt = pDetail.getStoreDrugPatient().getId();
                model.addAttribute("receiptid", receipt);

                InventoryStoreDrugTransactionDetail inventoryStoreDrugTransactionDetail = inventoryService
                        .getStoreDrugTransactionDetailById(pDetail.getTransactionDetail().getParent().getId());

                InventoryStoreDrugTransactionDetail drugTransactionDetail = inventoryService.getStoreDrugTransactionDetailById(inventoryStoreDrugTransactionDetail.getId());

                inventoryStoreDrugTransactionDetail.setCurrentQuantity(drugTransactionDetail.getCurrentQuantity());

                Integer flags = pDetail.getTransactionDetail().getFlag();

                if (flags == null || flags == FlagStates.NOT_PROCESSED){
                    flags = FlagStates.PARTIALLY_PROCESSED;
                }

                model.addAttribute("flag", flags);

                inventoryService.saveStoreDrugTransactionDetail(inventoryStoreDrugTransactionDetail);
                // save transactiondetail first
                InventoryStoreDrugTransactionDetail transDetail = new InventoryStoreDrugTransactionDetail();
                transDetail.setTransaction(transaction);
                transDetail.setCurrentQuantity(0);
                transDetail.setIssueQuantity(pDetail.getQuantity());
                transDetail.setOpeningBalance(totalQuantity);
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
                transDetail.setFrequency(pDetail.getTransactionDetail().getFrequency());
                transDetail.setNoOfDays(pDetail.getTransactionDetail().getNoOfDays());
                transDetail.setComments(pDetail.getTransactionDetail().getComments());
                transDetail.setFlag(FlagStates.PARTIALLY_PROCESSED);

                BigDecimal moneyUnitPrice = pDetail.getTransactionDetail().getCostToPatient().multiply(new BigDecimal(pDetail.getQuantity()));
                transDetail.setTotalPrice(moneyUnitPrice);
                transDetail.setParent(pDetail.getTransactionDetail());
                transDetail = inventoryService.saveStoreDrugTransactionDetail(transDetail);
            }

        }

        List<SimpleObject> dispensedDrugs = SimpleObject.fromCollection(listDrugIssue, uiUtils, "quantity", "transactionDetail.costToPatient", "transactionDetail.drug.name",
                "transactionDetail.formulation.name", "transactionDetail.formulation.dozage", "transactionDetail.frequency.name", "transactionDetail.noOfDays",
                "transactionDetail.comments", "transactionDetail.dateExpiry");
        model.addAttribute("listDrugIssue", SimpleObject.create("listDrugIssue", dispensedDrugs).toJson());
        if (listDrugIssue.size() > 0) {
            model.addAttribute("waiverAmount", listDrugIssue.get(0).getStoreDrugPatient().getWaiverAmount());
            model.addAttribute("waiverComment", listDrugIssue.get(0).getStoreDrugPatient().getComment());
        }else{
            model.addAttribute("waiverAmount", "0");
            model.addAttribute("waiverComment", "N/A");
        }


        if (CollectionUtils.isNotEmpty(listDrugIssue)) {
            model.addAttribute("issueDrugPatient", listDrugIssue.get(0)
                    .getStoreDrugPatient());

            model.addAttribute("date", listDrugIssue.get(0)
                    .getStoreDrugPatient().getCreatedOn());
            int age = listDrugIssue.get(0)
                    .getStoreDrugPatient().getPatient().getAge();
            if (age < 1) {
                model.addAttribute("age", "<1");
            } else {
                model.addAttribute("age", age);
            }
            //TODO starts here

            PatientIdentifier pi = listDrugIssue.get(0).getStoreDrugPatient().getPatient().getPatientIdentifier();

            int patientId = pi.getPatient().getPatientId();

            Date issueDate = listDrugIssue.get(0).getStoreDrugPatient().getCreatedOn();
            Encounter encounterId = listDrugIssue.get(0).getTransactionDetail().getEncounter();

            List<OpdDrugOrder> listOfNotDispensedOrder = new ArrayList<OpdDrugOrder>();
            if (encounterId != null) {
                listOfNotDispensedOrder = inventoryService.listOfNotDispensedOrder(patientId, issueDate, encounterId);
            }

            List<SimpleObject> notDispensed = SimpleObject.fromCollection(listOfNotDispensedOrder, uiUtils, "inventoryDrug.name",
                    "inventoryDrugFormulation.name", "inventoryDrugFormulation.dozage", "frequency.name", "noOfDays", "comments");
            model.addAttribute("listOfNotDispensedOrder", SimpleObject.create("listOfNotDispensedOrder", notDispensed).toJson());

            //TODO ends here

            model.addAttribute("identifier", listDrugIssue.get(0).getStoreDrugPatient().getPatient().getPatientIdentifier());
            model.addAttribute("givenName", listDrugIssue.get(0).getStoreDrugPatient().getPatient().getGivenName());
            model.addAttribute("familyName", listDrugIssue.get(0).getStoreDrugPatient().getPatient().getFamilyName());
            model.addAttribute("birthdate", listDrugIssue.get(0).getStoreDrugPatient().getPatient().getBirthdate());

            if (listDrugIssue.get(0).getStoreDrugPatient().getPatient().getMiddleName() != null) {
                model.addAttribute("middleName", listDrugIssue.get(0).getStoreDrugPatient().getPatient().getMiddleName());
            } else {
                model.addAttribute("middleName", "");
            }


            if (listDrugIssue.get(0)
                    .getStoreDrugPatient().getPatient().getGender().equals("M")) {
                model.addAttribute("gender", "Male");
            }
            if (listDrugIssue.get(0)
                    .getStoreDrugPatient().getPatient().getGender().equals("F")) {
                model.addAttribute("gender", "Female");
            }

            model.addAttribute("cashier", listDrugIssue.get(0)
                    .getStoreDrugPatient().getCreatedBy());

            HospitalCoreService hcs = Context.getService(HospitalCoreService.class);
            List<PersonAttribute> pas = hcs.getPersonAttributes(listDrugIssue.get(0)
                    .getStoreDrugPatient().getPatient().getId());

            model.addAttribute("lastVisit", hcs.getLastVisitTime(listDrugIssue.get(0).getStoreDrugPatient().getPatient()));

            for (PersonAttribute pa : pas) {
                PersonAttributeType attributeType = pa.getAttributeType();

                if (hcs.getPersonAttributeTypeByName("Paying Category Type").equals(Context.getPersonService()
                        .getPersonAttributeTypeByUuid("e191b0b8-f069-11ea-b498-2bfd800847e8"))) {
                    model.addAttribute("paymentCategory", "PAYING");
                    model.addAttribute("paymentSubCategory", pa.getValue());
                } else if (hcs.getPersonAttributeTypeByName("Non-Paying Category Type").equals(Context.getPersonService()
                        .getPersonAttributeTypeByUuid("0a8ae818-f06a-11ea-ab82-2f183f30d954"))) {
                    model.addAttribute("paymentCategoryName", "NON-PAYING");
                    model.addAttribute("paymentSubCategory", pa.getValue());
                } else if (hcs.getPersonAttributeTypeByName("Special Scheme Category Type").equals(Context.getPersonService()
                        .getPersonAttributeTypeByUuid("341ee8fa-f06a-11ea-aca0-03d040bd88c8")) ){
                    model.addAttribute("paymentCategoryName", "SPECIAL SCHEMES");
                    model.addAttribute("paymentSubCategory", pa.getValue());
                }
            }
            model.addAttribute("userLocation", Context.getAdministrationService().getGlobalProperty("hospital.location_user"));

        }

    }
}
