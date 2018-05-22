//
//  ViewController.swift
//  cocoa_test
//
//  Created by max on 5/14/18.
//  Copyright © 2018 max. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import iosMath

class ViewController: UIViewController {
    private let SERVICE_URL = "https://math-deque.herokuapp.com/str/"
    
    @IBOutlet weak var expressionText: UITextField!
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var latexView: UIView!
    
    private func onRequestComplete(_ error: String? = nil) -> Void {
        resultLabel.text = ""
        if let e: String = error {
            print(e)
            resultLabel.text = e
        }
        self.progressIndicator.stopAnimating()
    }
    
    @IBAction func onClick(_ sender: UIButton) {
        guard let expression: String = expressionText.text else {
            return
        }
        progressIndicator.startAnimating()
        
        
        Alamofire.request(SERVICE_URL + expression).responseJSON { (responseData) -> Void in
            if (responseData.result.value == nil) {
                self.onRequestComplete("Result is null")
            } else {
                guard let value = responseData.result.value else {
                    self.onRequestComplete("Fetching value fails")
                    return
                }
                let swiftyJsonVar = JSON(value)
                guard let mathFunc = swiftyJsonVar["MathFunc"].rawString() else {
                    self.onRequestComplete("Fetching 'MathFunc' key fails")
                    return
                }
                guard let mathResultFunc = swiftyJsonVar["MathResultFunc"].rawString() else {
                    self.onRequestComplete("Fetching 'MathResultFunc' key fails")
                    return
                }
                print(mathFunc)
                print(mathResultFunc)
                let latexLabel: MTMathUILabel = MTMathUILabel()
                latexLabel.latex = "Task: " + mathFunc + " \\\\ Result: " + mathResultFunc
                latexLabel.sizeToFit()
                self.latexView.addSubview(latexLabel)
                self.onRequestComplete()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*let asyncQueue = DispatchQueue(label: "asyncQueue", attributes: .concurrent)
        
        asyncQueue.async {
            for i in 0 ... 10 {
                print("Async FIRST here\(i)")
            }
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

