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
    private let calendarViewModel = MSCalendarViewModel()
    private let eventStore: EKEventStore = EKEventStore()
    private var collectionViewSelected: IndexPath?
    private var didSelectCollection = false
    // To find whether it's first Launch of the App
    private var isFirstTimeLaunch : Bool = false
    // Maintain the Last Offset Of Scroll
    private var lastContentOffset: CGFloat = 0
    private var lastContentOffsetOfCollectionView: CGFloat = 0
    private var tableViewStartedScroll : Bool = false
    private var collectionViewStartedScroll : Bool = false
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Maintaining a bool to identify the first launch
        isFirstTimeLaunch = true
        registerCells()
        checkEventStoreAccessForCalendar()
        calendarViewModel.addObserver(self, forKeyPath: MSConstants.kIsEventSaved, options: [.old, .new, .initial], context: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstTimeLaunch {
            // Scroll to today's date
            showTodaysday(index: MSDateManager.dateManager.indexForToday(), animated: false)
        }
        self.hidesBottomBarWhenPushed = true
        isFirstTimeLaunch = false
    }
    
    // KVO observer for Events Saved Property 
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == MSConstants.kIsEventSaved {
            if calendarViewModel.isEventSaved == true {
                // getting access of main queue before doing any UI Operations
                DispatchQueue.main.async {
                    self.calendarTableView.reloadData()
                }
            }
        }
    }
    
    deinit {
        calendarViewModel.removeObserver(self, forKeyPath: MSConstants.kIsEventSaved)
    }
    
    private func registerCells() {
        calendarCollectionView.register(UINib(nibName: MSConstants.kCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: MSConstants.kCollectionViewCell)
        calendarTableView.register(UINib(nibName: MSConstants.kTableViewCell, bundle: Bundle.main), forCellReuseIdentifier: MSConstants.kTableViewCell)
    }
    // checking whether the access of calendar has been provided or not
    private func checkEventStoreAccessForCalendar() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch status {
        case .authorized: calendarViewModel.accessGrantedForCalendar(eventStore : eventStore)
        case .notDetermined: requestForCalendarAccess()
        case .denied, .restricted: showAlert(title : MSConstants.kWarningTitle, message: MSConstants.kNoPermissionMessage)
        }
    }
    
    private func showAlert(title : String, message : String) {
        let alertController = UIAlertController(title: title, message:message , preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: MSConstants.kOkMessage, style: .cancel, handler: {action in})
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Ask the user for access to their Calendar
    private func requestForCalendarAccess() {
        eventStore.requestAccess(to: .event) {[weak self] granted, error in
            if granted {
                DispatchQueue.main.async {
                    self?.calendarViewModel.accessGrantedForCalendar(eventStore : (self?.eventStore)!)
                    self?.calendarViewModel.createEventForToday()
                }
            }
        }
    }
    // Scroll User to today's Date
    private func showTodaysday(index : Int, animated : Bool) {
        let indexPath = IndexPath(row: index, section: 0)
        
        calendarCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        calendarTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        calendarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.topItem?.title = MSDateHelper().monthStringCompleteFor(index: index)
        }
    }
    
}

extension MSCalendarViewController : UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MSDateManager.dateManager.totalDays()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MSConstants.kTableViewCell) as? MSEventTableViewCell else {
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
    //
    func scrollTableView(_ scrollView: UIScrollView) {
        collectionViewStartedScroll = false
        tableViewStartedScroll = true
        if tableViewStartedScroll && scrollView == calendarTableView {
            if (self.lastContentOffset < calendarTableView.contentOffset.y) {
                // Animating The Constraint update so that The transition is not abrupt

                UIView.animate(withDuration: 0.3, animations: {
                    self.collectionViewHeightConstraint.constant = CGFloat(MSConstants.kCollectionViewHeightNotExpanded)
                    self.calendarCollectionView.updateConstraints()
                })
            }
            self.lastContentOffset = calendarTableView.contentOffset.y
        }
    }
    
    func scrollCollectionView(_ scrollView: UIScrollView) {
        if collectionViewStartedScroll && scrollView == calendarCollectionView {
            if lastContentOffsetOfCollectionView > calendarCollectionView.contentOffset.y {
                // Animating The Constraint update so that The transition is not abrupt
                UIView.animate(withDuration: 0.3, animations: {
                    self.collectionViewHeightConstraint.constant = CGFloat(MSConstants.kCollectionViewHeightExpanded)
                    self.calendarCollectionView.updateConstraints()
                })
            }
            lastContentOffsetOfCollectionView = calendarCollectionView.contentOffset.y
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard isFirstTimeLaunch == false else {
            return
        }
        guard scrollView == calendarTableView else {
            if !tableViewStartedScroll {
                collectionViewStartedScroll = true
                scrollCollectionView(scrollView)
            }
            return
        }
        scrollTableView(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isFirstTimeLaunch == false else {
            return
        }
        guard scrollView == calendarTableView else {
            if !tableViewStartedScroll {
                collectionViewStartedScroll = true
                scrollCollectionView(scrollView)
            }
            return
        }
        // Scroll TableView and update the constraint of Collection view accordingly
        scrollTableView(scrollView)
        
        // To make the circle flow as we are Scrolling the TableView
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
                self.title = cell.model.titleMonth
            }
        }
    }
    
    // Resetting the boolean Variables to there default values
    private func resetBoolToDefaultValues() {
        tableViewStartedScroll = false
        collectionViewStartedScroll = false
        didSelectCollection = false
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        resetBoolToDefaultValues()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        resetBoolToDefaultValues()
    }
    
    private func openEventController(indexPath: IndexPath) {
        guard self.calendarViewModel.defaultCalendar != nil else {
            checkEventStoreAccessForCalendar()
            return
        }
        
        let model = calendarViewModel.fetchModel(indexPath: indexPath)
        if let event = model.eventModel {
            if let eventViewController = UIStoryboard(name: MSConstants.kStoryBoardName, bundle: nil).instantiateViewController(withIdentifier: MSConstants.kEventViewController) as? EKEventViewController {
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
        guard let cell = calendarCollectionView.dequeueReusableCell(withReuseIdentifier: MSConstants.kCollectionViewCell, for: indexPath) as? MSDateCollectionViewCell else {
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

// delegate methods of EventController

extension MSCalendarViewController : EKEventEditViewDelegate, EKEventViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        // Dismiss the modal view controller
        self.calendarTableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func eventEditViewControllerDefaultCalendar(forNewEvents controller: EKEventEditViewController) -> EKCalendar {
        return self.calendarViewModel.defaultCalendar!
    }
    
    public func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        self.calendarTableView.reloadData()
    }
}

