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

class MSCalendarViewController: UIViewController {
    
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var calendarTableView: UITableView!
    let calendarViewModel = MSCalendarViewModel()
    var eventStore: EKEventStore = EKEventStore()
    private var collectionViewSelected: IndexPath?
    private var didSelectCollection = false
    private var isFirstTimeLaunch : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isFirstTimeLaunch = true
        registerCells()
        checkEventStoreAccessForCalendar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstTimeLaunch {
            showTodaysday(index: MSDateManager.dateManager.indexForToday(), animated: false)
        }
        self.hidesBottomBarWhenPushed = true
        isFirstTimeLaunch = false
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
    
    private func showTodaysday(index : Int, animated : Bool) {
        let indexPath = IndexPath(row: index, section: 0)
        
        calendarCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        calendarTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        calendarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.topItem?.title = MSDateHelper().monthStringCompleteFor(index: index)
        }
    }
    
    private func registerCells() {
        calendarCollectionView.register(UINib(nibName: "MSDateCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "MSDateCollectionViewCell")
        calendarTableView.register(UINib(nibName: "MSEventTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "MSEventTableViewCell")
    }
    
}

extension MSCalendarViewController : UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MSDateManager.dateManager.totalDays()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MSEventTableViewCell") as? MSEventTableViewCell else {
            return UITableViewCell()
        }
        cell.model = calendarViewModel.fetchModel(indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openEventController(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? MSEventTableViewCell {
            cell.model = calendarViewModel.fetchModel(indexPath: indexPath)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == calendarTableView, didSelectCollection == false , isFirstTimeLaunch == false else {
            return
        }
        if let indexPaths = calendarTableView.indexPathsForVisibleRows, indexPaths.count > 0 {
            if let indexPathTableView = collectionViewSelected {
                if let cell = calendarCollectionView.cellForItem(at: indexPathTableView) as? MSDateCollectionViewCell {
                    cell.model.cellSelection = .none
                    cell.cellSelection = .none
                } else {
                    let model = calendarViewModel.fetchModel(indexPath: indexPathTableView)
                    model.cellSelection = .none
                }
                collectionViewSelected = nil
            }
            collectionViewSelected = indexPaths[0]
            let indexItem = IndexPath(item: indexPaths[0].row, section: indexPaths[0].section)
            calendarCollectionView.scrollToItem(at: indexItem, at: UICollectionViewScrollPosition.bottom, animated: false)
            if let cell = calendarCollectionView.cellForItem(at: indexItem) as? MSDateCollectionViewCell {
                cell.model.cellSelection = .selected
                cell.cellSelection = .selected
                self.navigationController?.navigationBar.topItem?.title = cell.model.titleMonth
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == calendarTableView else {
            return
        }
        didSelectCollection = false
    }
    
    private func openEventController(indexPath: IndexPath) {
        guard self.calendarViewModel.defaultCalendar != nil else {
           checkEventStoreAccessForCalendar()
            return
        }
        
        let model = calendarViewModel.fetchModel(indexPath: indexPath)
        if let event = model.eventModel {
            if let eventViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EKEventViewController") as? EKEventViewController {
                eventViewController.event = event
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

extension MSCalendarViewController : UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MSDateManager.dateManager.totalDays()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = calendarCollectionView.dequeueReusableCell(withReuseIdentifier: "MSDateCollectionViewCell", for: indexPath) as? MSDateCollectionViewCell else {
            return UICollectionViewCell()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? MSDateCollectionViewCell {
            cell.model = calendarViewModel.fetchModel(indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width / 7
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MSDateCollectionViewCell {
            cell.model.cellSelection = .selected
            cell.cellSelection = .selected
            self.navigationController?.navigationBar.topItem?.title = cell.model.titleMonth
        }
        didSelectCollection = true
        calendarTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        if let previousIndexPath = collectionViewSelected {
            if let cell = collectionView.cellForItem(at: previousIndexPath) as? MSDateCollectionViewCell {
                cell.model.cellSelection = .none
                cell.cellSelection = .none
            } else {
                let model = calendarViewModel.fetchModel(indexPath: previousIndexPath)
                model.cellSelection = .none
            }
        }
        collectionViewSelected = indexPath
    }
}

extension MSCalendarViewController : EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        // Dismiss the modal view controller
        self.calendarTableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func eventEditViewControllerDefaultCalendar(forNewEvents controller: EKEventEditViewController) -> EKCalendar {
        return self.calendarViewModel.defaultCalendar!
    }
}

