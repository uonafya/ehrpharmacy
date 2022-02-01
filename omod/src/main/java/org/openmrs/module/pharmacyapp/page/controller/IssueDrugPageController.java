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
        model.addAttribute("category", patient.getAttribute(Context.getPersonService().getPersonAttributeTypeByUuid("09cd268a-f0f5-11ea-99a8-b3467ddbf779")));
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
        String paymentCategory = "";
        String paymentSubCategory = "";
        for (PersonAttribute pa : pas) {
            PersonAttributeType attributeType = pa.getAttributeType();
            PersonAttributeType personAttributePCT = hcs.getPersonAttributeTypeByName("Paying Category Type");
            PersonAttributeType personAttributeNPCT = hcs.getPersonAttributeTypeByName("Non-Paying Category Type");
            PersonAttributeType personAttributeSSCT = hcs.getPersonAttributeTypeByName("Special Scheme Category Type");


            if (attributeType.getPersonAttributeTypeId().equals(personAttributePCT.getPersonAttributeTypeId())) {
                paymentCategory = "PAYING";
                paymentSubCategory = pa.getValue();
            } else if (attributeType.getPersonAttributeTypeId().equals(personAttributeNPCT.getPersonAttributeTypeId())) {
                paymentCategory = "NON-PAYING";
                paymentSubCategory = pa.getValue();
            } else if (attributeType.getPersonAttributeTypeId().equals(personAttributeSSCT.getPersonAttributeTypeId())) {
                paymentCategory = "SPECIAL SCHEMES";
                paymentSubCategory = pa.getValue();
            }
        }

        model.addAttribute("pharmacist", Context.getAuthenticatedUser().getGivenName());
        model.addAttribute("userLocation", Context.getAdministrationService().getGlobalProperty("hospital.location_user"));
        model.addAttribute("paymentCategory", paymentCategory);
        model.addAttribute("paymentSubCategory", paymentSubCategory);
    }


}
