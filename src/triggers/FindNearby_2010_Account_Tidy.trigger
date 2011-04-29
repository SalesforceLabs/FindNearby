trigger FindNearby_2010_Account_Tidy on Account (before update) {
     for(Integer k=0; k<Trigger.new.size(); k++)
     {
        Boolean reset = false; 
        //If they change which Address to map 
        if(Trigger.new[k].Which_Address__c != Trigger.old[k].Which_Address__c)
        { 
            reset = true; 
        }
        
        if(Trigger.new[k].Which_Address__c == 'Billing')
        {
            if(Trigger.new[k].BillingStreet != Trigger.old[k].BillingStreet || Trigger.new[k].Billingcity != Trigger.old[k].BillingCity ||
               Trigger.new[k].BillingPostalCode != Trigger.old[k].BillingPostalCode || Trigger.new[k].BillingState != Trigger.old[k].BillingState || Trigger.new[k].BillingState != Trigger.old[k].BillingState
               || Trigger.new[k].BillingCountry != Trigger.old[k].BillingCountry )
            {   
               reset = true;  
               
            }
        }
        else if(Trigger.new[k].Which_Address__c == 'Shipping')
        {
     
            if(Trigger.new[k].ShippingStreet != Trigger.old[k].ShippingStreet || Trigger.new[k].Shippingcity != Trigger.old[k].ShippingCity
             ||Trigger.new[k].ShippingPostalCode != Trigger.old[k].ShippingPostalCode || Trigger.new[k].ShippingState != Trigger.old[k].ShippingState  ||
             Trigger.new[k].ShippingCountry != Trigger.old[k].ShippingCountry)
            {
                  reset = true;  
            }
        }
        else{
        	Trigger.new[k].Which_Address__c = 'Billing';
        	reset = true;         	
        }
        if(reset){
            Trigger.new[k].Mapping_Status__c = 'Not Located Yet';
            Trigger.new[k].Lat__c = null;
            Trigger.new[k].Lon__c = null;
        }
        
     }//end FOR
}