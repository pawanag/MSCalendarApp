//
//  ViewController.swift
//  CalendarApp
//
//  Created by Pawan on 11/7/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class ViewController: UIViewController {
    
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var calendarTableView: UITableView!
    let locationManager = MSLocationManager.sharedManager
    let calendarViewModel = MSCalendarViewModel()
    var eventStore: EKEventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        checkEventStoreAccessForCalendar()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showTodaysday(index: MSDateManager.dateManager.indexForToday(), animated: false)
    }
    
    private func checkEventStoreAccessForCalendar() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch status {
        case .authorized: calendarViewModel.accessGrantedForCalendar(eventStore : eventStore)
        case .notDetermined: requestForCalendarAccess()
        case .denied, .restricted:
            let alertController = UIAlertController(title: "Warning", message: "Permission not granted for Calendar", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: {action in})
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    // Ask the user for access to their Calendar
    private func requestForCalendarAccess() {
        eventStore.requestAccess(to: .event) {[weak self] granted, error in
            if granted {
                DispatchQueue.main.async {
                    self?.calendarViewModel.accessGrantedForCalendar(eventStore : (self?.eventStore)!)
                }
            }
        }
    }
    
    func showTodaysday(index : Int, animated : Bool) {
        let indexPath = IndexPath(row: index, section: 0)
        calendarCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        calendarTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        calendarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        
    }
    
    private func registerCells() {
        calendarCollectionView.register(UINib(nibName: "MSDateCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "MSDateCollectionViewCell")
        calendarTableView.register(UINib(nibName: "MSEventTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "MSEventTableViewCell")
    }
    
}

extension ViewController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MSDateManager.dateManager.totalDays()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MSEventTableViewCell") as? MSEventTableViewCell {
            cell.resetToDefaultValues()
            cell.setValues(indexPath: indexPath)
            if calendarViewModel.isEventAccessGiven {
                let events = calendarViewModel.fetchEvent(index: indexPath.row)
                cell.setEventInfo(events: events)
            }
            
            
            if let location = locationManager.userLocation {
                let timeInterval = round((MSDateManager.dateManager.dateForIndex(index: indexPath.row)?.timeIntervalSince1970)!) //events time
                
                let timeInInteger = Int(timeInterval)
                calendarViewModel.fetchWeatherInfoFor(time: String(timeInInteger),location : location, completion: { (weatherResult) in
                    DispatchQueue.main.async {
                        switch weatherResult {
                        case let .success(weather):
                            cell.setWeatherInfo(weather: weather)
                        case let .failure(error):
                            print("Error fetching weather: \(error)")
                        }
                    }
                })
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let events = calendarViewModel.fetchEvent(index: indexPath.row)
        if events.count > 0 {
            if let eventViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EKEventViewController") as? EKEventViewController {
                eventViewController.event = events[0]
                self.navigationController?.pushViewController(eventViewController, animated: true)
            }
        } else {
            let addController = EKEventEditViewController()
            // Set addController's event store to the current event store
            addController.eventStore = self.eventStore
            let event = EKEvent(eventStore: self.eventStore)
            event.startDate = MSDateManager.dateManager.dateForIndex(index: indexPath.row)
            event.endDate = MSDateManager.dateManager.dateForIndex(index: (indexPath.row+1))
            addController.event = event
            addController.editViewDelegate = self
            self.present(addController, animated: true, completion: nil)
        }
    }
    
}

extension ViewController : UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MSDateManager.dateManager.totalDays()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = calendarCollectionView.dequeueReusableCell(withReuseIdentifier: "MSDateCollectionViewCell", for: indexPath) as? MSDateCollectionViewCell {
            
            cell.resetToDefaultValues()
            cell.setValues(indexPath: indexPath)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width / 7
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MSDateCollectionViewCell {
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentInset)
    }
}

extension ViewController : EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        // Dismiss the modal view controller
        self.dismiss(animated: true) {

        }
    }
    func eventEditViewControllerDefaultCalendar(forNewEvents controller: EKEventEditViewController) -> EKCalendar {
        return self.calendarViewModel.defaultCalendar
    }
}
