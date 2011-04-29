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
@isTest
private class TestFindNearbyMap {

    static testMethod void tGetSets() {
        FindNearbyMap f = new FindNearbyMap();
        PageReference pageRef = Page.FindNearbyMap;
        Test.setCurrentPage(pageRef);
       
        Account a = [select id from Account limit 1];
        Contact c = [select id from Contact limit 1];
        Lead l = [select id from Lead where isConverted=false limit 1];
        
        a.Mapping_Status__c = 'Located';
        a.Which_Address__c  = 'Billing';   
        a.BillingStreet = '2 Market St'; 
        l.Street = '2 market st';
        c.MailingStreet = '2 market st';
        update a; 
        update l;
        System.assert(l != null);
        f.getAccountIndustryOptions(); 
        f.setAccountIndustryOptions(); 
        
        f.getAccountTypeOptions();
        f.setAccountTypeOptions();
        
        f.getDistances();
        f.getLeadStatusOptions();



        f.searchAccounts = true;
        f.searchContacts = true;
        f.searchLeads = true; 
        
        //first If 
        f.needFilters = false;
        f.setStartingPoint();
        
        //List View Locations
        f.locs.add(new MapItem(a));
        f.setStartingPoint();
        
        //Contacts
        f.needFilters = true;
        f.locs.add(new MapItem(a));
        ApexPages.currentPage().getParameters().put('cid', c.Id);
        f.init();
        f.setStartingPoint();
        
        f.filterLocs();
        //Accounts
        f.needFilters = true;
        f.locs.add(new MapItem(a));
        ApexPages.currentPage().getParameters().put('aid', a.Id);
        f.setStartingPoint();
        
        //Leads
        f.needFilters = true;
        f.locs.add(new MapItem(a));
        ApexPages.currentPage().getParameters().put('lid', l.Id);
        f.setStartingPoint();
        
        
        f.locs = null;
        f.getCount();               
        System.Assert(f.getCount() != null);
        
        f.getDistance();
        System.Assert(f.getDistance() != null);
        
        f.getDestinations();
        
        List<String> s = new List<String>();
        s.add('All');
        
        f.setDistance('200');
        f.setAccountTypes(s);
        f.getAccountTypes();
        f.setAccountIndustries(s);
        f.getAccountIndustries();
        f.setLeadStatuses(s);
        f.getLeadStatuses();
                            
    }   
    
     static testMethod void tlocations() {
        FindNearbyMap f = new FindNearbyMap();
        PageReference pageRef = Page.FindNearbyMap;
        Test.setCurrentPage(pageRef);
       
        Account a = [select id from Account limit 1];
        Contact c = [select id from Contact limit 1];
        Lead l = [select id from Lead limit 1];
        
        a.Mapping_Status__c = 'Located';
        a.Which_Address__c  = 'Billing';   
        update a; 
        
        f.init();
        
        ApexPages.currentPage().getParameters().put('llids', c.Id);
        ApexPages.currentPage().getParameters().put('clids', c.Id);
        ApexPages.currentPage().getParameters().put('alids', c.Id);
        f.init();
        f.handleListViews();
        
        
        System.assert(a != null);
        
     }
    
}