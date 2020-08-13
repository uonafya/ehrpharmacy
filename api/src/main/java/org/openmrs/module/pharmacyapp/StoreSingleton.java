package org.openmrs.module.pharmacyapp;

import java.util.HashMap;

/**
 * <p> Class: SubStoreSingleton </p>
 * <p> Author: Nguyen manh chuyen </p>
 * <p> Update by: Nguyen manh chuyen </p>
 * <p> Version: $1.0 </p>
 * <p> Create date: Dec 28, 2010 10:11:47 PM </p>
 * <p> Update date: Dec 28, 2010 10:11:47 PM </p>
 **/
public class StoreSingleton {
    private static StoreSingleton instance = null;
    public static final StoreSingleton getInstance(){
        if (instance == null) {
            instance = new StoreSingleton();
        }
        return instance;
    }
    private static HashMap<String, Object> hash;
    public static HashMap<String, Object> getHash() {
        if( hash == null )
            hash = new HashMap<String, Object>();
        return hash;
    }
}
