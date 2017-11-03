//
//  InserirTableViewController.swift
//  ContatosAPI
//
//  Created by Rafael Franca on 28/09/17.
//  Copyright © 2017 Rafael Franca. All rights reserved.
//

import UIKit
import CoreData

class InserirTableViewController: UITableViewController {
    
    private var viewContext = AppDelegate.viewContext
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var website: UITextField!
    @IBOutlet weak var street: UITextField!
    @IBOutlet weak var suite: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var zipcode: UITextField!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var catchPhrase: UITextField!
    @IBOutlet weak var bs: UITextField!
    
    private var sessionConfiguration: URLSessionConfiguration {
        let cfg = URLSessionConfiguration.default
        cfg.allowsCellularAccess = true
        cfg.networkServiceType = .default
        cfg.requestCachePolicy = .returnCacheDataElseLoad
        cfg.isDiscretionary = true
        cfg.urlCache = URLCache(memoryCapacity: 2048,
                                diskCapacity: 10240,
                                diskPath: NSTemporaryDirectory())
        return cfg
    }
    
    private var operationQueue: OperationQueue {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 5
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        return queue
    }
    
    private var session: URLSession {
        let session = URLSession(configuration: sessionConfiguration,
                                 delegate: self,
                                 delegateQueue: operationQueue)
        return session
    }
    
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        let contacts = ContactsCore(context: viewContext)
        contacts.id = Int64(arc4random() % (arc4random() % 100))
        contacts.name = name.text
        contacts.username = username.text
        contacts.email = email.text
        contacts.phone = phone.text
        contacts.website = website.text
        contacts.contadress = AddressCore(context: viewContext)
        contacts.contadress?.street = street.text
        contacts.contadress?.suite = suite.text
        contacts.contadress?.city = city.text
        contacts.contadress?.zipcode = zipcode.text
        contacts.contadress?.geo = GeoCore(context: viewContext)
        contacts.contadress?.geo?.lat = String(0)
        contacts.contadress?.geo?.lng = String(0)
        contacts.company = CompanyCore(context: viewContext)
        contacts.company?.name = companyName.text
        contacts.company?.catchPhrase = catchPhrase.text
        contacts.company?.bs = bs.text
        
        do {
            try viewContext.save()
            DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
                self.send(contacts)
            }
        }catch {
            debugPrint(error)
        }
    }
    
    private func send(_ coreDataUser: ContactsCore) {
        let contacts = Contacts(id: Int(coreDataUser.id),
                                   name: coreDataUser.name!,
                                   phone: coreDataUser.phone!,
                                   username: coreDataUser.username!,
                                   email: coreDataUser.email!,
                                   website: coreDataUser.website!,
                                   company: Company(bs: coreDataUser.company?.bs!,
                                                        catchPhrase: coreDataUser.company?.catchPhrase!,
                                                        name: coreDataUser.company?.name!),
                                   address: Address(city: coreDataUser.contadress?.city!,
                                                        street: coreDataUser.contadress?.street!,
                                                        suite: coreDataUser.contadress?.suite!,
                                                        zipcode: coreDataUser.contadress?.zipcode!,
                                                        geo: Geo(lat: coreDataUser.contadress?.geo?.lat!,
                                                                     lng: coreDataUser.contadress?.geo?.lng!)))
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(contacts)
            
            if let url = URL(string: "https://jsonplaceholder.typicode.com/users") {
                var request = URLRequest(url:url)
                request.httpMethod = "POST"
                request.timeoutInterval = 10
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                let dataTask = session.dataTask(with: request)
                dataTask.resume()
            }
        }catch {
            debugPrint(error)
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*func textFieldShouldReturn (_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 2:
            if textField.isValidEmail() && textField == self.email {
                textField.setInvalidColor(valid: true)
            }
        default:
            <#code#>
        }
    }
    
    func isValidEmail() -> Bool {
        return (self.text?.contains("@"))! && (self.text?.contains(".com"))!
    }
    
    func setInvalidColor(valid: Bool) {
        if valid == true {
            self.layer.borderColor = UIColor(red: 240/255, gree: 240/255, blue: 240/255, alpha 1).cgColor = UIColor.red.cgColor
        }
    }*/
}

extension InserirTableViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let response = task.response as? HTTPURLResponse, response.statusCode == 201 {
            print("Operação concluida!")
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        if let erro = error {
            debugPrint(erro)
            DispatchQueue.main.async{[unowned self] in
                let ac = UIAlertController(title: "Erro!",
                                           message: erro.localizedDescription,
                                           preferredStyle: .alert)
                ac.addAction(UIAlertAction(title:"OK!",
                                           style: .default,
                                           handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
