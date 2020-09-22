package org.openmrs.module.pharmacyapp.page.controller;

import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.hospitalcore.model.InventoryDrug;
import org.openmrs.module.hospitalcore.model.InventoryDrugFormulation;
import org.openmrs.module.kenyaui.annotation.AppPage;
import org.openmrs.module.pharmacyapp.PharmacyAppConstants;
import org.openmrs.module.pharmacyapp.ReferenceApplicationWebConstants.ReferenceApplicationWebConstants;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.openmrs.ui.framework.page.PageRequest;
import org.springframework.web.bind.annotation.RequestParam;

/**
 *
 */
@AppPage(PharmacyAppConstants.APP_PHARMACY)
public class ViewStockBalanceDetailPageController {
    public void get( @RequestParam(value = "drugId", required = false) Integer drugId,
                     @RequestParam(value = "formulationId", required = false) Integer formulationId,
                     @RequestParam(value = "expiry", required = false) Integer expiry,
                     UiSessionContext sessionContext,
                     PageRequest pageRequest,
                     UiUtils ui,
                     PageModel pageModel){
        pageRequest.getSession().setAttribute(ReferenceApplicationWebConstants.SESSION_ATTRIBUTE_REDIRECT_URL,ui.thisUrl());
        sessionContext.requireAuthentication();

        InventoryService inventoryService = (InventoryService) Context
                .getService(InventoryService.class);

        pageModel.addAttribute("drugId",drugId );
        pageModel.addAttribute("formulationId",formulationId );
        pageModel.addAttribute("expiry",expiry );

        InventoryDrug drug = inventoryService.getDrugById(drugId);
        InventoryDrugFormulation formulation = inventoryService.getDrugFormulationById(formulationId);

        pageModel.addAttribute("formulation",formulation);
        pageModel.addAttribute("drug",drug);

    }

}
