package org.openmrs.module.pharmacyapp.page.controller;

import org.openmrs.Patient;
import org.openmrs.api.PatientService;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.model.OpdDrugOrder;
import org.openmrs.module.hospitalcore.model.PatientSearch;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.kenyaui.annotation.AppPage;
import org.openmrs.module.pharmacyapp.PharmacyAppConstants;
import org.openmrs.module.pharmacyapp.ReferenceApplicationWebConstants.ReferenceApplicationWebConstants;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.openmrs.ui.framework.page.PageRequest;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestParam;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 *
 */
@AppPage(PharmacyAppConstants.APP_PHARMACY)
public class ListOfOrderPageController {
    public void get(PageModel pageModel,
                    UiSessionContext sessionContext,
                    PageRequest pageRequest,
                    UiUtils ui,
                    @RequestParam("patientId") Patient patient,
                    @RequestParam(value = "date", required = false) String dateStr) {

        pageRequest.getSession().setAttribute(ReferenceApplicationWebConstants.SESSION_ATTRIBUTE_REDIRECT_URL,ui.thisUrl());
        sessionContext.requireAuthentication();

        InventoryService inventoryService = Context.getService(InventoryService.class);
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        Date date = null;
        try {
            date = sdf.parse(dateStr);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        List<OpdDrugOrder> listOfOrders = inventoryService.listOfOrder(patient.getPatientId(),date);
        HospitalCoreService hospitalCoreService = Context.getService(HospitalCoreService.class);
        PatientSearch patientSearch = hospitalCoreService.getPatientByPatientId(patient.getPatientId());

        String patientType = hospitalCoreService.getPatientType(patient);

        pageModel.addAttribute("patientType", patientType);
        pageModel.addAttribute("patientSearch", patientSearch);
        pageModel.addAttribute("listOfOrders", listOfOrders);
        pageModel.addAttribute("previousVisit",hospitalCoreService.getLastVisitTime(patient));
        pageModel.addAttribute("patientCategory", patient.getAttribute(Context.getPersonService().getPersonAttributeTypeByUuid("09cd268a-f0f5-11ea-99a8-b3467ddbf779")));
        //model.addAttribute("serviceOrderSize", serviceOrderList.size());
        pageModel.addAttribute("patientId", patient.getPatientId());
        pageModel.addAttribute("date", dateStr);

    }
}
