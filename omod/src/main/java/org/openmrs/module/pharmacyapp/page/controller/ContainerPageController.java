package org.openmrs.module.pharmacyapp.page.controller;

import org.openmrs.Role;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.model.*;
import org.openmrs.module.hospitalcore.util.Action;
import org.openmrs.module.hospitalcore.util.ActionValue;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.api.context.Context;
import org.openmrs.module.kenyaui.annotation.AppPage;
import org.openmrs.module.pharmacyapp.PharmacyAppConstants;
import org.openmrs.module.pharmacyapp.ReferenceApplicationWebConstants.ReferenceApplicationWebConstants;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.openmrs.ui.framework.page.PageRequest;
import org.springframework.web.bind.annotation.RequestParam;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 *
 */
@AppPage(PharmacyAppConstants.APP_PHARMACY)
public class ContainerPageController {
    public String get(@RequestParam(value = "rel", required = true) String rel,
                      @RequestParam(value = "date", required = false) String date,
                      @RequestParam(value = "tabId", required = false) String tabId,
                      UiSessionContext sessionContext,
                      PageRequest pageRequest,
                      UiUtils ui,
                      PageModel model) {


        List<Action> listDrugAttribute = ActionValue.getListDrugAttribute();
        model.addAttribute("listDrugAttribute", listDrugAttribute);
        List<InventoryStoreDrugTransactionDetail> listReceiptDrugReturn = null;
        InventoryService inventoryService = (InventoryService) Context
                .getService(InventoryService.class);

        List<InventoryDrugCategory> listCategory = inventoryService.listDrugCategory("", 0, 0);
        model.addAttribute("listCategory", listCategory);

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
        String dateStr = "";
        List<Action> listSubStoreStatus = new ArrayList<Action>();
        if (srl != null) {
            store = inventoryService.getStoreById(srl.getStoreid());
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
            dateStr = sdf.format(new Date());

            listSubStoreStatus = ActionValue.getListIndentSubStore();

        }

            model.addAttribute("date", date);
            model.addAttribute("currentDate", dateStr);
            model.addAttribute("currentTime", new Date());
            model.addAttribute("listSubStoreStatus", listSubStoreStatus);
            model.addAttribute("tabId", tabId);

            if (rel.equals("patients-queue")) {
                model.addAttribute("fragment", "queue");
                model.addAttribute("title", "Patient Queue");
                model.addAttribute("header", "PATIENT QUEUE LIST");
            } else if (rel.equals("dispense-drugs")) {
                model.addAttribute("fragment", "subStoreListDispense");
                model.addAttribute("title", "Dispense Drugs");
                model.addAttribute("header", "DISPENSE DRUGS TO PATIENT");
            } else if (rel.equals("issue-to-patient")) {
                model.addAttribute("fragment", "issuePatientDrug");
                model.addAttribute("title", "Issue Drugs to Patient");
                model.addAttribute("header", "ISSUE DRUGS TO PATIENT");
            } else if (rel.equals("issue-to-account")) {
                model.addAttribute("fragment", "issueDrugAccountList");
                model.addAttribute("title", "Issue Drugs to Account");
                model.addAttribute("header", "ISSUE DRUGS TO ACCOUNT");
            } else if (rel.equals("current-stock")) {
                model.addAttribute("fragment", "viewDrugStock");
                model.addAttribute("title", "View Drug Stock");
                model.addAttribute("header", "CURRENT DRUGS STOCK");
            } else if (rel.equals("expired-stock")) {
                model.addAttribute("fragment", "viewExpiredDrugs");
                model.addAttribute("title", "View Expired Stock");
                model.addAttribute("header", "EXPIRED DRUGS STOCK");
            } else if (rel.equals("indent-drugs")) {
                model.addAttribute("fragment", "indentDrugList");
                model.addAttribute("title", "Order Drugs");
                model.addAttribute("header", "ORDER DRUGS");
            } else {
                model.addAttribute("fragment", "404");
                model.addAttribute("title", "404");
                model.addAttribute("header", "404");
            }

        return null;
        }

    }

