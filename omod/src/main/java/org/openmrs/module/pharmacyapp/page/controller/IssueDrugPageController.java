package org.openmrs.module.pharmacyapp.page.controller;

import org.openmrs.*;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.InventoryCommonService;
import org.openmrs.module.hospitalcore.model.InventoryDrug;
import org.openmrs.module.hospitalcore.model.InventoryDrugCategory;
import org.openmrs.module.hospitalcore.model.InventoryStore;
import org.openmrs.module.hospitalcore.model.InventoryStoreRoleRelation;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.kenyaui.annotation.AppPage;
import org.openmrs.module.pharmacyapp.PharmacyAppConstants;
import org.openmrs.module.pharmacyapp.ReferenceApplicationWebConstants.ReferenceApplicationWebConstants;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.openmrs.ui.framework.page.PageRequest;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@AppPage(PharmacyAppConstants.APP_PHARMACY)
public class IssueDrugPageController {
    public void controller() {
    }

    public void get(@RequestParam(value = "categoryId", required = false) Integer categoryId,
                    @RequestParam(value = "patientId", required = false) Integer patientId,
                    UiSessionContext sessionContext,
                    PageRequest pageRequest,
                    UiUtils ui,
                    PageModel model) {
        pageRequest.getSession().setAttribute(ReferenceApplicationWebConstants.SESSION_ATTRIBUTE_REDIRECT_URL,ui.thisUrl());
        sessionContext.requireAuthentication();

        InventoryService inventoryService = (InventoryService) Context.getService(InventoryService.class);
        InventoryCommonService inventoryCommonService = Context.getService(InventoryCommonService.class);
        List<Concept> drugFrequencyConcept = inventoryCommonService.getDrugFrequency();
        Patient patient = Context.getPatientService().getPatient(patientId);
        HospitalCoreService hcs = Context.getService(HospitalCoreService.class);
        model.addAttribute("drugFrequencyList", drugFrequencyConcept);
        List<InventoryDrugCategory> listCategory = inventoryService.findDrugCategory("");
        model.addAttribute("listCategory", listCategory);
        model.addAttribute("categoryId", categoryId);
        if (categoryId != null && categoryId > 0) {
            List<InventoryDrug> drugs = inventoryService.findDrug(categoryId, null);
            model.addAttribute("drugs", drugs);

        } else {
            List<InventoryDrug> drugs = inventoryService.getAllDrug();
            model.addAttribute("drugs", drugs);
        }

        model.addAttribute("date", new Date());
        int userId = Context.getAuthenticatedUser().getId();
        // InventoryStore store = inventoryService.getStoreByCollectionRole(new ArrayList<Role>(Context.getAuthenticatedUser().getAllRoles()));
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
            store = inventoryService.getStoreById(srl.getStoreid());

        }
        model.addAttribute("store", store);
        model.addAttribute("date", new Date());
        model.addAttribute("patientId", patientId);
        model.addAttribute("identifier", patient.getPatientIdentifier());
        model.addAttribute("category", patient.getAttribute(14));
        model.addAttribute("age", patient.getAge());
        model.addAttribute("birthdate", patient.getBirthdate());
        model.addAttribute("lastVisit", hcs.getLastVisitTime(patient));
        model.addAttribute("date", new Date());
        String patientType = hcs.getPatientType(patient);
        model.addAttribute("patientType", patientType);

        if (patient.getGender().equals("M")) {
            model.addAttribute("gender", "Male");
        } else {
            model.addAttribute("gender", "Female");
        }

        model.addAttribute("familyName", patient.getFamilyName());
        model.addAttribute("givenName", patient.getGivenName());

        if (patient.getMiddleName() != null) {
            model.addAttribute("middleName", patient.getMiddleName());
        } else {
            model.addAttribute("middleName", "");
        }

        List<PersonAttribute> pas = hcs.getPersonAttributes(patient.getId());

        for (PersonAttribute pa : pas) {
            PersonAttributeType attributeType = pa.getAttributeType();
            PersonAttributeType personAttributePCT = hcs.getPersonAttributeTypeByName("Paying Category Type");
            PersonAttributeType personAttributeNPCT = hcs.getPersonAttributeTypeByName("Non-Paying Category Type");
            PersonAttributeType personAttributeSSCT = hcs.getPersonAttributeTypeByName("Special Scheme Category Type");
            if (attributeType.getPersonAttributeTypeId() == personAttributePCT.getPersonAttributeTypeId()) {
                model.addAttribute("paymentCategory", "PAYING");
                model.addAttribute("paymentSubCategory", pa.getValue());
            } else if (attributeType.getPersonAttributeTypeId() == personAttributeNPCT.getPersonAttributeTypeId()) {
                model.addAttribute("paymentCategory", "NON-PAYING");
                model.addAttribute("paymentSubCategory", pa.getValue());
            } else if (attributeType.getPersonAttributeTypeId() == personAttributeSSCT.getPersonAttributeTypeId()) {
                model.addAttribute("paymentCategory", "SPECIAL SCHEMES");
                model.addAttribute("paymentSubCategory", pa.getValue());
            }
        }

        model.addAttribute("pharmacist", Context.getAuthenticatedUser().getGivenName());
        model.addAttribute("userLocation", Context.getAdministrationService().getGlobalProperty("hospital.location_user"));
    }


}
