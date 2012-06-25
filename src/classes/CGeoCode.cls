public with sharing class CGeoCode {
    public String Address; 
    public String con;
    public Contact l; 
    public Contact getl(){return l;}
    private Boolean pAccounts=false; 
    public Boolean Problem = false; 
    
    public String getGKey(){ 
        try{
        findNearby__c settings = findNearby__c.getInstance();
        return settings.GKey__c;
        }
        catch(Exception e){return ' ';}
        
    }
    //Currently setting the continue flag with a Boolean - though the value is a String
    //This is probably not a good idea.
    public void setContinue(Boolean flag){ 
        if(flag){ con ='T';}
        else{ con ='F';} 
    }
    public String getContinue(){return con;}
     
    public pageReference init(){ 
        Boolean doIDoThis = false; 
        
        try{
            FN__FindNearby__c FNA = FN__FindNearby__c.getOrgDefaults();
            doIDoThis = FNA.FN__Contacts__c;
        }catch(Exception e){
            doIDoThis = false;
        }
        
        if(!doIDoThis){
           return Page.MapMessage_DoneGeoCoding;
        }
        
        pAccounts = MapUtility.hasPersonAccounts(); 
        getAddress();
        return null;    
    }
    
    public String getAddress(){ 
        
        //Reset the values
        //-----------------
        setContinue(false);
        String Address = '-';
        l = new Contact();
        //-----------------
         
        String id = ApexPages.currentPage().getParameters().get('id'); 
        
        l = MapUtility.getSingleContactToPlot(id,pAccounts) ;
        problem = false; 
        if(l != null ){
            setContinue(true);
            MapItem a = new MapItem(l);
            Address = a.rAddress;   
        }       
        
        return Address;
    }
    
    
    public PageReference result() {
        //Get the Status and the Accuracy of the result
        String code = Apexpages.currentPage().getParameters().get('Stat');
        String Accuracy = Apexpages.currentPage().getParameters().get('Acc');
        
        //If there is a Lead to map...
        if(l !=null)
        {
            Contact a = new Contact(id=l.Id);
            //Clean up the message
            a.Mapping_Status__c = MapUtility.DetermineStatus(code,Accuracy);        
        
            //Determin what to do.  
            if(a.Mapping_Status__c == 'Located')
            {
                try{
                    a.Lat__c = Double.valueOf(Apexpages.currentPage().getParameters().get('Lat'));
                    a.Lon__c = Double.valueOf(Apexpages.currentPage().getParameters().get('Lon'));
                }
                catch(Exception e){
                    a.Mapping_Status__c = 'Problem with Address';
                    System.debug('AGeoCode:' + e + ' Lat:'+Apexpages.currentPage().getParameters().get('Lat')+' Lon:'+Apexpages.currentPage().getParameters().get('Lon'));
                }
            }
            if(a.Mapping_Status__c == 'Bad Google Maps Key')
            {
                return Page.MapError_Google_Key;
            }
            if(a.Mapping_Status__c == 'Google Exhausted')
            {
                return Page.MapError_TooMany;
            }
            //If there was a problem with the Address
            if(a.Mapping_Status__c =='Problem with Address')
            {
                problem = true; 
            }
            
            try{
                update a; 
            }
            catch(Exception e){

            }
            
            if(ApexPages.currentPage().getParameters().get('id') != null){
                    return done();
            }
            return null;
        }
        
        return done();
        
    }
    public String getLName(){
        String name = '-';
        try{
            name = String.escapeSingleQuotes(l.Name);
        }
        catch(Exception e){}
        return name;
    }
    public PageReference done(){ 
        String id = ApexPages.currentPage().getParameters().get('id'); 
        
        if(id != null)
        {
            //If there was a problem with the Address
            if(problem)
            {
                return Page.MapError_ProblemAddress;
            }
            
            PageReference p = new PageReference('/apex/FindNearbyMap?cid='+id);
            return p;
        }
        else{
            return Page.MapMessage_DoneGeoCoding;
        }
    }
    
    public PageReference preTest(){
        pAccounts = MapUtility.hasPersonAccounts();
        PageReference p = Page.CGeoCode;
        p.setRedirect(true);
        return p;
    }
//*********************************************************************************
    private static testMethod void TestContactGeoCodeController() {
        CGeoCode trol = new CGeoCode ();
        
        //Test setContinue
        trol.setContinue(true);
        System.assert(trol.con=='T');       
        trol.setContinue(false);
        System.assert(trol.con=='F');       
        
        
        //Test GetContinue
        System.assert(trol.con == trol.GetContinue());
        
        //Test GetLName
        System.assert(trol.getLName() != null);
        System.assert(trol.done() != null);
        
        Contact tL = new Contact();
        tL.FirstName = 'Iman';
        tL.LastName = 'B';
        tL.Mapping_Address__c = 'Shipping';
        tL.OtherStreet = 'a';
        tL.OtherCity = 'a';
        tL.OtherState = 'Ca';
        tL.OtherPostalCode = '94105';
        tL.OtherCountry = 'USA';
        try{
        insert tL; 
        
        trol.l = tL; 
        
        ApexPages.currentPage().getParameters().put('Stat', '200');
        ApexPages.currentPage().getParameters().put('Acc', '7');
        ApexPages.currentPage().getParameters().put('Lat', '7');
        ApexPages.currentPage().getParameters().put('Lon', '7');
        trol.result();
        
        ApexPages.currentPage().getParameters().put('Stat', '200');
        ApexPages.currentPage().getParameters().put('Acc', '4');
        trol.result();
        ApexPages.currentPage().getParameters().put('Stat', '610');
        ApexPages.currentPage().getParameters().put('Acc', '7');   
        trol.result();
        ApexPages.currentPage().getParameters().put('Stat', '620');
        ApexPages.currentPage().getParameters().put('Acc', '7');
        trol.result();
        ApexPages.currentPage().getParameters().put('Stat', '777');
        ApexPages.currentPage().getParameters().put('Acc', '7');     
        trol.result();
          trol.preTest();
           trol.getGKey();
        trol.init();
        }
        catch(Exception e){}
     }
    
}