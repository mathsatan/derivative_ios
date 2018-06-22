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

class ViewController: UIViewController, UITextFieldDelegate {
    //private let SERVICE_URL = "http://localhost:9000/evaluate"
    private let SERVICE_URL = "https://derivative-service.herokuapp.com/"
    
    @IBOutlet weak var expressionText: UITextField!
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var latexView: UIView!
    
    @IBOutlet weak var plotImage: UIImageView!
    private func onRequestComplete(_ error: String? = nil) -> Void {
        resultLabel.text = ""
        if let e: String = error {
            print(e)
            resultLabel.text = e
            self.latexView.subviews.forEach { $0.removeFromSuperview() }
            self.plotImage.image = nil
        }
        self.progressIndicator.stopAnimating()
    }
    
    @IBAction func onClick(_ sender: UIButton) {
        guard let expression: String = expressionText.text, expression != "" else {
            return
        }
        progressIndicator.startAnimating()
        self.resultLabel.text = ""
        
        let data = ["expression": "\(expression)"]
        Alamofire.request(SERVICE_URL + "evaluate",
                          method: .post,
                          parameters: data,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { (responseData) -> Void in
            if (responseData.result.value == nil) {
                self.onRequestComplete("Result is null")
            } else {
                guard let value = responseData.result.value else {
                    self.onRequestComplete("Fetching value fails")
                    return
                }
                let swiftyJsonVar = JSON(value)
                
                if let mathError = swiftyJsonVar["math_error"].string {
                    self.onRequestComplete(mathError)
                } else {
                    guard let mathFunc = swiftyJsonVar["MathFunc"].rawString() else {
                        self.onRequestComplete("Fetching 'MathFunc' key fails")
                        return
                    }
                    guard let mathResultFunc = swiftyJsonVar["MathResultFunc"].rawString() else {
                        self.onRequestComplete("Fetching 'MathResultFunc' key fails")
                        return
                    }
                    
                    self.plotImage.image = nil
                    if let mathPlot = swiftyJsonVar["MathPlotFileName"].rawString() {
                        if mathPlot != "null" {
                            self.load2DPlot(mathPlot)
                        }
                    }
                    
                    let latexLabel: MTMathUILabel = MTMathUILabel()
                    latexLabel.latex = "Task: " + mathFunc + " \\\\ Result: " + mathResultFunc
                    latexLabel.sizeToFit()
                    self.latexView.subviews.forEach { $0.removeFromSuperview() }
                    self.latexView.addSubview(latexLabel)
                    self.onRequestComplete()
                }
            }
        }
    }
    
    fileprivate func load2DPlot(_ plotImageName: String) {
        plotImage.downloadedFrom(link: SERVICE_URL + "getRes/" + plotImageName)
        print(plotImageName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.expressionText.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.expressionText {
            self.expressionText.becomeFirstResponder()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.expressionText.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.expressionText.endEditing(true);
        return false;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// Extension for async image loading
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

