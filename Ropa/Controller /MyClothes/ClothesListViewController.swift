//
//  ClothesListViewController.swift
//  Ropa
//
//  Created by Chen Hsin on 2018/7/12.
//  Copyright © 2018年 Chen Hsin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class ClothesListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ClotheseManagerDelegate {
    
    
    @IBOutlet weak var clothesCollectionView: UICollectionView!
    
    var fireUploadDic: [String:Any]?
    var clothing: [Clothes] = []
    var ref: DatabaseReference?

    
    func manager(_ manager: ClothesManager, didfetch Clothing: [Clothes]) {
        clothing = Clothing
        self.clothesCollectionView.reloadData()
    }
    
    func manager(_ manager: ClothesManager, didFaithWith error: Error) {
        //skip
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clothing.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ClothesListViewCell
        
         //圖片呈現部分
        if let dataDic = fireUploadDic {
            let keyArray = Array(dataDic.keys)
            if let imageUrlString = dataDic[keyArray[indexPath.row]] as? String {
                if let imageUrl = URL(string: imageUrlString) {
                    URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                        if error != nil {
                            print("Download Image Task Fail: \(error!.localizedDescription)")
                        }
                        else if let imageData = data {
                            print("This is Image:",data)
                            DispatchQueue.main.async {
                                cell.imageView.image = UIImage(data: imageData)
                            }
                        }
                    } .resume()
                }
            }
        }
        //圖片呈現部分
        
        let clothes = clothing[indexPath.row]
        cell.brandLabel.text = clothes.brand
        return cell
    }
    

//    //從這邊開始
//    func downloadImage() -> UIImage {
//        let storage = Storage.storage()
//        var reference: StorageReference!
//        storage.c
//        return image
//
//    }
//
//
   
    let clothesManager = ClothesManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //圖片呈現部分
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("clothes")
        let query = databaseRef.queryOrdered(byChild: "owner").queryEqual(toValue: "\(uid)")
        databaseRef.observe(.value) { (snapshot) in
            if let uploadDataDic = snapshot.value as? [String: Any] {
                self.fireUploadDic = uploadDataDic
                self.clothesCollectionView.reloadData()
            }
        }
        //圖片呈現部分
    
        if Auth.auth().currentUser?.uid != nil {
            clothesManager.delegate = self
            clothesManager.getClothes()
        }
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
