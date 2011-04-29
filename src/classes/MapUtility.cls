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
public with sharing class MapUtility {
    
    Map<String, String> errors = new Map<String, String> {'200' => 'Located', '610' => 'Bad Google Maps Key', 
                                                          '620' =>'Google Exhausted', '500'=>'Google Exhausted',
                                                          '000'=>'Problem with Address'};

    public static String LeadBaseQuery = 'Select OwnerId, Do_Not_Map__c, Mapping_Status__c,'+
                                         ' Lat__c, Lon__c, Phone,Status,Industry,'+
                                         ' PostalCode, State, Street, City, Country,'+
                                         ' Name,Owner.Name'+
                                         ' from Lead ';
    
    public static String AccountBaseQuery = 'Select  OwnerId, Mapping_Status__c, Id,'+
                                         ' Name, Lat__c,Lon__c,Phone, BillingStreet,'+
                                         ' BillingCity,BillingState, BillingPostalCode,'+
                                         ' BillingCountry, Which_Address__c,ShippingStreet,'+
                                         ' ShippingCity,ShippingState,Type, Industry, ShippingPostalCode,'+
                                         ' ShippingCountry, Owner.Name'+
                                         ' from Account ';
    

    
    
    public static String ContactBaseQuery= 'Select Title, Phone, OwnerId, OtherStreet, OtherState, '+
                                         ' OtherPostalCode, OtherPhone, OtherCountry, OtherCity, Name, Owner.Name, Account.Type, '+
                                         ' Mapping_Status__c, Mapping_Address__c, MailingStreet, MailingState, Account.Industry,'+
                                         ' MailingPostalCode, MailingCountry, MailingCity, Lon__c, Lat__c, Id, Email From Contact ';
    
    
    public static String LeadToPlot = ' where (Mapping_Status__c != \'Located\' and Mapping_Status__c != \'Problem with Address\' and isConverted = false and Do_Not_Map__c = false) ';
    public static String AccountToPlot = ' where (Mapping_Status__c != \'Located\' and Mapping_Status__c != \'Problem With Address\') '+ 
                                        'and Which_Address__c != \'Do Not Map\' ';

    public static String ContactToPlot  = ' where (Mapping_Status__c != \'Located\' and Mapping_Status__c != \'Problem With Address\') '+ 
                                        'and Mapping_Address__c != \'Do Not Map\' ';
                                         
    public static String singleLimit = ' Limit 1 ';
    //public static String ObjectLimit = ' Limit 150';
        
    
    
    /*
    I will specifically find leads that NEED TO BE GEOLOCATED
    Pass in a Lead's Id, get all the fields required. 
    If no Id is passed in (null), return ANY lead should be Geolocated.
    
        If I can't find anything - return null; 
    */
    public static Lead getSingleLeadToPlot(String id){
        Lead l; 
         try{
            if(id != null)
            {
                l = [ Select OwnerId, Do_Not_Map__c, Mapping_Status__c, Lat__c, Lon__c, Phone,Status,Industry, PostalCode, State, Street, City, Country, Name,Owner.Name 
                        from Lead
                        where id = :EncodingUtil.urlEncode(id,'UTF-8')
                        limit 1]; 
               
            }
            else{
                l = [ Select OwnerId, Do_Not_Map__c, Mapping_Status__c, Lat__c, Lon__c, Phone,Status,Industry, PostalCode, State, Street, City, Country, Name,Owner.Name 
                        from Lead
                        where (Mapping_Status__c != 'Located' and Mapping_Status__c != 'Problem with Address' and isConverted = false and Do_Not_Map__c = false) 
                        limit 1
                    ];
               
            }
         }
         catch(Exception e){
                 l = null;
         }
         return l; 
    }

    /*
    I will specifically find leads that NEED TO BE GEOLOCATED
    Pass in a Lead's Id, get all the fields required. 
    If no Id is passed in (null), return ANY lead should be Geolocated.
    
        If I can't find anything - return null; 
    */
    public static Contact getSingleContactToPlot(String id, Boolean pAccounts){
        Contact l; 
         try{
            
                   
            if(id != null)
            {
                id = String.escapeSingleQuotes(id);
                l = [Select Title, Phone, OwnerId, OtherStreet, OtherState, 
                                         OtherPostalCode, OtherPhone, OtherCountry, OtherCity, Name, Owner.Name, Account.Type,
                                         Mapping_Status__c, Mapping_Address__c, MailingStreet, MailingState, Account.Industry,
                                         MailingPostalCode, MailingCountry, MailingCity, Lon__c, Lat__c, Id, Email 
                    From Contact
                    where id=:EncodingUtil.urlEncode(id,'UTF-8')
                    limit 1 ];
               
            }
            else{
                if(pAccounts){
                      l = Database.query(ContactBaseQuery+ContactToPlot+' and isPersonAccount= false ' +singleLimit);
                }
                else{

                   l= [Select Title, Phone, OwnerId, OtherStreet, OtherState, 
                     OtherPostalCode, OtherPhone, OtherCountry, OtherCity, Name, Owner.Name, Account.Type,
                     Mapping_Status__c, Mapping_Address__c, MailingStreet, MailingState, Account.Industry,
                     MailingPostalCode, MailingCountry, MailingCity, Lon__c, Lat__c, Id, Email 
                     From Contact
                     where  (Mapping_Status__c != 'Located' and Mapping_Status__c != 'Problem With Address')  
                                        and Mapping_Address__c != 'Do Not Map' 
                     limit 1]; 
                    
                }
               
            }
         }
         catch(Exception e){
            
            l = null;
         }
         return l; 
    }
    


    /*
    I will specifically find Accounts that NEED TO BE GEOLOCATED
    Pass in a Account's Id, get all the fields required. 
    If no Id is passed in (null), return ANY lead should be Geolocated.
    */
    public static Account getSingleAccountToPlot(String id){
        Account a; 
         try{
            if(id != null)
            {
                a = [Select  OwnerId, Mapping_Status__c, Id,Name, Lat__c,Lon__c,Phone, BillingStreet,
                              BillingCity,BillingState, BillingPostalCode,BillingCountry, Which_Address__c,
                              ShippingStreet, ShippingCity,ShippingState,Type, Industry, ShippingPostalCode,ShippingCountry, Owner.Name
                     from Account 
                     where id = :EncodingUtil.urlEncode(id,'UTF-8')
                     limit 1];
                
                //a = Database.query(AccountBaseQuery+' where id = \''+id+'\' '+singleLimit);
            }
            else{
                a = [Select  OwnerId, Mapping_Status__c, Id,
                                Name, Lat__c,Lon__c,Phone, BillingStreet, BillingCity,BillingState, BillingPostalCode,
                                          BillingCountry, Which_Address__c,ShippingStreet, ShippingCity,ShippingState,Type, Industry, ShippingPostalCode,ShippingCountry, Owner.Name
                     from Account
                     where (Mapping_Status__c != 'Located' and Mapping_Status__c != 'Problem With Address')  
                                        and Which_Address__c != 'Do Not Map'
                     limit 1]; 
                //a = Database.query(AccountBaseQuery+AccountToPlot+singleLimit);
            }
         }
         catch(Exception e){
            
            a = null;
         }
         return a; 
    }
    
    
    public static Integer getObjectLimit(){
        try{
        FindNearby__c FNA = FindNearby__c.getOrgDefaults();
        String num = FNA.How_Many__c + ' ';
        
        Integer k = num.IndexOf('.');
        
        num = num.substring(0,k);
        
         return Integer.ValueOf(num);
        }
        catch(Exception e){
             return 35;
        }
                
        
    }
    
    public static Decimal getAccuracy(){
        Decimal num=6;
        try{
            FindNearby__c FNA = FindNearby__c.getOrgDefaults();
            num = FNA.Accuracy__c;
        }catch(Exception e){return 6;}
        
        if(num < 1){ num = 1;}
        if(num > 9){num = 9;}       
        
        return num;        
    }
    
    
    
    public static List<MapItem> getNearbyAccounts(MapItem startingPoint, Decimal d){
                          
        list<Account>Accounts = new List<Account>();
        List<MapItem> items = new List<MapItem>();
        //Integer k =0;
        
        try{
             List<Decimal> latLons = getBoundingBox(startingPoint,d);
            Accounts = [Select  OwnerId, Mapping_Status__c, Id,
                                          Name, Lat__c,Lon__c,Phone, BillingStreet,
                                          BillingCity,BillingState, BillingPostalCode,
                                          BillingCountry, Which_Address__c,ShippingStreet, ShippingCity,ShippingState,Type, Industry, ShippingPostalCode,ShippingCountry, Owner.Name
                        from Account 
                        where ((lat__c >= :latLons[0] and lon__c >= :latLons[1]
                             and lat__c <= :latLons[2]  and lon__c <= :latLons[3])
                             or Id = :EncodingUtil.urlEncode(startingPoint.rId,'UTF-8'))
                        limit :getObjectLimit() 
                     ];
                            
            
            //Get all leads nearby
            //Accounts = database.Query(AccountBaseQuery+ getBoundingCondition(startingPoint, d)+  getObjectLimit() );
            
            //Convert the leads to MapItems
            for(Account a: Accounts){
                items.add(new MapItem(a));
            }
        }
        //If Something went wrong, just return the Starting Point
        catch(Exception e){
            items.add(startingPoint);
        }
        return items; 
    }
    
     public static List<MapItem> getNearbyContacts(MapItem startingPoint, Decimal d){
                
        list<Contact> Contacts = new List<Contact>();
        List<MapItem> items = new List<MapItem>();
        Integer k =0;
        try{
             List<Decimal> latLons = getBoundingBox(startingPoint,d);
             Contacts = [Select Title, Phone, OwnerId, OtherStreet, OtherState, 
                                         OtherPostalCode, OtherPhone, OtherCountry, OtherCity, Name, Owner.Name, Account.Type,
                                         Mapping_Status__c, Mapping_Address__c, MailingStreet, MailingState, Account.Industry,
                                         MailingPostalCode, MailingCountry, MailingCity, Lon__c, Lat__c, Id, Email 
                        From Contact
                        where  ((lat__c >= :latLons[0] and lon__c >= :latLons[1]
                             and lat__c <= :latLons[2]  and lon__c <= :latLons[3])
                             or Id = :EncodingUtil.urlEncode(startingPoint.rId,'UTF-8'))
                        limit :getObjectLimit()
                        ];
            
            
            
            //Get all leads nearby
            ///Contacts = database.Query(ContactBaseQuery+ getBoundingCondition(startingPoint, d)+  getObjectLimit() );
            //Convert the leads to MapItems
            for(Contact a: Contacts){
                items.add(new MapItem(a)); 
            }
        }
        //If Something went wrong, just return the Starting Point
        catch(Exception e){
            items.add(startingPoint);
        }
        return items; 
    }
 
 
 
    /*
        I will take a starting point and a distance, and find all Mappable Leads Nearby.
    
    */    
    public static List<MapItem> getNearbyLeads(MapItem startingPoint, Decimal d){
                
        list<Lead>leads = new List<Lead>();
        List<MapItem> items = new List<MapItem>();

        try{
            List<Decimal> latLons = getBoundingBox(startingPoint,d);
            leads =[Select OwnerId, Do_Not_Map__c, Mapping_Status__c, Lat__c, Lon__c, Phone,Status,Industry, PostalCode, State, Street, City, Country, Name,Owner.Name 
                    from Lead
                    where ((lat__c >= :latLons[0] and lon__c >= :latLons[1]
                             and lat__c <= :latLons[2]  and lon__c <= :latLons[3])
                             or Id = :EncodingUtil.urlEncode(startingPoint.rId,'UTF-8'))
                    limit :getObjectLimit()
                    ];
            
            
            //Get all leads nearby
            //leads = database.Query(LeadBaseQuery+ getBoundingCondition(startingPoint, d)+  getObjectLimit() );
            
            //Convert the leads to MapItems
            for(Lead l: Leads){
                items.add(new MapItem(l));
            }
        }
        catch(Exception e){
            items.add(startingPoint);
        }
        return items; 
    }
    
    
    //This will interpret the results from google, determine what the FNA Status should be. 
    public static String DetermineStatus(String code,String Accuracy){
        String status = '';
        
        //Google found something
        if(code == '200')
        {
            try{
                //Was it accurate enough? 
                if(Double.valueOf(Accuracy)>= Double.valueOf(getAccuracy()+' ' )){
                    status = 'Located';
                }
                else{
                    status = 'Problem with Address';
                }
            }
            catch(Exception e){
                status = 'Problem with Address';
                System.debug('Determine Status:' + e+' Accuracy:'+Accuracy);
            }
        }
        //Bad Google Key
        else if (code == '610'){ 
            status = 'Bad Google Maps Key';
        }
        //Just try some other time
        else if (code == '620' || code =='500'){ 
            status = 'Google Exhausted';
        }
        //Anything else... probably should try this one again later, or direct attention to address.
        else{
                status= 'Problem with Address';
        }
            
        return status;
        
        
    }

    /*
        Returns the bounding box. 
        Lat MIN, Lon Min, Lat Max, Lon Max.
        If there's an "error" return a non-valid bounding box (min > max)
    */
    public static List<Decimal> getBoundingBox(MapItem i, Decimal d){
        List<Decimal> latlons = new List<Decimal>();
        try{
            latlons.add( calcMinLat(i,d) );// Lat Min
            latlons.add( calcMinLon(i,d) );// Lon Min
            latlons.add( calcMaxLat(i,d) );// Lat Max
            latlons.add( calcMaxLon(i,d) );// Lon Max
        }
        catch(Exception e){
            latlons.add( 1 );// Lat Min
            latlons.add( 1 );// Lon Min
            latlons.add( 0 );// Lat Max
            latlons.add( 0 );// Lon Max
        }
        return latlons; 
        
    }
    
    /*
        I will take a starting point and a distance and return the string Conditional statement.
        I will help you find all the Whatevers within the boundingBox. 
    */
    public static String getBoundingCondition(MapItem startingPoint, Decimal d){
        List<Decimal> latLons = getBoundingBox(startingPoint,d);
        String condition = ' where ((lat__c >= '+latLons[0] +' and lon__c >= '+latLons[1]+
                             ' and lat__c <= '+latLons[2] +' and lon__c <= '+latLons[3]+')'+
                             ' or Id = \''+startingPoint.rId+'\')';
        
        
        return condition;
    }
    
    
    public static Decimal calcMaxLat(MapItem i, Decimal distance){
        Decimal lat = i.rLat;
        Decimal lon = i.rLon;
        
        Decimal maxLat = (distance + (69.1)* lat)/69.1;
        return Math.abs(maxLat);
    }

    public static Decimal calcMinLat(MapItem i, Decimal distance){
        Decimal max = calcMaxLat(i,distance);
        Decimal diff = max - i.rLat;
        
        return i.rLat-diff;
    }
    
    public static Decimal calcMaxLon(MapItem i, Decimal distance){
        Decimal lat = i.rLat;
        Decimal lon = i.rLon;
        Decimal L = Math.cos(lat/57.3);
        
        Decimal max = (distance + (L * 69.1*lon))/(L*69.1);
        return max; 
    }

    public static Decimal calcMinLon(MapItem i, Decimal distance){
        Decimal max = calcMaxLon(i,distance);
        Decimal diff = max - i.rLon;
        
        return i.rLon-diff;
    }       

    
    public static boolean hasPersonAccounts(){ 
        Map<String, Schema.SObjectField> M = Schema.SObjectType.Contact.fields.getMap();
            
        if(M.containsKey('IsPersonAccount')){
            return true;
        }   
        return false; 
    }
    


}