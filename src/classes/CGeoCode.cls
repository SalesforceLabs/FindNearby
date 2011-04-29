/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
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