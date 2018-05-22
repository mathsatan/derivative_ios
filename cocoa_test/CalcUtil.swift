//
//  CalcUtil.swift
//  cocoa_test
//
//  Created by max on 5/20/18.
//  Copyright © 2018 max. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CalcUtil {
    static func req(_ url: String) -> MathResult {
        let res: MathResult = MathResultOk("", "", "")
        
        
        return res
    }
    class MathResult {
        //func isOk() -> Bool
    }
    
    class MathResultOk: MathResult {
        let problem: String
        let solution: String
        let plotUrl: String
        init(_ problem: String, _ solution: String, _ plotUrl: String) {
            self.problem = problem
            self.solution = solution
            self.plotUrl = plotUrl
        }
    }
    class MathResultFail: MathResult {
        let errorMessage: String
        init(_ error: String) {
            self.errorMessage = error
        }
    }
}
