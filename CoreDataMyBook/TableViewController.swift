//
//  ViewController.swift
//  CoreDataMyBook
//
//  Created by inan on 12.05.2018.
//  Copyright © 2018 inan. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
  
  var nameArray = [String]()
  var yearArray = [Int]()
  var artistArray = [String]()
  var imageArray = [UIImage]()
  var selectedPainting = ""
  
  override func viewWillAppear(_ animated: Bool) {
    NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.getInfo), name: NSNotification.Name(rawValue: "newPainting"), object: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
      getInfo()
  }


  
  @objc func getInfo() {
    
    nameArray.removeAll(keepingCapacity: false)
    yearArray.removeAll(keepingCapacity: false)
    imageArray.removeAll(keepingCapacity: false)
    artistArray.removeAll(keepingCapacity: false)
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
    fetchRequest.returnsObjectsAsFaults = false
    
    do {
      
      let results = try context.fetch(fetchRequest)
      
      if results.count > 0 {
        
        for result in results as! [NSManagedObject] {
          
          if let name = result.value(forKey: "name") as? String {
            self.nameArray.append(name)
          }
          
          if let year = result.value(forKey: "year") as? Int {
            self.yearArray.append(year)
          }
          
          if let artist = result.value(forKey: "artist") as? String {
            self.artistArray.append(artist)
          }
          
          if let imageData = result.value(forKey: "image") as? Data {
            let image = UIImage(data: imageData)
            self.imageArray.append(image!)
          }
          
          self.tableView.reloadData()
          
        }
        
      }
      
      
    } catch {
      print("error")
    }
    
  }
  
  //getting context
  func getContext () -> NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.persistentContainer.viewContext
  }
  
  
  //function for deleting respective datas
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      
      let moc = getContext()
      
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
      
      let result = try? moc.fetch(fetchRequest)
      let resultData = result as! [NSManagedObject]
      
      for object in resultData {
        if let name = object.value(forKey: "name") as? String {
          if name == nameArray[indexPath.row] {
            moc.delete(object)
            nameArray.remove(at: indexPath.row)
            yearArray.remove(at: indexPath.row)
            imageArray.remove(at: indexPath.row)
            artistArray.remove(at: indexPath.row)
            self.tableView.reloadData()
            do {
              try moc.save()
              print("saved!")
            } catch let error as NSError  {
              print("Could not save \(error), \(error.userInfo)")
            } catch {
              
            }
            break
          }
        }
      }
      
      
    }
  }
  
  
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return nameArray.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    cell.textLabel?.text = nameArray[indexPath.row]
    return cell
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toDetail" {
      let destinationVC = segue.destination as! detailsVC
      destinationVC.chosenPainting = selectedPainting
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedPainting = nameArray[indexPath.row]
    performSegue(withIdentifier: "toDetail", sender: nil)
  }
  
  
  @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
    performSegue(withIdentifier: "toDetail", sender: nil)
  }
  
  
}

