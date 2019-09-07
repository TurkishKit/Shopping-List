//
//  ViewController.swift
//  Shopping List
//
//  Created by Ege Sucu on 26.06.2019.
//  Copyright © 2019 Ege Sucu. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
//    TableView Standart Fonksiyonları
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "listItem") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = shoppingItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let remove = UIContextualAction(style: .destructive, title: "Remove") { (action, UIView, (Bool)->Void) in
            self.removeItem(listItem: self.shoppingItems[indexPath.row])
            self.shoppingItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
        
        return UISwipeActionsConfiguration(actions: [remove])
    }
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let update = UIContextualAction(style: .normal, title: "Update") { (action, UIView, (Bool) -> Void) in
            self.updateItem(listItem: self.shoppingItems[indexPath.row])
            self.fetchItems()
            tableView.reloadData()
        }
        update.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
       
        return UISwipeActionsConfiguration(actions: [update])
    }
    
 
    @IBOutlet weak var shoppingTableView: UITableView!
    
    var shoppingItems = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchItems()

        
    }
    
    /**
     createItem fonksiyonu bir string alarak bununla bir obje yaratır ve veritabanına ekler.
     
     - parameters:
        - listItem: Alışveriş listesine ekleyeceğimiz yeni ürünün String değeri.
 
     */
    
    func createItem(listItem: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Bag", in: managedContext)!
        
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        
        item.setValue(listItem, forKey: "item")
        
        do{
            try managedContext.save()
        } catch let error{
            print("Item can't be created: \(error.localizedDescription)")
        }
        
    }
    
    /**
     fetchItems veritabanındaki kayıtlı verileri bularak tabloya yerleştirir.
     
     */
    func fetchItems(){
        shoppingItems.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bag")
        
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            
            for item in fetchResults as! [NSManagedObject]{
                
                shoppingItems.append(item.value(forKey: "item") as! String)
                
            }
            shoppingTableView.reloadData()
            
        } catch let error{
            print(error.localizedDescription)
        }
        
    }
    
    
    func removeItem(listItem: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bag")
        fetchRequest.predicate = NSPredicate(format: "item = %@", listItem)
        
        if let result = try? managedContext.fetch(fetchRequest){
            for item in result{
                managedContext.delete(item)
            }
            
            do {
                try managedContext.save()
                print("Items Saved")
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    func updateItem(listItem: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bag")
        fetchRequest.predicate = NSPredicate(format: "item = %@", listItem)
        
        let popup = UIAlertController(title: "Update Item", message: "Update item in your bag.", preferredStyle: .alert)
        popup.addTextField { (textField) in
            textField.placeholder = "Item"
        }
        let saveAction = UIAlertAction(title: "Add", style: .default) { (_) in
            
            do {
                let result = try managedContext.fetch(fetchRequest)
                
                let item = result[0]
                item.setValue(popup.textFields?.first?.text ?? "Error", forKey: "item")
            } catch let error {
                print(error.localizedDescription)
            }
            
            self.fetchItems()

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        popup.addAction(saveAction)
        popup.addAction(cancelAction)
        self.present(popup, animated: true, completion: nil)
        
        
        
    }
    
    /**
     addTapped fonksiyonu kullanıcı + butonuna tıkladığında çalışacak aksiyonları başlatır
     
     - parameters:
        - sender: Hangi itemin fonksiyona yollandığını belirtir.
     
     */
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let popup = UIAlertController(title: "Add Item", message: "Add Items into your bag.", preferredStyle: .alert)
        popup.addTextField { (textField) in
            textField.placeholder = "Item"
        }
        let saveAction = UIAlertAction(title: "Add", style: .default) { (_) in
            self.createItem(listItem: popup.textFields?.first?.text ?? "Error")
            self.fetchItems()
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        popup.addAction(saveAction)
        popup.addAction(cancelAction)
        self.present(popup, animated: true, completion: nil)
        
    }
    


}

