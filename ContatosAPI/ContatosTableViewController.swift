//
//  ContatosTableViewController.swift
//  ContatosAPI
//
//  Created by Rafael Franca on 28/09/17.
//  Copyright © 2017 Rafael Franca. All rights reserved.
//

import UIKit
import CoreData

class ContatosTableViewController: UITableViewController, URLSessionDataDelegate {

    var jsonData = Data()
    var contacts = [Contacts]()
    
    var container: NSPersistentContainer? = AppDelegate.persistentContainer {
        didSet {
            updateUI()
        }
    }
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<ContactsCore>?
    
    private func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<ContactsCore> = ContactsCore.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            
            fetchedResultsController = NSFetchedResultsController<ContactsCore>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cfg = URLSessionConfiguration.default
        cfg.allowsCellularAccess = true
        cfg.networkServiceType = .default
        cfg.requestCachePolicy = .returnCacheDataElseLoad
        cfg.isDiscretionary = true
        cfg.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 10, diskPath: NSTemporaryDirectory())

        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 5
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)

        let session = URLSession(configuration: cfg, delegate: self, delegateQueue: queue)

        if let url = URL(string: "https://jsonplaceholder.typicode.com/users") {
            var request = URLRequest(url:url)
            request.timeoutInterval = 10
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let dataTask = session.dataTask(with: request)
            dataTask.resume()
        }
        updateUI()
    }
        

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)

        if let user = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = user.username
        }
        return cell
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        jsonData.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
       
        do {
            let decoder = JSONDecoder()
            contacts = try decoder.decode([Contacts].self, from: jsonData)
            
            let dao = ContactsDAO()
            dao.saveContacts(contacts: contacts, withPersistentContainer: container!)
            
            DispatchQueue.main.async{[unowned self] in
                self.updateUI()
            }
        } catch  {
            debugPrint(error)
        }
    }
}
    
    extension ContatosTableViewController: NSFetchedResultsControllerDelegate {
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.beginUpdates()
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                        didChange sectionInfo: NSFetchedResultsSectionInfo,
                        atSectionIndex sectionIndex: Int,
                        for type: NSFetchedResultsChangeType) {
            switch type {
            case .insert:
                tableView.insertSections([sectionIndex], with: .fade)
            case .delete:
                tableView.deleteSections([sectionIndex], with: .fade)
            default:
                break
            }
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                        didChange anObject: Any,
                        at indexPath: IndexPath?,
                        for type: NSFetchedResultsChangeType,
                        newIndexPath: IndexPath?) {
            switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            }
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.endUpdates()
        }
    }
