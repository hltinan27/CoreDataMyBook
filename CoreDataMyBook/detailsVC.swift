//
//  detailsVC.swift
//  CoreDataMyBook
//
//  Created by inan on 12.05.2018.
//  Copyright © 2018 inan. All rights reserved.
//

import UIKit
import CoreData

class detailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameText: UITextField!
  @IBOutlet weak var artistNameText: UITextField!
  @IBOutlet weak var paintYear: UITextField!
  var chosenPainting = ""
  
    override func viewDidLoad() {
        super.viewDidLoad()

      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
      
      fetchRequest.predicate = NSPredicate(format: "name = %@", self.chosenPainting)
      fetchRequest.returnsObjectsAsFaults = false
      
      
      do {
        
        let results = try context.fetch(fetchRequest)
        
        if results.count > 0 {
          
          for result in results as! [NSManagedObject] {
            
            if let name = result.value(forKey: "name") as? String {
              nameText.text = name
            }
            
            if let year = result.value(forKey: "year") as? Int {
              paintYear.text = String(year)
            }
            
            if let artist = result.value(forKey: "artist") as? String {
              artistNameText.text = artist
            }
            
            if let imageData = result.value(forKey: "image") as? Data {
              let image = UIImage(data: imageData)
              self.imageView.image = image
            }
            
          }
          
          
        }
        
      } catch {
        print("error")
      }
  
      imageView.isUserInteractionEnabled = true
      let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailsVC.selectImage))
      imageView.addGestureRecognizer(gestureRecognizer)
      
  }
  
  
  @objc func selectImage() {
    
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = .photoLibrary
    picker.allowsEditing = true
    present(picker, animated: true, completion: nil)
    
  }
  
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
    self.dismiss(animated: true, completion: nil)
  }

  @IBAction func saveButtonClicked(_ sender: UIButton) {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    let newArt = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
    //attributes
    newArt.setValue(nameText.text, forKey: "name")
    newArt.setValue(artistNameText.text, forKey: "artist")
    
    if let year = Int(paintYear.text!) {
      newArt.setValue(year, forKey: "year")
    }
    
    let data = UIImageJPEGRepresentation(imageView.image!, 0.5)
    newArt.setValue(data, forKey: "image")
    
    do {
      try context.save()
      print("succesful")
    } catch {
      print("error")
    }
    
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPainting"), object: nil)
    self.navigationController?.popViewController(animated: true)
    
    
  }
}
