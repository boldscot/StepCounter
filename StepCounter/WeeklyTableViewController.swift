//
//  WeeklyTableViewController.swift
//  StepCounter
//
//  Created by sc on 08/12/2016.
//  Copyright © 2016 sc. All rights reserved.
//

import UIKit

class WeeklyTableViewController: UITableViewController {
    var vc = ViewController()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "WeeklyTotalViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WeeklyTotalViewCell

        let calendar = NSCalendar.current
        let currentDay = calendar.date(byAdding: .day, value: -(indexPath.row*7), to: calendar.startOfDay(for: NSDate() as Date) as Date)
        let dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDay! as Date)
        let startDay = calendar.date(from: dateComponents)
        let endDay = startDay?.addingTimeInterval( -604799)
        let dateString = String(describing: startDay)
        
        vc.getSteps(endTime: startDay! as Date as NSDate, startOfDay: endDay! as Date as NSDate, completion: { stepString in
            cell.stepsLabel.text = "Steps: "+stepString
        })
        cell.weekLabel.text = "Week: "+getSubString(str: String(describing: dateComponents.weekOfYear), startIndex: 9, endIndex: -1)
        cell.startDateLabel.text = getSubString(str: dateString, startIndex: 9, endIndex: -16)
        cell.endDateLabel.text = getSubString(str: String(describing: endDay), startIndex: 9, endIndex: -16)
        
        //Border Code
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.white.cgColor

        return cell
    }
    
    // GET A SUBSTRING OF A GIVEN A STRING, START AND END INDEX
    func getSubString(str:String, startIndex:Int, endIndex:Int) -> String{
        let strRange = str.characters
        let newStr = strRange.index(strRange.startIndex, offsetBy: startIndex)..<strRange.index(strRange.endIndex, offsetBy: endIndex)
        return str[newStr]
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
