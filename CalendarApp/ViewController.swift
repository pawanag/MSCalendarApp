//
//  ViewController.swift
//  CalendarApp
//
//  Created by Pawan on 11/7/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var calendarTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private func registerCells() {
        calendarCollectionView.register(UINib(nibName: "MSDateCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "MSDateCollectionViewCell")
        calendarTableView.register(UINib(nibName: "MSEventTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "MSEventTableViewCell")
    }
    
}

extension ViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MSEventTableViewCell") as? MSEventTableViewCell {
            return cell
        }
        return UITableViewCell()
    }
    
    
}

extension ViewController : UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = calendarCollectionView.dequeueReusableCell(withReuseIdentifier: "MSDateCollectionViewCell", for: indexPath) as? MSDateCollectionViewCell {
            
            return cell
        }
        return UICollectionViewCell()
   }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width / 7
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
}
