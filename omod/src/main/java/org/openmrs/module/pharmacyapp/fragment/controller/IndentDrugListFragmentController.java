package org.openmrs.module.pharmacyapp.fragment.controller;

import org.apache.commons.lang.StringUtils;
import org.openmrs.Role;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.InventoryStore;
import org.openmrs.module.hospitalcore.model.InventoryStoreDrugIndent;
import org.openmrs.module.hospitalcore.model.InventoryStoreRoleRelation;
import org.openmrs.module.hospitalcore.util.Action;
import org.openmrs.module.hospitalcore.util.ActionValue;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.ehrinventory.util.PagingUtil;
import org.openmrs.module.ehrinventory.util.RequestUtil;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by ngarivictor on 3/22/2016.
 */
public class IndentDrugListFragmentController {
    public void controller() {

    }

    public List<SimpleObject> showList(
            @RequestParam(value = "statusId", required = false) Integer statusId,
            @RequestParam(value = "indentName", required = false) String indentName,
            @RequestParam(value = "fromDate", required = false) String fromDate,
            @RequestParam(value = "toDate", required = false) String toDate,
            @RequestParam(value = "pageSize", required = false) Integer pageSize,
            @RequestParam(value = "currentPage", required = false) Integer currentPage,
            UiUtils uiUtils,
            HttpServletRequest request
    ) {
        InventoryService inventoryService = Context.getService(InventoryService.class);

        List<Role> role = new ArrayList<Role>(Context.getAuthenticatedUser().getAllRoles());

        InventoryStoreRoleRelation storeRoleRelation = null;
        Role rolePerson = null;
        for (Role roleUser : role) {
            if (inventoryService.getStoreRoleByName(roleUser.toString()) != null) {
                storeRoleRelation = inventoryService.getStoreRoleByName(roleUser.toString());
                rolePerson = roleUser;
            }
        }
        InventoryStore subStore = null;
        if (storeRoleRelation != null) {
            subStore = inventoryService.getStoreById(storeRoleRelation.getStoreid());

        }
        int total = inventoryService.countSubStoreIndent(subStore.getId(), indentName, statusId, fromDate, toDate);

        String temp = "";
        if (!StringUtils.isBlank(indentName)) {
            temp = "?indentName=" + indentName;
        }

        if (statusId != null) {
            if (StringUtils.isBlank(temp)) {
                temp = "?statusId=" + statusId;
            } else {
                temp += "&statusId=" + statusId;
            }
        }
        if (!StringUtils.isBlank(fromDate)) {
            if (StringUtils.isBlank(temp)) {
                temp = "?fromDate=" + fromDate;
            } else {
                temp += "&fromDate=" + fromDate;
            }
        }
        if (!StringUtils.isBlank(toDate)) {
            if (StringUtils.isBlank(temp)) {
                temp = "?toDate=" + toDate;
            } else {
                temp += "&toDate=" + toDate;
            }
        }
        PagingUtil pagingUtil = new PagingUtil(RequestUtil.getCurrentLink(request) + temp, pageSize, currentPage, total);
        List<InventoryStoreDrugIndent> listIndent = inventoryService.listSubStoreIndent(subStore.getId(), indentName, statusId, fromDate, toDate, pagingUtil.getStartPos(), pagingUtil.getPageSize());
        List<Action> listSubStoreStatus = ActionValue.getListIndentSubStore();

        return SimpleObject.fromCollection(listIndent, uiUtils, "id", "name", "createdOn", "transaction.description", "subStoreStatus", "subStoreStatusName");
    }

}
