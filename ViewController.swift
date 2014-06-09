//
//  ViewController.swift
//  store search v2
//
//  Created by leon on 6/7/14.
//  Copyright (c) 2014 Leon Chism. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var textField: UITextField!
    
    // for getting the JSON back from the store
    var data: NSMutableData = NSMutableData()

    // for the store search, this was an NSArray
    var tableViewData: NSArray = NSArray()
    
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // set up text field
        self.textField = UITextField(frame: CGRectMake(0, 0, self.view.bounds.size.width, 100))
        self.textField.backgroundColor = UIColor.redColor()
        
        self.view.addSubview(self.textField)
        
        // set up table view
        self.tableView = UITableView(frame: CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height - 100), style: UITableViewStyle.Plain)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.textField.delegate = self
        self.view.addSubview(self.tableView)
        
        // do the search
        //searchItunesFor("JQ Software")
        
    }

    
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
        
        
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        // either of these seems to work. the first is from the swift demo on youtube, the second is from the 
        // demo serching the iTunes store. since i'm converting, i'll use the second one.
        //let myNewCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as UITableViewCell
        let myNewCell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "myCell")
        
        
        // from the todo list:
        // myNewCell.text = self.tableViewData[indexPath.row]
        
        var rowData: NSDictionary = self.tableViewData[indexPath.row] as NSDictionary
        
        myNewCell.text = rowData["trackName"] as String
        
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        var urlString: NSString = rowData["artworkUrl60"] as NSString
        var imgURL: NSURL = NSURL(string: urlString)
        
        // Download an NSData representation of the image at the URL
        var imgData: NSData = NSData(contentsOfURL: imgURL)
        myNewCell.image = UIImage(data: imgData)
        
        // Get the formatted price string for display in the subtitle
        var formattedPrice: NSString = rowData["formattedPrice"] as NSString
        
        myNewCell.detailTextLabel.text = formattedPrice
        
        return myNewCell
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        
        // tableViewData.append(textField.text)
        searchItunesFor(textField.text)
        textField.text = ""
        // self.tableView.reloadData()
        
        textField.resignFirstResponder()
        return true
    } // called when 'return' key pressed. return NO to ignore.
    
    
    
    //
    //
    // these are the classes for searching iTunes
    //
    //
    func searchItunesFor(searchTerm: String) {
        
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        var itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        var escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=software"
        var url: NSURL = NSURL(string: urlPath)
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)
        
        println("Search iTunes API at URL \(url)")
        
        connection.start()
    }
    
    //
    // for getting data back from the NSURLConnection
    //
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        // Recieved a new request, clear out the data object
        self.data = NSMutableData()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        // Append the recieved chunk of data to our data object
        self.data.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        // Request complete, self.data should now hold the resulting info
        // Convert the retrieved data in to an object through JSON deserialization
        
        println("got here")
        
        var err: NSError
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options:    NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        
        println(jsonResult)
        
        if jsonResult.count>0 && jsonResult["results"].count>0 {
            var results: NSArray = jsonResult["results"] as NSArray
            self.tableViewData = results
            self.tableView.reloadData()
            
        }
    }

}
