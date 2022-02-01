package org.openmrs.module.pharmacyapp.page.controller;

import org.openmrs.Role;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.model.InventoryDrug;
import org.openmrs.module.hospitalcore.model.InventoryStore;
import org.openmrs.module.hospitalcore.model.InventoryStoreDrugTransactionDetail;
import org.openmrs.module.hospitalcore.model.InventoryStoreRoleRelation;
import org.openmrs.module.hospitalcore.util.Action;
import org.openmrs.module.hospitalcore.util.ActionValue;
import org.openmrs.module.ehrinventory.InventoryService;
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
public class DashboardPageController {
    public String get(PageModel model,
                      UiSessionContext sessionContext,
                      PageRequest pageRequest,
                      UiUtils ui,
                      @RequestParam(value="tabId",required=false)  String tabId) {


        List<InventoryStoreDrugTransactionDetail> listReceiptDrugReturn = null;
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
        String dateStr = "";
        List<Action> listSubStoreStatus = new ArrayList<Action>();
        if (srl != null) {
            store = inventoryService.getStoreById(srl.getStoreid());
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
            dateStr = sdf.format(new Date());
            listSubStoreStatus = ActionValue.getListIndentSubStore();

        }
        /*else{
            return "redirect: index.htm";
        }*/
        model.addAttribute("currentDate", dateStr);
        model.addAttribute("currentTime", new Date());
        model.addAttribute("listSubStoreStatus", listSubStoreStatus);
        model.addAttribute("tabId", tabId);
        return null;
    }
}