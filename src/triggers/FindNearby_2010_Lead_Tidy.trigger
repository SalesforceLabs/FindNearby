trigger FindNearby_2010_Lead_Tidy on Lead (before update) {

     for(Integer k=0; k<Trigger.new.size(); k++)
     {
        Boolean reset = false; 
        
        if(Trigger.new[k].Street != Trigger.old[k].Street || 
           Trigger.new[k].City != Trigger.old[k].City ||
           Trigger.new[k].PostalCode != Trigger.old[k].PostalCode || 
           Trigger.new[k].State != Trigger.old[k].State || 
           Trigger.new[k].Country != Trigger.old[k].Country )
        {   
           reset = true;  
        }
        
        if(Trigger.new[k].Mapping_Status__c != 'Located')
        {
          Trigger.new[k].Lat__c = null;
            Trigger.new[k].Lon__c = null;
        }
        
        if(reset){
            Trigger.new[k].Mapping_Status__c = 'Not Located Yet';
            Trigger.new[k].Lat__c = null;
            Trigger.new[k].Lon__c = null;
        }
        
     }//end FOR
}