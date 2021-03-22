package org.openmrs.module.pharmacyapp.metadata;

import org.springframework.stereotype.Component;
import org.openmrs.module.metadatadeploy.bundle.AbstractMetadataBundle;
import org.openmrs.module.metadatadeploy.bundle.Requires;

import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.idSet;
import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.privilege;
import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.role;

@Component
@Requires(org.openmrs.module.kenyaemr.metadata.SecurityMetadata.class)
public class PharmacyAppSecurity extends AbstractMetadataBundle{

    public static class _Privilege {

        public static final String APP_PHARMACY_MODULE_APP = "App: pharmacyapp.pharmacy";
    }

    public static final class _Role {

        public static final String APPLICATION_PHARMACY_MODULE = "EHR Pharmacy";
    }


    /**
     * @see AbstractMetadataBundle#install()
     */
    @Override
    public void install() {

        install(privilege(_Privilege.APP_PHARMACY_MODULE_APP, "Able to access Key EHR pharmacy features"));
        install(role(_Role.APPLICATION_PHARMACY_MODULE, "Can access Key pharmacy module App for EHR",
                idSet(org.openmrs.module.kenyaemr.metadata.SecurityMetadata._Role.API_PRIVILEGES_VIEW_AND_EDIT),
                idSet(_Privilege.APP_PHARMACY_MODULE_APP)));

    }
}
