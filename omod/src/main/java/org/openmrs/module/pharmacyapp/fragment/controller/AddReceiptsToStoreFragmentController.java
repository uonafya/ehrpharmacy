package org.openmrs.module.pharmacyapp.fragment.controller;

import org.openmrs.Concept;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.InventoryCommonService;
import org.openmrs.module.hospitalcore.model.InventoryDrug;
import org.openmrs.module.hospitalcore.model.InventoryDrugFormulation;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.List;

/**
 * @author Stanslaus Odhiambo
 *         Created on 4/7/2016.
 */
public class AddReceiptsToStoreFragmentController {

    public List<SimpleObject> fetchDrugNames(@RequestParam(value = "categoryId") int categoryId, UiUtils uiUtils) {
        List<SimpleObject> drugNames = null;
        InventoryService inventoryService = (InventoryService) Context.getService(InventoryService.class);
        if (categoryId > 0) {
            List<InventoryDrug> drugs = inventoryService.findDrug(categoryId, null);
            drugNames = SimpleObject.fromCollection(drugs, uiUtils, "id", "name");
        }
        return drugNames;
    }

    public List<SimpleObject> getFormulationByDrugName(@RequestParam(value = "drugName") String drugName, UiUtils ui) {

        InventoryCommonService inventoryCommonService = (InventoryCommonService) Context.getService(InventoryCommonService.class);
        InventoryDrug drug = inventoryCommonService.getDrugByName(drugName);

        List<SimpleObject> formulationsList = null;

        if (drug != null) {
            List<InventoryDrugFormulation> formulations = new ArrayList<InventoryDrugFormulation>(drug.getFormulations());
            formulationsList = SimpleObject.fromCollection(formulations, ui, "id", "name", "dozage");
        }

        return formulationsList;
    }
    public List<SimpleObject> getFrequencies(UiUtils uiUtils){
        InventoryCommonService inventoryCommonService = Context
                .getService(InventoryCommonService.class);
        List<Concept> drugFrequencyConcept = inventoryCommonService
                .getDrugFrequency();
        if(drugFrequencyConcept != null){
            List<SimpleObject> mydrugFrequencyObj = SimpleObject.fromCollection(drugFrequencyConcept,uiUtils, "id", "name");
            return mydrugFrequencyObj;
        }
        else{
            return null;
        }
    }


    public List<SimpleObject> fetchDrugListByName(@RequestParam(value = "searchPhrase") String searchPhrase, UiUtils ui) {
        InventoryService inventoryService = (InventoryService) Context.getService(InventoryService.class);
        List<InventoryDrug> drugs = inventoryService.findDrug(null, searchPhrase);
        return SimpleObject.fromCollection(drugs,ui,"id","name","category.id");
    }


}
