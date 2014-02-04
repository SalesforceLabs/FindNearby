public with sharing class FindNearbyMap {

public Boolean searchLeads {get;set;}
public Boolean searchAccounts {get;set;}
public Boolean searchContacts {get;set;}
public Boolean OnlyMyRecords{get;set;} 
public Boolean pAccounts = false;  

public Boolean ListAccounts = false;  
public Boolean ListLeads = false;  
public Boolean ListContacts = false;  

public String distance;
public Boolean needFilters{get;set;}

public List<MapItem> locs = new List<MapItem>();
public List<MapItem> destinations = new List<MapItem>();
public MapItem startingPoint {get;set;}
public String StartingAddress {get;set;}

public Map<String, MapItem> locationMap = new Map<String, MapItem>{};
public List<SelectOption> AccountTypeOptions = new List<SelectOption>();
public List<SelectOption> AccountIndustryOptions = new List<SelectOption>();

public List<MapItem> getDestinations(){return destinations;}

public String getDistance(){ return distance+'';}

public String[] AccountTypes = new String[]{'All'};
public String[] AccountIndustries = new String[]{'All'};
public String[] LeadStatuses = new String[]{'All'};

public void setAccountTypes(String[] s){ AccountTypes = s;}
public String[] getAccountTypes(){return AccountTypes;}
public void setAccountIndustries(String[] s){ AccountIndustries = s;}
public String[] getAccountIndustries(){return AccountIndustries;}
public void setLeadStatuses(String[] s){ LeadStatuses = s;}
public String[] getLeadStatuses(){return LeadStatuses;}
public boolean LeadsAvailable,ContactsAvailable,AccountsAvailable; 

public boolean getLeadsAvailable(){
	try{
		FN__FindNearby__c FNA = FN__FindNearby__c.getOrgDefaults();
    	LeadsAvailable = FNA.FN__Leads__c;
	}
	catch(Exception e){LeadsAvailable=false;}
    
    return LeadsAvailable;
}
public boolean getContactsAvailable(){
	try{
		FN__FindNearby__c FNA = FN__FindNearby__c.getOrgDefaults();
    	ContactsAvailable = FNA.FN__Contacts__c;
	}
	catch(Exception e){ContactsAvailable=false;}
	
    return ContactsAvailable;
}
public boolean getAccountsAvailable(){
	try{
		FN__FindNearby__c FNA = FN__FindNearby__c.getOrgDefaults();
    	AccountsAvailable = FNA.FN__Accounts__c;
	}
	catch(Exception e){AccountsAvailable=false;}
    return AccountsAvailable;
}

public String getGKey(){ 
	findNearby__c settings = findNearby__c.getInstance();
    if(settings.GKey__c == null)
    {
    	return ' ';
    }
    return settings.GKey__c;
	
}


public PageReference init(){
    
    
    
    //reset variables to default.
    needFilters=true;
    distance = '25';
    
    searchLeads = getLeadsAvailable(); 
    
    onlyMyRecords=true;
    
    searchAccounts = getAccountsAvailable();
    
    searchContacts = getContactsAvailable();
    
    HandleListViews();
    
    setAccountTypeOptions();
    hasPersonAccounts(); 
    setAccountIndustryOptions();
    
    return setStartingPoint();
    
} 

public void HandleListViews(){
    handleAccountListView();
    handleLeadListView();
    handleContactListView();
}


public void handleContactListView(){
    String clids = ApexPages.currentPage().getParameters().get('clids');
    List<String> cids = new List<String>();
    if(clids !='null' && clids !=null){ 
            cids.addAll(clids.split(','));          
            needFilters = false; 
            try{
                List<Contact> ContactList= [Select Title, Phone, OwnerId, OtherStreet, OtherState, OtherPostalCode, OtherPhone, OtherCountry, OtherCity, Name, Owner.Name, Account.Type, 
                                                 Mapping_Status__c, Mapping_Address__c, MailingStreet, MailingState, Account.Industry,
                                                 MailingPostalCode, MailingCountry, MailingCity, Lon__c, Lat__c, Id, Email 
                                                 From Contact
                                                where id in :cids and Mapping_Status__c = 'Located'];
           
                for(Contact a: ContactList){
                    locs.add(new MapItem(a));
                }
                listContacts = true; 
            }
            catch(Exception e){
            
            }
    } 
}




public void handleLeadListView(){
    String llids = ApexPages.currentPage().getParameters().get('llids');
    List<String> lids = new List<String>();
    if(llids !='null' && llids !=null){ 
            lids.addAll(llids.split(','));          
            needFilters = false; 
            try{
                List<Lead> leadList= [Select OwnerId, Do_Not_Map__c, Mapping_Status__c,Lat__c, Lon__c, Phone,Status,Industry, PostalCode, State, Street, City, Country, Name,Owner.Name 
                                    from Lead
                                    where id in :lids and Mapping_Status__c = 'Located'];
           
                for(Lead a: leadList){
                    locs.add(new MapItem(a));
                }
                ListLeads = true; 
            }
            catch(Exception e){
            
            }
    } 
}

public void handleAccountListView(){
        String Alids = ApexPages.currentPage().getParameters().get('alids');
        List<String> ids = new List<String>();
        if(Alids !='null' && Alids !=null){ 
            ids.addAll(Alids.split(','));          
            needFilters = false; 
            
            try{
                List<Account> asd= [Select  OwnerId, Mapping_Status__c, Id,  Name, Lat__c,Lon__c,Phone, 
                    BillingStreet, BillingCity,BillingState, BillingPostalCode, BillingCountry, 
                    Which_Address__c,ShippingStreet,ShippingCity,ShippingState,Type, Industry, 
                    ShippingPostalCode,ShippingCountry, Owner.Name from Account
                    where id in :ids and Mapping_Status__c ='Located']; 
            
                for(Account a: asd){
                    locs.add(new MapItem(a));
                }
                ListAccounts = true; 
            }
            catch(Exception e){
            
            }
        } 
}


public void setDistance(String d){ 
    try{
        Decimal a = Decimal.valueOf(d);
        if(a>200){
            distance = '25';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Distance must be less than 200 miles');
            ApexPages.addMessage(myMsg);
            
        }
        else{
            distance = d;
        }
    }
    catch(Exception e){
        //If it's not a decimal.
        distance = '25';
    }

    
}


public PageReference setStartingPoint(){
    if(locs.size() == 0 && !needFilters){
        return Page.MapError_BadListView;
    }
    else if(!needFilters){
        
        startingPoint =locs[0];
        startingPoint.rName= 'List View';
    }
    
    
    if(needFilters){
        String sID = ApexPages.currentPage().getParameters().get('lid');
        
        if(sID =='null'||sID ==null){
            sID = ApexPages.currentPage().getParameters().get('aid');
            
            if(sID !='null' && sID !=null){ 
                Account a = MapUtility.getSingleAccountToPlot(sID);
                startingPoint = new MapItem(a);
            }
            else{
                sID = ApexPages.currentPage().getParameters().get('cid');
                if(sID !='null' && sID !=null){ 
                    Contact c = MapUtility.getSingleContactToPlot(sID,pAccounts); 
                    startingPoint = new MapItem(c);
                }
            }
        } 
        else{
            Lead l = MapUtility.getSingleLeadToPlot(sID);
            startingPoint = new MapItem(l);
        }
    } 


    if(startingPoint == null)
    {
        return Page.MapError_NoStartingPoint;
    }
     
    return null;
}


    
     
    
    
public List<MapItem> getLocations(){
    locs = new List<MapItem>();
    try{
        if(needFilters){
        
            if(searchAccounts){
                locs.addAll(MapUtility.getNearbyAccounts(startingPoint, Decimal.valueOf(distance)));
            }
            if(searchLeads){
                locs.addAll(MapUtility.getNearbyLeads(startingPoint, Decimal.valueOf(distance)));
            }
            if(searchContacts){
                locs.addAll(MapUtility.getNearbyContacts(startingPoint, Decimal.valueOf(distance)));
            }
            filterLocs();
            sortLocs();
        }
        else{
            handleListViews();
        }
        
        makeMap();
    }
    catch(Exception e){
        sortLocs();
        makeMap();
    }
    return locs;
}


/*
Instead of Customizing the Query... which can get cumbersome.
Query more - Remove After the fact. 

*/
public void filterLocs(){
    filterMine();
    filterIndustry();
    filterAccountType();
    filterLeadStatuses();
}


public void filterIndustry(){
    //Check if ALL has been selected. 
    Boolean all=false;
    for(String i: AccountIndustries){
        if(i == 'All'){
            all = true; 
        }
    }
    
    if(!all){
        List<MapItem> ls = new List<MapItem>();
        for(Integer k=0; k<locs.size(); k++){
        
            for(String ind : AccountIndustries){
                if(ind.equals(locs[k].rIndustry)){
                    ls.add(locs[k]);
                    
                }//Are they equal?
            }//check for EACH indsutry value.
        }//the list of locations
        locs = ls;  
    }//If we are filtering
}

public void filterAccountType(){
    //Check if ALL has been selected. 
    Boolean all=false;
    for(String i: AccountTypes){
        if(i == 'All'){
            all = true; 
        }
    }
    
    if(!all){
        List<MapItem> ls = new List<MapItem>();
        for(Integer k=0; k<locs.size(); k++){
        
            for(String ind : AccountTypes){
                if(locs[k].rType=='Account' && ind.equals(locs[k].rOne)){
                    ls.add(locs[k]);
                    
                }//Are they equal?
               if(locs[k].rType != 'Account'){
                    ls.add(locs[k]);
               }
            }//check for EACH indsutry value.
        }//the list of locations
        locs = ls;  
    }//If we are filtering
}

public void filterLeadStatuses(){
    //Check if ALL has been selected. 
    Boolean all=false;
    for(String i: LeadStatuses){
        if(i == 'All'){
            all = true; 
        }
    }
    
    if(!all){
        List<MapItem> ls = new List<MapItem>();
        for(Integer k=0; k<locs.size(); k++){
        
            for(String ind : LeadStatuses){
                if(locs[k].rType=='Lead' && ind.equals(locs[k].rOne)){
                    ls.add(locs[k]);
                    
                }//Are they equal?
               if(locs[k].rType != 'Lead'){
                    ls.add(locs[k]);
               }
            }//check for EACH indsutry value.
        }//the list of locations
        locs = ls;  
    }//If we are filtering
}

public void makeMap(){
    for(MapItem a: locs){
        locationMap.put(a.rId,a);   
    }
}

/*
Is the record owned by me?
*/
public void filterMine(){
    if(onlyMyRecords){
        for(Integer k=0; k<locs.size(); k++)
        {  
            //If you find the main account.
           if(locs[k].rOwnerId != UserInfo.getUserId())
           {
               Locs.remove(k);
           } 
        }
    }
}
/*
This function goes through the final Filtered list, and makes sure the Starting Point is #1
*/
public void sortLocs(){
     for(Integer k=0; k<locs.size(); k++)
     {  
       //If you find the main account.
       if(locs[k].rId == startingPoint.rId)
       {
           Locs.remove(k);
           break;
       } 
    }
    //If that was the only account found... then you have to add it with different syntax.    
    if(Locs.isEmpty()){
        //startingPoint.rName = 'e:None Returned';
        Locs.add(startingPoint);
    }
    else{Locs.add(0,startingPoint);}
     
} 

public pageReference Search(){
    getLocations();
    return null;
}




public PageReference goBackToRecord(){
    PageReference p;
    if(needFilters){
        p = new PageReference('/'+startingPoint.rId);
    }
    else if (ListAccounts){
        p = new PageReference('/001/o');
    }
    else if (ListContacts){
        p = new PageReference('/003/o');
    }
    else if (ListLeads){
        p = new PageReference('/00Q/o');
    }
    return p;
}

public Boolean hasPersonAccounts(){
    pAccounts =  MapUtility.hasPersonAccounts(); 
    return pAccounts;
}






/*
    Set the Account Type Options from the UI
*/
public void setAccountTypeOptions(){
    Schema.DescribeFieldResult F = Account.Type.getDescribe();
    List<Schema.PicklistEntry> P = F.getPicklistValues();

    AccountTypeOptions.add(new SelectOption('All',system.label.All));

    for(integer k =0; k< P.size(); k++)
    {
        if(P[k].isActive())
        {
           AccountTypeOptions.add(new SelectOption(P[k].getLabel(),P[k].getLabel()));
        }
    }   
}

/*
    get the list of all Account Types
*/ 
public List<SelectOption> getAccountTypeOptions(){
   if(AccountTypeOptions == null){
        setAccountTypeOptions();
   }
     
   return AccountTypeOptions;
}


/*
    Get the list of all Account Industries. 
*/
public List<SelectOption> getAccountIndustryOptions(){
   if(AccountIndustryOptions == null){
        setAccountIndustryOptions();
   }
   return AccountIndustryOptions;
}

/*
    Creates the list of all Account Industries. 
*/
public void setAccountIndustryOptions(){
    Schema.DescribeFieldResult F = Account.Industry.getDescribe();
    List<Schema.PicklistEntry> P = F.getPicklistValues();

    AccountIndustryOptions.add(new SelectOption('All',system.label.All));

    for(integer k =0; k< P.size(); k++)
    {
        if(P[k].isActive())
        {
           AccountIndustryOptions.add(new SelectOption(P[k].getLabel(),P[k].getLabel()));
        }
    }
        
}


/* 
    Creates drop down of Distances 
*/  
public List<SelectOption> getDistances(){ 
    List<SelectOption> distances = new List<SelectOption>{new SelectOption('1','1'),
            new SelectOption('5','5'),new SelectOption('10','10'), new SelectOption('15','15'),
            new SelectOption('20','20'), new SelectOption('25','25'), new SelectOption('50','50'), new SelectOption('75','75'),
            new SelectOption('100','100'),new SelectOption('150','150')
    }; 
  return distances;
}

/*
    Create the Lead Status Options List
*/
public List<SelectOption> getLeadStatusOptions(){
        List<SelectOption> items = new List<SelectOption>();
        Schema.DescribeFieldResult F = Lead.Status.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
    
        items.add(new SelectOption('All',system.label.All));
    
        for(integer k =0; k< P.size(); k++)
        {
            if(P[k].isActive())
            {
               items.add(new SelectOption(P[k].getLabel(),P[k].getLabel()));
            }
        }
         return items;
}

/*
    returns the number of locations on the map
*/
public Integer getCount(){
    if(locs == null)
    {
        getLocations();
    }
    return locs.size();
}

    
}