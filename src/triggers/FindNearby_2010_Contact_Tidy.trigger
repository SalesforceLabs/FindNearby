trigger FindNearby_2010_Contact_Tidy on Contact (before update) {
     for(Integer k=0; k<Trigger.new.size(); k++)
     {
        Boolean reset = false; 
        //If they change which Address to map 
        if(Trigger.new[k].Mapping_Address__c != Trigger.old[k].Mapping_Address__c)
        { 
            reset = true; 
        }
        
        if(Trigger.new[k].Mapping_Address__c == 'Mailing')
        {
            if(Trigger.new[k].MailingStreet != Trigger.old[k].MailingStreet || Trigger.new[k].Mailingcity != Trigger.old[k].MailingCity ||
               Trigger.new[k].MailingPostalCode != Trigger.old[k].MailingPostalCode || Trigger.new[k].MailingState != Trigger.old[k].MailingState || Trigger.new[k].MailingState != Trigger.old[k].MailingState
               || Trigger.new[k].MailingCountry != Trigger.old[k].MailingCountry )
            {   
               reset = true;  
               
            }
        }
        else if(Trigger.new[k].Mapping_Address__c == 'Other')
        {
            if(Trigger.new[k].OtherStreet != Trigger.old[k].OtherStreet || Trigger.new[k].Othercity != Trigger.old[k].OtherCity
             ||Trigger.new[k].OtherPostalCode != Trigger.old[k].OtherPostalCode || Trigger.new[k].OtherState != Trigger.old[k].OtherState  ||
             Trigger.new[k].OtherCountry != Trigger.old[k].OtherCountry)
            {
                  reset = true;  
            }
        }
        else{
        	Trigger.new[k].Mapping_Address__c = 'Mailing';
        	reset = true;         	
        }
        
        
        if(reset){
            Trigger.new[k].Mapping_Status__c = 'Not Located Yet';
            Trigger.new[k].Lat__c = null;
            Trigger.new[k].Lon__c = null;
        }
        
     }//end FOR
}