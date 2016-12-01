//
//  ViewController.swift
//  StepCounter
//
//  Created by sc on 28/11/2016.
//  Copyright © 2016 sc. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mostStepsText: UITextView!
    @IBOutlet weak var mostStepsLabel: UILabel!
    @IBOutlet weak var stepCounterLabel: UILabel!
    @IBOutlet weak var stepCounterText: UITextView!
    @IBOutlet weak var lastSevenDays: UITableView!
    
    
    //Check if health kit is on device
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            print("hk")
            return HKHealthStore()
        } else {
            print("nil")
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.lastSevenDays.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        lastSevenDays.delegate = self
        lastSevenDays.dataSource = self
        
        //SETUP TEXT VIEWS AND LABELS
        mostStepsLabel.textAlignment = NSTextAlignment.center
        mostStepsText.textAlignment = NSTextAlignment.center
        stepCounterLabel.textAlignment = NSTextAlignment.center
        stepCounterText.textAlignment = NSTextAlignment.center
        
        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let dataTypesToWrite = NSSet(object: stepsCount!)
        let dataTypesToRead = NSSet(object: stepsCount!)
        
        healthStore?.requestAuthorization(toShare: dataTypesToWrite as? Set<HKSampleType>,read: dataTypesToRead as? Set<HKObjectType>,
            completion: {
                (success, error) in
                    if success {
                        print("SUCCESS")
                    } else {
                        print(error.debugDescription)
                    }
            }
        )
        updateSteps()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // This will call the updatesteps function every 5 seconds
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(ViewController.updateSteps), userInfo: nil, repeats: true)
    }
    
    func updateSteps() {
        let calendar = NSCalendar.current
        let startOfDay = calendar.startOfDay(for: NSDate() as Date)
        getSteps(currentTime: NSDate(), startOfDay: startOfDay as NSDate)
    }
    
    // QUERY THE HEALTH APP FOR STEP COUNT DATA
    func getSteps(currentTime: NSDate, startOfDay: NSDate) {
        //Mark:
        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay as Date, end: currentTime as Date, options: .strictStartDate)
        let interval: NSDateComponents = NSDateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startOfDay as Date, intervalComponents:interval as DateComponents)
        
        query.initialResultsHandler = { query, results, error in
            if error != nil {
                print("ERROR")
                return
            }
            DispatchQueue.main.async {
                do {
                    if results != nil {
                        results?.enumerateStatistics(from: startOfDay as Date, to: currentTime as Date) {
                            statistics, stop in
                            if let quantity = statistics.sumQuantity(){
                                let steps = Int(quantity.doubleValue(for: HKUnit.count()))
                                self.stepCounterText.text = String(format: "%d", steps)
                            } else {
                                print("QUANTITY WAS NIL")
                            }
                        }
                    }
                }
            }
        }
        self.healthStore?.execute(query)
    }
    
    
    // TABLE VIEW FUNCTIONS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DayTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DayTableViewCell
        
        let calendar = NSCalendar.current
        let startOfDay = calendar.date(byAdding: .day, value: indexPath.row, to: NSDate() as Date)
        //let endOfDay = startOfDay?.addingTimeInterval(86400)
       
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.string(from: startOfDay!)
        
        cell.dayOfTheWeek.text = dayOfWeekString
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}



