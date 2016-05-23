//
//  ViewController.swift
//  YTDemo
//
//  Created by Gabriel Theodoropoulos on 27/6/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tblVideos: UITableView!
    
    @IBOutlet weak var segDisplayedContent: UISegmentedControl!
    
    @IBOutlet weak var viewWait: UIView!
    
    @IBOutlet weak var txtSearch: UITextField!
    
    var apiKey = "AIzaSyAFXvJP0aRZzENntE_iaigcJTYc-x93o1Y"
    var desiredChannelsArray = ["Apple", "Google", "Microsoft"]
    var channelIndex = 0
    var channelDataArray: Array<Dictionary<NSObject, AnyObject>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tblVideos.delegate = self
        tblVideos.dataSource = self
        txtSearch.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: IBAction method implementation
    
    @IBAction func changeContent(sender: AnyObject) {
        
    }
    
    
    // MARK: UITableView method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell()
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 140.0
    }
    
    
    // MARK: UITextFieldDelegate method implementation
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
}
extension ViewController{
    // HTTP Request
    func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void){
        let request = NSMutableURLRequest(URL: targetURL)
        request.HTTPMethod = "GET"
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration)
        let task = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                completion(data: data, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error)
            })
        }
        task.resume()
    }
    //Getting YouTube channel
    func getChannelDetails(useChannelIDParam: Bool){
        
        var urlString: String!
        if !useChannelIDParam{
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&forUsername=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
        }else{
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&id=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
        }
        var targetURL = NSURL(string: urlString)
        
        //HTTP Request Completion Handler
        performGetRequest(targetURL) { (data, HTTPStatusCode, error) in
            if HTTPStatusCode == 200 && error == nil{
                do{
                    //Convert the json data to a dictionary
                    let resultDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                    // Get the first dictionary JSON data to a dictionary
                    let items: AnyObject! = resultDict["items"] as AnyObject!
                    let firstItemDict = (items as! Array<AnyObject>)[0] as! Dictionary<NSObject, AnyObject>
                    
                    // Get the snippet dictionary that contains the desired data
                    let snippetDict = firstItemDict["snippet"] as! Dictionary<NSObject, AnyObject>
                    
                    // create a new dictionary to store only the values we care about
                    var desiredValueDict: Dictionary<NSObject, AnyObject> = Dictionary<NSObject, AnyObject>()
                    desiredValueDict["title"] = snippetDict["title"]
                    desiredValueDict["description"] = snippetDict["description"]
                    desiredValueDict["thumbnail"] = ((snippetDict["thumbnail"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"]
                    //Save the channel's uploaded videos playlists ID
                    desiredValueDict["playlistID"] = ((snippetDict["contentDetails"] as! Dictionary<NSObject, AnyObject>)["relatedPlaylists"] as! Dictionary<NSObject, AnyObject>)["uploads"]
                    
                    //Append the desitredValueDict dictionary to the following array
                    self.channelDataArray.append(desiredValueDict)
                    
                    //reload the tableView
                    self.tblVideos.reloadData()
                    
                    //Load the next channel data(if exist)
                    self.channelIndex += 1
                    if self.channelIndex < self.desiredChannelsArray.count{
                        self.getChannelDetails(useChannelIDParam)
                    }else{
                        self.viewWait.hidden = true
                    }
                }catch{
                    print("HTTP Error: \(HTTPStatusCode): \(error)")
                }
                
            }else{
                print("HTTP Status Code:  \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
            }
        }
        
    }
    
}
















