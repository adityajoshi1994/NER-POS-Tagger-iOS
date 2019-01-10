//
//  ViewController.swift
//  NER-POS Tagger
//
//  Created by Aditya Joshi on 11/8/18.
//  Copyright © 2018 Aditya Joshi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    private class Pair{
        var word: String
        var tag: String
        
        init(word: String, tag: String){
            self.word = word
            self.tag = tag
        }
    }
    
    let POSMappingDictionary: Dictionary<String, String> = ["ADV" : "ADVERB", "NOUN": "NOUN", "ADP": "ADPOSITION", "NUM" : "NUMERAL", "DET" : "DETERMINER", "." : "NONE", "PRON" : "PRONOUN", "VERB" : "VERB", "PRT" : "PARTICLE", "X" : "NONE", "CONJ" : "CONJUNCTION", "ADJ" : "ADJECTIVE"]
    
    let NERMappingDictionary: Dictionary<String, String> = ["I-sportsteam": "Sports team", "I-product": "Product", "I-musicartist" : "Music artist", "B-musicartist": "Music artist", "B-movie" : "Movie", "I-movie" : "Movie", "I-other" : "Other", "B-other" : "Other", "I-person" : "Person", "B-facility" : "Facility", "I-facility" : "Facility", "B-company" : "Company", "B-person" : "Person", "O" : "NONE", "B-tvshow" : "TV show", "B-product" : "Product", "I-geo-loc" : "Geo-location", "B-geo-loc" : "Geo-location", "B-sportsteam" : "Sports team", "I-company" : "Company", "I-tvshow" : "TV show"]
    
    @IBOutlet weak var textView: UITextView!
    let voice = AVSpeechSynthesisVoice(language: "en-US")
    let synth = AVSpeechSynthesizer()
    var inputSentence: String = ""
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var isPOS: Bool = false
    private var POSTagPairings: [Pair] = []
    private var NERTagPairings: [Pair] = []
    private var tableData: [Pair] = []
    var tapGesture = UITapGestureRecognizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textView.delegate = self
        textView.text = "Type your text here..."
        textView.textColor = UIColor.lightGray
        tableView.dataSource = self
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openBrowserForSearch(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        let pair = tableData[indexPath.row]
        cell.wordLabel.text = pair.word
        cell.tagLabel.text = pair.tag
        if(!isPOS && cell.tagLabel.text != "NONE"){
            cell.wordLabel.textColor = UIColor.blue
        }else{
            cell.wordLabel.textColor = UIColor.black
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        
        //access the label inside the cell
        print(cell.wordLabel.text)
        if(!isPOS && cell.tagLabel.text != "NONE"){
            var chromeURL = "http://www.google.com/search?q=" + cell.wordLabel.text!
            chromeURL = chromeURL.replacingOccurrences(of: " ", with: "%20")
            print(chromeURL)
            UIApplication.shared.open(URL(string: chromeURL)!, options: [:], completionHandler: nil)
        }
        
        //or you can access the array object
        //print(Locations[indexPath.row])
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
            //textView.layer.borderWidth = 1
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type your text here..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func indexChanged(_ sender: AnyObject){
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            isPOS = false
            tableData = NERTagPairings
            tableView.reloadData()
        case 1:
            isPOS = true
            tableData = POSTagPairings
            tableView.reloadData()
        default:
            isPOS = false
        }
    }
    
    @IBAction func speakButton(_ sender: Any) {
        
        if(synth.isSpeaking){
            synth.stopSpeaking(at: AVSpeechBoundary.word)
        }
        let utterance: AVSpeechUtterance

        if(textView.textColor == UIColor.lightGray || textView.text.isEmpty){
            utterance = AVSpeechUtterance(string: "Nothing to say please type something in the textbox")
        }else{
            utterance = AVSpeechUtterance(string: textView.text)
        }
        utterance.voice = voice
        synth.speak(utterance)
    }
    
    
    
    @IBAction func submitButton(_ sender: Any) {
        var endpoint: String = "http://Your_end_point/api/gettags"
        guard !textView.text.isEmpty else {
            print("Textview is empty")
            return
        }
        //endpoint += textView.text
        guard var urlComponents = URLComponents(string: endpoint) else {
            print("Cannot create URL")
            return
        }
        self.textView.resignFirstResponder()
        urlComponents.queryItems = [URLQueryItem(name: "input", value: textView.text)]
        
        let urlRequest = URLRequest(url: urlComponents.url!)
        let session = URLSession.shared
        self.inputSentence = self.textView.text
        let task = session.dataTask(with: urlRequest){
            data, response, error in
            guard error == nil else{
                print("Error occurred while getting tags")
                print(error!)
                return
            }
            
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            do {
                guard let tagDict = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                
                self.processResponse(pDict: tagDict)
                self.tableData = []
                if(self.isPOS){
                    self.tableData = self.POSTagPairings
                }else{
                    self.tableData = self.NERTagPairings
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                print(tagDict)
                print(type(of: tagDict))
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
        
    }
    func UI(_ block: @escaping ()->Void) {
        
    }
    func processResponse(pDict: Dictionary<String, Any>){
        let pos = pDict["POS"] as? [String]
        let splitArray: [String.SubSequence] = self.inputSentence.split(separator: " ")
        POSTagPairings = []
        var i = 0
        for tag in pos! {
            POSTagPairings.append(Pair(word: String(splitArray[i]), tag: POSMappingDictionary[tag] ?? "X"))
            i += 1
        }
        
        let ner = pDict["NER"] as! [String]
        NERTagPairings = []
        i = 0
        var currWord: String = ""
        var currTag: String = ""
        while(i < ner.count){
            let firstChar: Character = ner[i][ner[i].index(ner[i].startIndex, offsetBy: 0)]
            switch firstChar{
            case "B","O":
                if(currWord.count > 0){
                    NERTagPairings.append(Pair(word: currWord.trimmingCharacters(in: .whitespacesAndNewlines), tag: currTag))
                }
                currWord = ""
                currWord = String(splitArray[i]) + " "
                currTag = NERMappingDictionary[ner[i]] ?? "X"
                break
            case "I":
                currWord = currWord + String(splitArray[i]) + " "
                break
            default:
                break
            }
            i += 1
        }
        if(currWord.count > 0){
            NERTagPairings.append(Pair(word: currWord.trimmingCharacters(in: .whitespacesAndNewlines), tag: currTag))
        }
        
        
    }
    
    @objc func openBrowserForSearch(_ sender: UITapGestureRecognizer){
        
    }
    
}

