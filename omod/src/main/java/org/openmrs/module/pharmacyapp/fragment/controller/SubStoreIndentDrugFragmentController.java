package org.openmrs.module.pharmacyapp.fragment.controller;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.openmrs.Role;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.*;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.ehrinventory.model.InventoryStoreDrugIndentDetail;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class SubStoreIndentDrugFragmentController {

    public String saveIndentSlip(HttpServletRequest request) {
        String drugOrderString = request.getParameter("drugOrder");
        String indentString = request.getParameter("indentName");
        List<String> errors = new ArrayList<String>();
        InventoryDrug drug = null;
        int drugIdMain = -1;

        JSONArray indentArray = new JSONArray(indentString);
        JSONObject indentObject = indentArray.getJSONObject(0);
        String indentName = indentObject.getString("indentName");
        int mainStoreId = Integer.parseInt(indentObject.getString("mainstore"));

        InventoryService inventoryService = (InventoryService) Context.getService(InventoryService.class);
        Date date = new Date();
        int userId = Context.getAuthenticatedUser().getId();
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
            store = inventoryService.getStoreById(4);

        }
        InventoryStore mainStore = inventoryService.getStoreById(4);
        InventoryStoreDrugIndent indent = new InventoryStoreDrugIndent();
        indent.setName(indentName);
        indent.setCreatedOn(date);
        indent.setStore(store);
        indent.setMainStore(mainStore);

        if (!StringUtils.isBlank(request.getParameter("send"))) {
            indent.setMainStoreStatus(1);
            indent.setSubStoreStatus(2);
        } else {
            indent.setMainStoreStatus(0);
            indent.setSubStoreStatus(1);
        }
//        String fowardParam = "subStoreIndentDrug_"+userId;
//        List<InventoryStoreDrugIndentDetail> list = (List<InventoryStoreDrugIndentDetail> ) StoreSingleton.getInstance().getHash().get(fowardParam);
//        if(list != null && list.size() > 0){
//            indent = inventoryService.saveStoreDrugIndent(indent);
//            for(int i=0;i< list.size();i++){
//                InventoryStoreDrugIndentDetail indentDetail = list.get(i);
//                indentDetail.setCreatedOn(date);
//                indentDetail.setIndent(indent);
//                inventoryService.saveStoreDrugIndentDetail(indentDetail);
//            }
//            StoreSingleton.getInstance().getHash().remove(fowardParam);
//            return "success";
//        }else{
//            return "Sorry don't have any indents to save";
//        }

        JSONArray drugArray = new JSONArray(drugOrderString);
        List<InventoryStoreDrugIndentDetail> list = new ArrayList<InventoryStoreDrugIndentDetail>();
//        loop over the incoming items
        for (int i = 0; i < drugArray.length(); i++) {

            JSONObject incomingItem = drugArray.getJSONObject(i);
            System.out.println(incomingItem);
            String drugCategoryId = incomingItem.getString("drugCategoryId");
            String quantity = incomingItem.getString("quantity");
            String drugId = incomingItem.getString("drugId");
            String drugFormulationId = incomingItem.getString("drugFormulationId");
            if (StringUtils.isNotBlank(drugId)) {
                drug = inventoryService.getDrugById(Integer.parseInt(drugId));
            }
            if (drug == null) {
                errors.add("Drug is Required!");

            } else {
                drugIdMain = drug.getId();
            }
            int formulation = Integer.parseInt(drugFormulationId);

            InventoryDrugFormulation formulationO = inventoryService.getDrugFormulationById(formulation);
            if (formulationO == null) {
                errors.add("Formulation is Required.");
            }
            if (formulationO != null && drug != null && !drug.getFormulations().contains(formulationO)) {
                errors.add("Formulation is not correct.");
            }

            if (CollectionUtils.isNotEmpty(errors)) {
                return "error";
            }


            InventoryStoreDrugIndentDetail indentDetail = new InventoryStoreDrugIndentDetail();
            indentDetail.setDrug(drug);
            indentDetail.setFormulation(inventoryService.getDrugFormulationById(formulation));
            indentDetail.setQuantity(Integer.parseInt(quantity));
            list.add(indentDetail);

        }

        if(list != null && list.size() > 0){
            indent = inventoryService.saveStoreDrugIndent(indent);
            for(int i=0;i< list.size();i++){
                InventoryStoreDrugIndentDetail indentDetail = list.get(i);
                indentDetail.setCreatedOn(date);
                indentDetail.setIndent(indent);
                inventoryService.saveStoreDrugIndentDetail(indentDetail);
            }
        }
        return "success";
    }


}
