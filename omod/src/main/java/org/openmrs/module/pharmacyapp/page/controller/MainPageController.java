package org.openmrs.module.pharmacyapp.page.controller;


import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.kenyaui.annotation.AppPage;
import org.openmrs.module.pharmacyapp.PharmacyAppConstants;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.openmrs.ui.framework.page.PageRequest;

/**
 * .
 */
@AppPage(PharmacyAppConstants.APP_PHARMACY)
public class MainPageController {
    public String get(PageModel model,
                      UiSessionContext sessionContext,
                      PageRequest pageRequest,
                      UiUtils ui) {
        return "redirect:" + ui.pageLink("pharmacyapp","dashboard");
    }
}

