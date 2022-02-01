package org.openmrs.module.pharmacyapp.page.controller;

import org.openmrs.Role;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.model.InventoryDrug;
import org.openmrs.module.hospitalcore.model.InventoryDrugCategory;
import org.openmrs.module.hospitalcore.model.InventoryStore;
import org.openmrs.module.hospitalcore.model.InventoryStoreRoleRelation;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.ehrinventory.model.InventoryStoreDrugIndentDetail;
import org.openmrs.module.kenyaui.annotation.AppPage;
import org.openmrs.module.pharmacyapp.PharmacyAppConstants;
import org.openmrs.module.pharmacyapp.StoreSingleton;
import org.openmrs.module.pharmacyapp.ReferenceApplicationWebConstants.ReferenceApplicationWebConstants;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.openmrs.ui.framework.page.PageRequest;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 *
 */
@AppPage(PharmacyAppConstants.APP_PHARMACY)
public class SubStoreIndentDrugPageController {

    public void get(@RequestParam(value = "categoryId", required = false) Integer categoryId,
                    UiSessionContext sessionContext,
                    PageRequest pageRequest,
                    UiUtils ui,
                    PageModel model) {

        InventoryService inventoryService = (InventoryService) Context.getService(InventoryService.class);
        List<InventoryDrugCategory> listCategory = inventoryService.findDrugCategory("");
        model.addAttribute("listCategory", listCategory);
        model.addAttribute("categoryId", categoryId);
        if(categoryId != null && categoryId > 0){
            List<InventoryDrug> drugs = inventoryService.findDrug(categoryId, null);
            model.addAttribute("drugs",drugs);

        }
        // InventoryStore store = inventoryService.getStoreByCollectionRole(new ArrayList<Role>(Context.getAuthenticatedUser().getAllRoles()));
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
            store = inventoryService.getStoreById(srl.getStoreid());

        }
        model.addAttribute("store",store);
        model.addAttribute("date",new Date());
        int userId = Context.getAuthenticatedUser().getId();
        String fowardParam = "subStoreIndentDrug_"+userId;
        List<InventoryStoreDrugIndentDetail> list = (List<InventoryStoreDrugIndentDetail> ) StoreSingleton.getInstance().getHash().get(fowardParam);
        model.addAttribute("listIndent", list);

    }
}
