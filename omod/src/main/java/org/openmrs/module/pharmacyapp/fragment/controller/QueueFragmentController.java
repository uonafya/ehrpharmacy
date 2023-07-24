package org.openmrs.module.pharmacyapp.fragment.controller;

import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.InventoryStoreDrugPatient;
import org.openmrs.module.hospitalcore.model.PatientSearch;
import org.openmrs.module.hospitalcore.util.FlagStates;
import org.openmrs.module.ehrinventory.InventoryService;
import org.openmrs.module.ehrinventory.util.PagingUtil;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class QueueFragmentController {
    public void controller(){

    }
    public List<SimpleObject> searchPatient(
            @RequestParam(value = "date", required = false) String dateStr,
            @RequestParam(value = "searchKey", required = false) String searchKey,
            @RequestParam(value = "currentPage", required = false) Integer currentPage,
            @RequestParam(value = "pgSize", required = false) Integer pgSize,
            UiUtils uiUtils) {
        if (pgSize == null) {
            pgSize = Integer.MAX_VALUE;
        }

        Integer flags = FlagStates.NOT_PROCESSED;

        InventoryService inventoryService = Context.getService(InventoryService.class);
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd/MM/yyyy");
        Date date = null;
        try {
            date = simpleDateFormat.parse(dateStr);
        } catch (ParseException e) {
            e.printStackTrace();
        }

        List<PatientSearch> patientSearchList = inventoryService.searchListOfPatient(date, searchKey, currentPage,pgSize);
        if (currentPage == null) currentPage = 1;
        int total = inventoryService.countSearchListOfPatient(date, searchKey, currentPage);
        PagingUtil pagingUtil = new PagingUtil(pgSize, currentPage, total);


        List<SimpleObject> patientQueueList = new ArrayList<SimpleObject>();

        for (PatientSearch patientSearch : patientSearchList) {
            SimpleObject patientInQueue = new SimpleObject();

            String fullNames = patientSearch.getGivenName() + ' ' + patientSearch.getFamilyName();
            if (patientSearch.getMiddleName() != null){
                fullNames += ' ' + patientSearch.getMiddleName();
            }

            patientInQueue.put("fullname", fullNames);
            patientInQueue.put("identifier", patientSearch.getIdentifier());
            patientInQueue.put("age", patientSearch.getAge());

            if (patientSearch.getGender().equals("M")){
                patientInQueue.put("gender", "Male");
            }
            else{
                patientInQueue.put("gender", "Female");
            }

            patientInQueue.put("patientId", patientSearch.getPatientId());
            patientInQueue.put("flag", flags);

            patientQueueList.add(patientInQueue);
        }

        return patientQueueList;
        //return SimpleObject.fromCollection(patientSearchList,uiUtils,"fullname", "identifier", "age", "gender","patientId");

    }



}
