//
//  ContactsDAO.swift
//  ContatosAPI
//
//  Created by Rafael Franca on 28/09/17.
//  Copyright © 2017 Rafael Franca. All rights reserved.
//

import UIKit
import CoreData

struct ContactsDAO {
    func saveContacts(contacts: [Contacts], withPersistentContainer persistentContainer: NSPersistentContainer) {
        persistentContainer.performBackgroundTask { (context) in
            do {
                for contact in contacts {
                    let contactFetchRequest: NSFetchRequest<ContactsCore> = ContactsCore.fetchRequest()
                    contactFetchRequest.predicate = NSPredicate(format: "id == %d", contact.id)
                    
                    let contactsCore = try context.fetch(contactFetchRequest)
                    
                    if contactsCore.count == 0 {
                        let contactCore = ContactsCore(context: context)
                        
                        contactCore.id = Int64(contact.id)
                        contactCore.name = contact.name
                        contactCore.username = contact.username
                        contactCore.email = contact.email
                        contactCore.phone = contact.phone
                        contactCore.website = contact.website
                        
                        let companyCore = CompanyCore(context: context)
                        companyCore.name = contact.company?.name
                        companyCore.catchPhrase = contact.company?.catchPhrase
                        companyCore.bs = contact.company?.bs
                        
                        let addressCore = AddressCore(context: context)
                        addressCore.street = contact.address?.street
                        addressCore.suite = contact.address?.suite
                        addressCore.city = contact.address?.city
                        addressCore.zipcode = contact.address?.zipcode
                        
                        let geoCore = GeoCore(context: context)
                        geoCore.lat = contact.address?.geo?.lat
                        geoCore.lng = contact.address?.geo?.lng
                        
                        addressCore.geo = geoCore
                        geoCore.adress = addressCore
                        contactCore.company = companyCore
                        
                        try context.save()
                    }
                }
            } catch {
                print("Erro no Fetching")
            }
        }
    }
}
