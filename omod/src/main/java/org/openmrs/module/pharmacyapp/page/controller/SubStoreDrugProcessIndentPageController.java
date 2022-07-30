package org.openmrs.module.pharmacyapp.page.controller;

import org.apache.commons.lang.math.NumberUtils;
import org.openmrs.Role;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.model.*;
import org.openmrs.module.hospitalcore.util.ActionValue;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.ehrinventory.model.InventoryStoreDrug;
import org.openmrs.module.ehrinventory.model.InventoryStoreDrugIndentDetail;
import org.openmrs.module.ehrinventory.util.DateUtils;
import org.openmrs.module.kenyaui.annotation.AppPage;
import org.openmrs.module.pharmacyapp.PharmacyAppConstants;
import org.openmrs.module.pharmacyapp.ReferenceApplicationWebConstants.ReferenceApplicationWebConstants;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.openmrs.ui.framework.page.PageRequest;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.util.*;
import java.util.logging.Logger;

/**
 *
 */
@AppPage(PharmacyAppConstants.APP_PHARMACY)
public class SubStoreDrugProcessIndentPageController {
    private final Logger logger = Logger.getLogger(SubStoreDrugProcessIndentPageController.class.getName());

    public String get(@RequestParam(value = "indentId", required = false) Integer indentId,
                      PageModel pageModel,
                      UiUtils ui,
                      UiSessionContext sessionContext,
                      PageRequest pageRequest
    ) {

        InventoryService inventoryService = (InventoryService) Context.getService(InventoryService.class);
        InventoryStoreDrugIndent indent = inventoryService.getStoreDrugIndentById(indentId);
        if (indent != null && indent.getSubStoreStatus() != 3 && indent.getMainStoreStatus() != 3) {
            return "redirect:" + ui.pageLink("pharmacyapp", "main");
        }
        List<InventoryStoreDrugIndentDetail> listDrugNeedProcess = inventoryService.listStoreDrugIndentDetail(indentId);

        List<SimpleObject> simpleObjects = SimpleObject.fromCollection(listDrugNeedProcess, ui, "id", "drug.id", "drug.name",
                "formulation.id", "formulation.name", "formulation.dozage", "formulation.description", "quantity", "mainStoreTransfer");
        String listDrugTPJson = SimpleObject.create("listDrugNeedProcess", simpleObjects).toJson();
        pageModel.addAttribute("listDrugNeedProcess", listDrugTPJson);
        pageModel.addAttribute("indent", indent);
        return "subStoreDrugProcessIndent";

    }

    public String post(HttpServletRequest request, PageModel model, UiUtils uiUtils) {
//        System.out.println(request.getParameter("drugIntents"));
        Map<String,Object> redirectParams = new HashMap<String, Object>();
        redirectParams.put("tabId","manage");

        InventoryService inventoryService = (InventoryService) Context.getService(InventoryService.class);
        Integer indentId = NumberUtils.toInt(request.getParameter("indentId"));
        InventoryStoreDrugIndent indent = inventoryService.getStoreDrugIndentById(indentId);
        List<InventoryStoreDrugIndentDetail> listIndentDetail = inventoryService.listStoreDrugIndentDetail(indentId);
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
            subStore = inventoryService.getStoreById(4);

        }
        List<InventoryStoreDrugTransactionDetail> refundDrugList = inventoryService.listTransactionDetail(indent.getTransaction().getId());
        if ("1".equals(request.getParameter("refuse"))) {
            if (indent != null) {
                indent.setMainStoreStatus(ActionValue.INDENT_MAINSTORE[3]);
                indent.setSubStoreStatus(ActionValue.INDENT_SUBSTORE[3]);
                inventoryService.saveStoreDrugIndent(indent);

                for (InventoryStoreDrugIndentDetail t : listIndentDetail) {
                    InventoryStoreDrug storeDrug = inventoryService.getStoreDrug(4, t.getDrug().getId(), t.getFormulation().getId());
                    if (storeDrug != null) {
                        storeDrug.setStatusIndent(0);
                        inventoryService.saveStoreDrug(storeDrug);
                    }

                }
            }


            if (refundDrugList != null && refundDrugList.size() > 0) {
                InventoryStoreDrugTransaction transaction = new InventoryStoreDrugTransaction();
                transaction.setDescription("REFUND BC SUBSTORE REFUSE " + DateUtils.getDDMMYYYY());
                transaction.setTypeTransaction(ActionValue.TRANSACTION[0]);
                transaction.setCreatedBy("System");
                transaction.setCreatedOn(new Date());
                transaction = inventoryService.saveStoreDrugTransaction(transaction);


                for (InventoryStoreDrugTransactionDetail refund : refundDrugList) {

                    Date date = new Date();
                    Integer sumTotalQuantity = 0; //just for testing. Remember to remove it
                    InventoryStoreDrugTransactionDetail transDetail = new InventoryStoreDrugTransactionDetail();
                    transDetail.setTransaction(transaction);
                    transDetail.setDrug(refund.getDrug());
                    transDetail.setReorderPoint(refund.getDrug().getReorderQty());
                    transDetail.setAttribute(refund.getDrug().getAttributeName());
                    transDetail.setDateExpiry(refund.getDateExpiry());
                    transDetail.setBatchNo(refund.getBatchNo());
                    transDetail.setCompanyName(refund.getCompanyName());
                    transDetail.setCreatedOn(new Date());
                    transDetail.setDateManufacture(refund.getDateManufacture());
                    transDetail.setFormulation(refund.getFormulation());
                    transDetail.setUnitPrice(refund.getUnitPrice());
                    transDetail.setVAT(refund.getVAT());
                    transDetail.setCostToPatient(refund.getCostToPatient());
                    transDetail.setParent(refund);
                    transDetail.setReceiptDate(date);
                    transDetail.setQuantity(refund.getIssueQuantity());
                    BigDecimal moneyUnitPrice = refund.getCostToPatient().multiply(new BigDecimal(refund.getIssueQuantity()));
                    //		moneyUnitPrice = moneyUnitPrice.add(moneyUnitPrice.multiply(refund.getVAT().divide(new BigDecimal(100))));
                    transDetail.setTotalPrice(moneyUnitPrice);

                    transDetail.setCurrentQuantity(refund.getIssueQuantity());
                    transDetail.setIssueQuantity(0);
                    transDetail.setOpeningBalance(sumTotalQuantity);
                    transDetail.setClosingBalance(sumTotalQuantity + refund.getIssueQuantity());
                    inventoryService.saveStoreDrugTransactionDetail(transDetail);
                    try {
                        Thread.sleep(2000);
                    } catch (InterruptedException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }

                }
            }

            return "redirect:" + uiUtils.pageLink("pharmacyapp", "main", redirectParams);
        }
        //save here
        InventoryStoreDrugTransaction transaction = new InventoryStoreDrugTransaction();
        transaction.setStore(subStore);
        transaction.setDescription("RECEIPT " + DateUtils.getDDMMYYYY());
        transaction.setTypeTransaction(ActionValue.TRANSACTION[0]);
        transaction.setCreatedBy("System");
        transaction.setCreatedOn(new Date());
        transaction = inventoryService.saveStoreDrugTransaction(transaction);


        for (InventoryStoreDrugTransactionDetail refund : refundDrugList) {

            Date date = new Date();
            Integer sumTotalQuantity = inventoryService.sumCurrentQuantityDrugOfStore(4, refund.getDrug().getId(), refund.getFormulation().getId());
            InventoryStoreDrugTransactionDetail transDetail = new InventoryStoreDrugTransactionDetail();
            transDetail.setTransaction(transaction);
            transDetail.setDrug(refund.getDrug());

            transDetail.setAttribute(refund.getAttribute());
            transDetail.setReorderPoint(refund.getReorderPoint());

            transDetail.setDateExpiry(refund.getDateExpiry());
            transDetail.setBatchNo(refund.getBatchNo());
            transDetail.setCompanyName(refund.getCompanyName());
            transDetail.setCreatedOn(date);
            transDetail.setDateManufacture(refund.getDateManufacture());
            transDetail.setFormulation(refund.getFormulation());
            transDetail.setUnitPrice(refund.getUnitPrice());
            transDetail.setVAT(refund.getVAT());
            transDetail.setCostToPatient(refund.getCostToPatient());
            transDetail.setParent(refund);
            transDetail.setReceiptDate(date);
            BigDecimal moneyUnitPrice = refund.getCostToPatient().multiply(new BigDecimal(refund.getIssueQuantity()));
            transDetail.setTotalPrice(moneyUnitPrice);

            transDetail.setQuantity(refund.getIssueQuantity());
            transDetail.setCurrentQuantity(refund.getIssueQuantity());
            transDetail.setIssueQuantity(0);
            transDetail.setOpeningBalance(sumTotalQuantity);
            transDetail.setClosingBalance(sumTotalQuantity + refund.getIssueQuantity());
            inventoryService.saveStoreDrugTransactionDetail(transDetail);
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

        }
        //indent.setMainStoreStatus(ActionValue.INDENT_MAINSTORE[2]);
        indent.setSubStoreStatus(ActionValue.INDENT_SUBSTORE[4]);
        inventoryService.saveStoreDrugIndent(indent);
        return "redirect:" + uiUtils.pageLink("pharmacyapp", "main", redirectParams);
    }

}
