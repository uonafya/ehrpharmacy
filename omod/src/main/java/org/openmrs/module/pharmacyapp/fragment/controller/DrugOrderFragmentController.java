package org.openmrs.module.pharmacyapp.fragment.controller;

import org.apache.commons.collections.CollectionUtils;
import org.openmrs.Encounter;
import org.openmrs.PatientIdentifier;
import org.openmrs.Role;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.*;
import org.openmrs.module.hospitalcore.util.ActionValue;
import org.openmrs.module.hospitalcore.util.FlagStates;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.ehrinventory.model.InventoryStoreDrugAccountDetail;
import org.openmrs.module.ehrinventory.util.DateUtils;
import org.openmrs.module.pharmacyapp.StoreSingleton;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
public class DrugOrderFragmentController {

    public List<SimpleObject> listReceiptDrugAvailable(
            @RequestParam(value = "drugId", required = false) Integer drugId,
            @RequestParam(value = "formulationId", required = false) Integer formulationId,
            @RequestParam(value = "frequencyName", required = false) String frequencyName,
            @RequestParam(value = "days", required = false) Integer days,
            @RequestParam(value = "comments", required = false) String comments,
            UiUtils uiUtils) {
        List<InventoryStoreDrugTransactionDetail> listReceiptDrugReturn = null;
        InventoryService inventoryService = (InventoryService) Context
                .getService(InventoryService.class);
        InventoryDrug drug = inventoryService.getDrugById(drugId);
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
        if (store != null && drug != null && formulationId != null) {
            List<InventoryStoreDrugTransactionDetail> listReceiptDrug = inventoryService
                    .listStoreDrugTransactionDetail(store.getId(),
                            drug.getId(), formulationId, true);
            // check that drug is issued before
            int userId = Context.getAuthenticatedUser().getId();

            String fowardParam = "issueDrugAccountDetail_" + userId;
            String fowardParamDrug = "issueDrugDetail_" + userId;
            List<InventoryStoreDrugPatientDetail> listDrug = (List<InventoryStoreDrugPatientDetail>) StoreSingleton
                    .getInstance().getHash().get(fowardParamDrug);
            List<InventoryStoreDrugAccountDetail> listDrugAccount = (List<InventoryStoreDrugAccountDetail>) StoreSingleton
                    .getInstance().getHash().get(fowardParam);
            listReceiptDrugReturn = new ArrayList<InventoryStoreDrugTransactionDetail>();
            boolean check = false;
            if (CollectionUtils.isNotEmpty(listDrug)) {
                if (CollectionUtils.isNotEmpty(listReceiptDrug)) {
                    for (InventoryStoreDrugTransactionDetail drugDetail : listReceiptDrug) {
                        for (InventoryStoreDrugPatientDetail drugPatient : listDrug) {
                            if (drugDetail.getId().equals(
                                    drugPatient.getTransactionDetail().getId())) {
                                drugDetail.setCurrentQuantity(drugDetail
                                        .getCurrentQuantity()
                                        - drugPatient.getQuantity());
                            }

                        }
                        if (drugDetail.getCurrentQuantity() > 0) {
                            listReceiptDrugReturn.add(drugDetail);
                            check = true;
                        }
                    }
                }
            }

            if (CollectionUtils.isNotEmpty(listDrugAccount)) {
                if (CollectionUtils.isNotEmpty(listReceiptDrug)) {
                    for (InventoryStoreDrugTransactionDetail drugDetail : listReceiptDrug) {
                        for (InventoryStoreDrugAccountDetail drugAccount : listDrugAccount) {
                            if (drugDetail.getId().equals(
                                    drugAccount.getTransactionDetail().getId())) {
                                drugDetail.setCurrentQuantity(drugDetail
                                        .getCurrentQuantity()
                                        - drugAccount.getQuantity());
                            }
                        }
                        if (drugDetail.getCurrentQuantity() > 0 && !check) {
                            listReceiptDrugReturn.add(drugDetail);
                        }
                    }
                }
            }
            if (CollectionUtils.isEmpty(listReceiptDrugReturn)
                    && CollectionUtils.isNotEmpty(listReceiptDrug)) {
                listReceiptDrugReturn.addAll(listReceiptDrug);
            }

//            model.addAttribute("listReceiptDrug", listReceiptDrugReturn);

            // ghanshyam,4-july-2013, issue no # 1984, User can issue drugs only
            // from the first indent
            String listOfDrugQuantity = "";
            for (InventoryStoreDrugTransactionDetail lrdr : listReceiptDrugReturn) {
                listOfDrugQuantity = listOfDrugQuantity
                        + lrdr.getId().toString() + ".";
            }

//            model.addAttribute("listOfDrugQuantity", listOfDrugQuantity);
        }

        return SimpleObject.fromCollection(listReceiptDrugReturn, uiUtils, "id", "dateExpiry", "dateManufacture", "companyName", "companyNameShort", "batchNo", "currentQuantity",
                "drug.name", "formulation.id", "formulation.name", "formulation.dozage", "costToPatient");
    }


    public String subStoreIssueDrugDeduct(
            @RequestParam(value = "receiptid", required = false) Integer receiptid,
            @RequestParam(value = "flag", required = false) Integer flag) {
        InventoryService inventoryService = (InventoryService) Context
                .getService(InventoryService.class);
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
                .listStoreDrugPatientDetail(receiptid);
        InventoryStoreDrugPatient inventoryStoreDrugPatient = new InventoryStoreDrugPatient();
        if (inventoryStoreDrugPatient != null && listDrugIssue != null && listDrugIssue.size() > 0) {


            InventoryStoreDrugTransaction transaction = new InventoryStoreDrugTransaction();
            transaction.setDescription("DISPENSE DRUG TO PATIENT " + DateUtils.getDDMMYYYY());
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
                /*
                int t = totalQuantity - pDetail.getQuantity();
                This is the option that was there before. It should not deduct again on dispense since it already did that on Cashier
                See modification in the line below
                */

                int t = totalQuantity;

                InventoryStoreDrugTransactionDetail inventoryStoreDrugTransactionDetail = inventoryService
                        .getStoreDrugTransactionDetailById(pDetail.getTransactionDetail().getParent().getId());

                InventoryStoreDrugTransactionDetail drugTransactionDetail = inventoryService.getStoreDrugTransactionDetailById(inventoryStoreDrugTransactionDetail.getId());

                inventoryStoreDrugTransactionDetail.setCurrentQuantity(drugTransactionDetail.getCurrentQuantity() - pDetail.getQuantity());

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
                transDetail.setFlag(FlagStates.FULLY_PROCESSED);


                BigDecimal moneyUnitPrice = pDetail.getTransactionDetail().getCostToPatient().multiply(new BigDecimal(pDetail.getQuantity()));

                transDetail.setTotalPrice(moneyUnitPrice);


                transDetail.setParent(pDetail.getTransactionDetail());
                transDetail = inventoryService
                        .saveStoreDrugTransactionDetail(transDetail);
                pDetail.setQuantity(pDetail.getQuantity());

                pDetail.setTransactionDetail(transDetail);


                // save issue to patient detail
                inventoryService.saveStoreDrugPatientDetail(pDetail);

                if (transDetail.getFlag() == FlagStates.PARTIALLY_PROCESSED) {
                    inventoryStoreDrugPatient = inventoryService.getStoreDrugPatientById(pDetail.getStoreDrugPatient().getId());
                    inventoryStoreDrugPatient.setStatuss(1);

                }


            }

            if (CollectionUtils.isNotEmpty(listDrugIssue)) {
                //TODO starts here

                PatientIdentifier pi = listDrugIssue.get(0).getStoreDrugPatient().getPatient().getPatientIdentifier();

                int patientId = pi.getPatient().getPatientId();
                Date issueDate = listDrugIssue.get(0).getStoreDrugPatient().getCreatedOn();
                Encounter encounterId = listDrugIssue.get(0).getTransactionDetail().getEncounter();

                List<OpdDrugOrder> listOfNotDispensedOrder = null;
                if (encounterId != null) {
                    listOfNotDispensedOrder = inventoryService.listOfNotDispensedOrder(patientId, issueDate, encounterId);
                }

                //TODO ends here

            }

        }
        return "success";

    }
}
