//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100
    
    let sentimentClassifier = TweetSentimentClassifier()
    // Instantiation using Twitter's OAuth Consumer Key and secret
    let swifter = Swifter(consumerKey: "your_consumer_key", consumerSecret: "Your_secret_key")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        fetchTweets()
    }
    
    
    func fetchTweets(){
         
        if let searchText = textField.text {
            
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                
                
                for i in 0 ..< self.tweetCount {
                    if let tweet = results[i]["full_text"].string{
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                self.makePrediction(with: tweets)
                
                
                
            }) { (error) in
                print("there was an error with the twitter api request: \(error)")
            }
            
            
            
        }
        
        
    }
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]){
        do{
            
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for pred in predictions{
                print(pred.label)
                
                let sentiment = pred.label
                
                if sentiment == "Pos" {
                    sentimentScore += 1
                }else if sentiment == "Neg"{
                    sentimentScore -= 1
                }
            }
            
            UpdateUI(with: sentimentScore)
               
            
        } catch{
            print("There was an error with making a prediction, \(error)")
        }
    }
    
    
    
    func UpdateUI(with sentimentScore: Int){
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
        }else if sentimentScore > 10 {
            self.sentimentLabel.text = "😀"
        }else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        }else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        }else if sentimentScore > -10 {
            self.sentimentLabel.text = "😕"
        }else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
        }else{
            self.sentimentLabel.text = "🤮"
        }
    }
    
    
}
