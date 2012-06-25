public with sharing class LGeoCode {
    
    public String Address; 
    public String con;
    public Boolean Problem=false; 
     
    public Lead l; 
    
    public String getGKey(){ 
        try{
        findNearby__c settings = findNearby__c.getInstance();
        return settings.GKey__c;
        }
        catch(Exception e){return ' ';}
        
    }
    
    
    public Lead getL(){return l;}
    
    //Currently setting the continue flag with a Boolean - though the value is a String
    //This is probably not a good idea.
    public void setContinue(Boolean flag){ 
        if(flag){ con ='T';}
        else{ con ='F';}
    }
    public String getContinue(){return con;}
     
    public pageReference init(){
        Boolean doIDoThis=false;
        try{    
            FN__FindNearby__c FNA = FN__FindNearby__c.getOrgDefaults();
            doIDoThis = FNA.FN__Leads__c;
        }catch(Exception e){
            doIDoThis = false;
        }
        if(!doIDoThis){
            return  Page.AGeoCode;
        }
            
        getAddress();
        return null;
    }
    
    public String getAddress(){ 
        
        //Reset the values
        //-----------------
        setContinue(false);
        Address = '-';
        l = new Lead();
        //-----------------
        
        String id = ApexPages.currentPage().getParameters().get('id'); 
        
        l = MapUtility.getSingleLeadToPlot(id);
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
            //Clean up the message
            l.Mapping_Status__c = MapUtility.DetermineStatus(code,Accuracy);        
        
            //Determin what to do. 
            if(l.Mapping_Status__c == 'Located')
            {
                try{
                    l.Lat__c = Double.valueOf(Apexpages.currentPage().getParameters().get('Lat'));
                    l.Lon__c = Double.valueOf(Apexpages.currentPage().getParameters().get('Lon'));
                }
                catch(Exception e){
                    l.Mapping_Status__c = 'Problem with Address';
                    System.debug('AGeoCode:' + e + ' Lat:'+Apexpages.currentPage().getParameters().get('Lat')+' Lon:'+Apexpages.currentPage().getParameters().get('Lon'));
                }
            }
            if(l.Mapping_Status__c == 'Bad Google Maps Key')
            {
                return Page.MapError_Google_Key;
            }
            if(l.Mapping_Status__c == 'Google Exhausted')
            {
                return Page.MapError_TooMany;
            }
            
            
            //If there was a problem with the Address
            if(l.Mapping_Status__c =='Problem with Address')
            {
                problem = true; 
            }
            
            update l; 
        
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
            
            //If Not
            PageReference p = new PageReference('/apex/FindNearbyMap?lid='+id+'&aid=null');
            return p;
        }
        else{    
            return Page.AGeoCode;
        }
    }
    //*********************************************************************************
    private static testMethod void TestAccountGeoCodeController() {
        LGeoCode trol = new LGeoCode();
        
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
        try{
        Lead tL = new Lead();
        tL.FirstName = 'Iman';
        tL.LastName = 'Iman';
        tL.Street = 'a';
        tL.City = 'a';
        tL.State = 'Ca';
        tL.PostalCode = '94105';
        tL.Country = 'USA';
        tL.Company='Company';
        trol.getGkey();
        trol.init();
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
        
        trol.getAddress();
        }
        catch(Exception e){}
     }
    
}