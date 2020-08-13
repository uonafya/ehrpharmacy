package org.openmrs.module.pharmacyapp.page.controller;

import org.apache.commons.collections.CollectionUtils;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.ehrinventory.model.InventoryStoreDrugAccountDetail;

import org.openmrs.module.pharmacyapp.ReferenceApplicationWebConstants.ReferenceApplicationWebConstants;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.openmrs.ui.framework.page.PageRequest;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Date;
import java.util.List;


/**
 * Created by USER on 4/6/2016.
 */
public class IssueDrugAccountDetailPageController {

    public void get (
            @RequestParam(value = "issueId", required = false) Integer issueId,
            UiSessionContext sessionContext,
            PageRequest pageRequest,
            UiUtils ui,
            PageModel model) {

        pageRequest.getSession().setAttribute(ReferenceApplicationWebConstants.SESSION_ATTRIBUTE_REDIRECT_URL,ui.thisUrl());
        sessionContext.requireAuthentication();

        InventoryService inventoryService = (InventoryService) Context
                .getService(InventoryService.class);
        List<InventoryStoreDrugAccountDetail> listDrugIssue = inventoryService
                .listStoreDrugAccountDetail(issueId);
        model.addAttribute("listDrugIssue", listDrugIssue);

        Date issueAccountDate = new Date();
        String issueAccountName = "UNKNOWN";
        String pharmacist = "Unknown";


        if (CollectionUtils.isNotEmpty(listDrugIssue)) {
            issueAccountDate = listDrugIssue.get(0).getDrugAccount().getCreatedOn();
            issueAccountName=listDrugIssue.get(0).getDrugAccount().getName();
            pharmacist = listDrugIssue.get(0).getDrugAccount().getCreatedBy();
        }

        model.addAttribute("issueAccountDate", issueAccountDate);
        model.addAttribute("issueAccountName", issueAccountName);
        model.addAttribute("pharmacist", pharmacist);

        model.addAttribute("userLocation", Context.getAdministrationService().getGlobalProperty("hospital.location_user"));

    }
}
