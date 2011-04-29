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
public with sharing class MapItem {
    public String rId {get;set;}
    public String rType {get;set;}

    public String rOwner{get;set;}
    public String rPhone{get;set;}
    
    public String rStreet{get;set;}
    public String rCity{get;set;}
    public String rState{get;set;}
    public String rPostalCode{get;set;}
    public String rCountry{get;set;}
    
    public String rAddress{get;set;}
    public String rName{get;set;}
    public String rOwnerId{get;set;}
    public Decimal rLat{get;set;}
    public Decimal rLon{get;set;}
    public String rOne {get;set;}
    public String rIndustry {get;set;}
    public String rOneLabel {get;set;}
    public String rIndustryLabel {get;set;}
    
    
    public MapItem(Account a){
        rId = a.Id;
        rType = 'Account';
        rName = getCleanName(a.Name);
        rLat = a.Lat__c;
        rLon = a.Lon__c;
        rOwnerId = a.OwnerId;
        
        if(a.Which_Address__c != 'Billing')
        {
            setAddress(a.ShippingStreet,a.ShippingCity,a.ShippingState,a.ShippingPostalCode,a.ShippingCountry); 
        }
        else
        {
            setAddress(a.BillingStreet,a.BillingCity,a.BillingState,a.BillingPostalCode,a.BillingCountry); 
              
        }
        rAddress= String.escapeSingleQuotes(getCleanAddress());  
        rphone = a.phone;
        rOwner = a.Owner.Name;
        
        rOneLabel='Type';
        if(a.Type == null){
            rOne = '-';
        }
        else{
            rOne = a.Type;
        }
        
        rOneLabel='Industry';
        if(a.Industry == null){
            rIndustry = '-';
        }
        else{
            rIndustry = a.Industry;
        }
    }
    
    
    
    public MapItem(Contact a){
    	rId = a.Id;
        rType = 'Contact';
        rName = getCleanName(a.Name);
        rLat = a.Lat__c;
        rLon = a.Lon__c;
        rOwnerId = a.OwnerId;
        
        if(a.Mapping_Address__c != 'Mailing')
        {
            setAddress(a.OtherStreet,a.OtherCity,a.OtherState,a.OtherPostalCode,a.OtherCountry); 
        }
        else
        {
            setAddress(a.MailingStreet,a.MailingCity,a.MailingState,a.MailingPostalCode,a.MailingCountry); 
              
        }
        
        rAddress= String.escapeSingleQuotes(getCleanAddress());  
        rphone = a.phone;
        rOwner = a.Owner.Name;
        
        rOneLabel='Type';
        if(a.Account.Type == null){
            rOne = '-';
        }
        else{
            rOne = a.Account.Type;
        }
        
        rOneLabel='Industry';
        if(a.Account.Industry == null){
            rIndustry = '-';
        }
        else{
            rIndustry = a.Account.Industry;
        }
    	
    }
   
    public MapItem(Lead l){
        rId = l.Id;
        rType = 'Lead';
        rName = getCleanName(l.Name);
        rOwnerId = l.OwnerId;
        rLat = l.Lat__c;
        rLon = l.Lon__c;
        setAddress(l.street,l.city,l.state,l.PostalCode,l.Country); 
        
        rphone = l.phone;
        rAddress= String.escapeSingleQuotes(getCleanAddress()); 
        rOwner = l.Owner.Name;
        
        
        
        rOneLabel='Status';
        if(l.Status == null){
            rOne = '-';
        }
        else{
            rOne = l.Status;
        }
        
         if(l.industry == null){
            rIndustry = '-';
        }
        else{
            rIndustry = l.industry;
        }
        
    }
    
    public MapItem(User u){
    	
        rId = u.Id;
        rType = 'Lead';
        rName = getCleanName(u.Name);
        rOwnerId = u.Id;
        rLat = 0;
        rLon = 0;
        rStreet = String.escapeSingleQuotes(u.street);
        rCity = u.city;
        rState = u.State;
        rPostalCode = u.PostalCode;
        rCountry = u.Country;
        rphone = u.phone;
        rAddress=String.escapeSingleQuotes(getCleanAddress());
        rOne='-';
        rIndustry='-'; 
        rOwner = u.Name;
        if(rName.length()>18){
        	rName=rName.substring(0,18)+'...';
        }
        
    }
    
   private Set<String> badChars = new Set<String>{'&', '(', ')','&', ';', ':', 
                                                         '#',  '@', '"', '!', '@', 
                                                         '~', '-', '$', '%', '^', 
                                                         '&', '*', '_', '+', '=', 
                                                         '?', '{', '[', ']',
                                                         '}', '|','\n','\r'};
                                                         
    public String getCleanName(String n){
    	String theName='';
    	
    	try{
            theName = String.escapeSingleQuotes(n+'');  
        
            for(String theChar: badChars)
            {
                theName = theName.replace(theChar,'');    
            }
            
            if(theName.length()>20){
        		theName=theName.substring(0,20);
            }
        }
        catch(Exception e){ theName='-';}
        return theName; 
    	
    }                                                       
    public String getCleanAddress(){
        
        //Make one String with Street, City, State, Zip, Country... as long as each of the elements exist.
        String theAddress =rStreet;
        
        try{
            if(rCity.length()>0){ theAddress+=', '+rCity ;}
        }
        catch(Exception e){ }
        try{
            if(rState.length()>0){ theAddress+=', '+rState ;}
        }
        catch(Exception e){ }
        try{
            if(rPostalCode.length()>0){ theAddress+=', '+ rPostalCode;}
        }
        catch(Exception e){ }
        try{
            if(rCountry.length()>0){ theAddress+=', '+ rCountry;} 
        }
        catch(Exception e){ }
        try{
            theAddress = String.escapeSingleQuotes(theAddress+'');  
        
            for(String theChar: badChars)
            {
                theAddress = theAddress.replace(theChar,'');    
            }
            
            
            
        }
        catch(Exception e){ theAddress='-';}
        return theAddress;      
    }
     private void setAddress(String street,string city, string state, string postalCode, string country){
        if (street == null)
        {
            street = '';
        }
        if (city == null)
        {
            city = '';
        }
        if (state == null)
        {
            state = '';
        }
        if (postalCode == null)
        {
            postalCode = '';
        }
        if (Country== null)
        {
            Country = '';
        }
        
        rStreet = street;
        rCity = city;
        rState = state;
        rPostalCode = postalCode;
        rCountry = Country; 
    }
    
}