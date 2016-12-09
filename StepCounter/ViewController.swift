//
//  ViewController.swift
//  StepCounter
//
//  Created by sc on 28/11/2016.
//  Copyright © 2016 sc. All rights reserved.
//

import UIKit
import HealthKit
import Charts

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var stepCounterLabel: UILabel!
    @IBOutlet weak var stepCounterText: UITextView!
    @IBOutlet weak var lastSevenDays: UITableView!
    @IBOutlet weak var barChartView: BarChartView!
    let days = ["Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"]
    var stepChartValues = [Double]()
    var IsAuthorised: Bool = false
    
    //Check if health kit is on device
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        lastSevenDays.delegate = self
        lastSevenDays.dataSource = self
        
        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let dataTypesToWrite = NSSet(object: stepsCount!)
        let dataTypesToRead = NSSet(object: stepsCount!)
        
        healthStore?.requestAuthorization(toShare: dataTypesToWrite as? Set<HKSampleType>,read: dataTypesToRead as? Set<HKObjectType>,
            completion: {
                (success, error) in
                    if success {
                        self.IsAuthorised = true
                    } else {
                        print(error.debugDescription)
                    }
            })
        updateSteps()
        drawGraph()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // This will call the updatesteps function every 5 seconds
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(ViewController.updateSteps), userInfo: nil, repeats: true)
        if (IsAuthorised) {
            Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ViewController.drawGraph), userInfo: nil, repeats: false)
        }
    }
    
    // DRAW THE GRAPH
    func drawGraph() {
        if(stepChartValues.count == 0) {stepChartValues = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]}
        setChart(dataPoints: days, values: stepChartValues)
        stepChartValues = []
    }
    
    //SET UP THE BAR CHART: PASS DATA TO IT AND BUILD THE GRAPH, SET COLORS ETC...
    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."
        barChartView.backgroundColor = UIColor.black
        
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<days.count-1{
            let chartEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(chartEntry)
        }
        let barChartDataSet = BarChartDataSet(values: dataEntries, label: "Number of steps")
        
        barChartDataSet.stackLabels = days
        barChartDataSet.colors = [UIColor.red]
        barChartDataSet.valueColors = [UIColor.white]
        barChartDataSet.barBorderColor = UIColor.white
        barChartDataSet.valueTextColor = UIColor.white
        
        barChartView.chartDescription?.text = ""
        barChartView.xAxis.labelTextColor = UIColor.white
        barChartView.xAxis.gridColor = UIColor.white
        barChartView.xAxis.axisLineColor = UIColor.white
        barChartView.leftAxis.labelTextColor = UIColor.white
        barChartView.rightAxis.labelTextColor = UIColor.white
        barChartView.animate(xAxisDuration: 0.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        
        let chartData = BarChartData(dataSet: barChartDataSet)
        barChartView.data = chartData
    }
    
    // UPDATE DAILY STEPS
    func updateSteps() {
        let calendar = NSCalendar.current
        let startOfDay = calendar.startOfDay(for: NSDate() as Date)
        getSteps(endTime: NSDate(), startOfDay: startOfDay as NSDate, completion: { stepString in
            self.stepCounterText.text = stepString
        })
    }
    

    // QUERY THE HEALTH APP FOR STEP COUNT DATA
    func getSteps(endTime: NSDate, startOfDay: NSDate, completion: @escaping (String) -> Void) {
        var steps: Int = 0
        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay as Date, end: endTime as Date, options: .strictStartDate)
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
                        results?.enumerateStatistics(from: startOfDay as Date, to: endTime as Date) {
                            statistics, stop in
                            if let quantity = statistics.sumQuantity(){
                                steps = Int(quantity.doubleValue(for: HKUnit.count()))
                            } else {
                                print("QUANTITY WAS NIL")
                            }
                        }
                        print("steps ",steps)
                    }
                }
                completion(String(format: "%d", steps))
                
            }
        }
        self.healthStore?.execute(query)
    }
    
    
    // TABLE VIEW FUNCTIONS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Cell setup
        let cellIdentifier = "DayTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DayTableViewCell
        
        let calendar = NSCalendar.current
        let startOfDay = calendar.date(byAdding: .day, value: -(indexPath.row+1), to: calendar.startOfDay(for: NSDate() as Date) as Date)
        let endOfDay = startOfDay?.addingTimeInterval(86399)
        
        //Get the day of the week
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.string(from: startOfDay!)
        cell.dayOfTheWeek.text = dayOfWeekString
        
        //Border Code
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.red.cgColor
        
        //get the steps for the label
        getSteps(endTime: endOfDay! as Date as NSDate, startOfDay: startOfDay! as Date as NSDate, completion: { stepString in
            cell.stepsForDay.text = stepString
            self.stepChartValues.append(Double(stepString)!)
        })
        return cell
    }
}




