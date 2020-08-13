package org.openmrs.module.pharmacyapp.fragment.controller;

import org.apache.commons.lang.StringUtils;
import org.openmrs.Role;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.InventoryDrugCategory;
import org.openmrs.module.hospitalcore.model.InventoryStore;
import org.openmrs.module.hospitalcore.model.InventoryStoreDrugTransactionDetail;
import org.openmrs.module.hospitalcore.model.InventoryStoreRoleRelation;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.ehrinventory.util.PagingUtil;
import org.openmrs.module.ehrinventory.util.RequestUtil;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by USER on 3/30/2016.
 */
public class ViewExpiredDrugsFragmentController {
    public void controller() {

    }

    public List<SimpleObject> viewStockBalanceExpired(
            @RequestParam(value = "pageSize", required = false) Integer pageSize,
            @RequestParam(value = "currentPage", required = false) Integer currentPage,
            @RequestParam(value = "categoryId", required = false) Integer categoryId,
            @RequestParam(value = "drugName", required = false) String drugName,
            @RequestParam(value = "attribute", required = false) String attribute,
            @RequestParam(value = "fromDate", required = false) String fromDate,
            @RequestParam(value = "toDate", required = false) String toDate,
            UiUtils uiUtils, HttpServletRequest request) {
        InventoryService inventoryService = Context
                .getService(InventoryService.class);
        List<Role> role = new ArrayList<Role>(Context.getAuthenticatedUser().getAllRoles());
        List<InventoryStoreDrugTransactionDetail> stockBalances = new ArrayList<InventoryStoreDrugTransactionDetail>();
        InventoryStoreRoleRelation storeRoleRelation = null;

        Role roleUser = null;
        for (Role rolePerson : role) {
            if (inventoryService.getStoreRoleByName(rolePerson.toString()) != null) {
                storeRoleRelation = inventoryService.getStoreRoleByName(rolePerson.toString());
                roleUser = rolePerson;
            }
        }
        InventoryStore store = null;
        if (storeRoleRelation != null) {
            store = inventoryService.getStoreById(storeRoleRelation.getStoreid());

        }

        // ghanshyam 7-august-2013 code review bug
        if (store != null) {
            int total = inventoryService.countViewStockBalance(store.getId(),
                    categoryId, drugName, attribute, fromDate, toDate, true);
            String temp = "";
            if (categoryId != null) {
                temp = "?categoryId=" + categoryId;
            }

            if (drugName != null) {
                if (StringUtils.isBlank(temp)) {
                    temp = "?drugName=" + drugName;
                } else {
                    temp += "&drugName=" + drugName;
                }
            }
            //NEW
            if (attribute != null) {
                if (StringUtils.isBlank(temp)) {
                    temp = "?attribute=" + attribute;
                } else {
                    temp += "&attribute=" + attribute;
                }
            }

            if (fromDate != null) {
                if (StringUtils.isBlank(temp)) {
                    temp = "?fromDate=" + fromDate;
                } else {
                    temp += "&fromDate=" + fromDate;
                }
            }
            if (toDate != null) {
                if (StringUtils.isBlank(temp)) {
                    temp = "?toDate=" + toDate;
                } else {
                    temp += "&toDate=" + toDate;
                }
            }

            PagingUtil pagingUtil = new PagingUtil(
                    RequestUtil.getCurrentLink(request) + temp, pageSize,
                    currentPage, total);
            stockBalances = inventoryService
                    .listViewStockBalance(store.getId(), categoryId, drugName, attribute,
                            fromDate, toDate, true, pagingUtil.getStartPos(),
                            pagingUtil.getPageSize());
            List<InventoryDrugCategory> listCategory = inventoryService
                    .listDrugCategory("", 0, 0);
            if (stockBalances != null) {
                Collections.sort(stockBalances);
            }else{
                stockBalances = new ArrayList<InventoryStoreDrugTransactionDetail>();
            }

        }
        return SimpleObject.fromCollection(stockBalances, uiUtils, "drug.id", "drug.name", "drug.category.name", "formulation.id", "formulation.name", "formulation.dozage", "currentQuantity", "reorderPoint");

    }
}



