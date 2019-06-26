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

