//
//  CombineZipSectionContainer.swift
//  CombineMarble
//
//  Created by Alfian Losari on 04/07/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Combine
import Foundation

class CombineZipSectionContainer: CombineSectionContainer {
    
    var isCombined = false
    var numbers1 = PassthroughSubject<String?, Error>()
    var numbers2 = PassthroughSubject<String?, Error>()
    var currentFirstLine: [String] = []
    var currentSecondLine: [String] = []
    
    var isLineCombined: Bool {
        return !currentFirstLine.isEmpty && !currentSecondLine.isEmpty
    }

    var sections: [SectionController.CombineCollection] {
        return [
            firstLine,
            secondLine,
            combinedLine
        ]
    }
    
    private lazy var firstLine: SectionController.CombineCollection = {
        var first = SectionController.CombineCollection(title: "Zip", items: [])
        first.container = self
        return first
    }()
    
    private lazy var secondLine: SectionController.CombineCollection  = {
        var second = SectionController.CombineCollection(title: " ", items: [])
        second.container = self
        return second
    }()
    
    private lazy var combinedLine: SectionController.CombineCollection  = {
        var second = SectionController.CombineCollection(title: " ", items: [])
        second.container = self
        return second
    }()
    
    private var randomValues: [String] {
        return [
            "1",
            "D",
            "3",
            "7",
            "B",
            "C",
            "9",
            "F"
            ].shuffled()
    }
    
    private lazy var sendValues: [String] = {
        return self.randomValues
    }()
    
    private func setupSubscription() {
        _ = numbers1.sink(receiveValue: { (value) in
            self.firstLine.items.append(SectionController.CombineItem(text: value))
            self.secondLine.items.append(SectionController.CombineItem(text: nil))
            NotificationCenter.default.post(name: combineDidChangeNotification, object: self.firstLine)
            NotificationCenter.default.post(name: combineDidChangeNotification, object: self.secondLine)
            if !self.isLineCombined {
                self.combinedLine.items.append(SectionController.CombineItem(text: nil))
                NotificationCenter.default.post(name: combineDidChangeNotification, object: self.combinedLine)
            }
        })
        
        _ = numbers2.sink(receiveValue: { (value) in
            self.firstLine.items.append(SectionController.CombineItem(text: nil))
            self.secondLine.items.append(SectionController.CombineItem(text: value))
            NotificationCenter.default.post(name: combineDidChangeNotification, object: self.firstLine)
            NotificationCenter.default.post(name: combineDidChangeNotification, object: self.secondLine)
            if !self.isLineCombined {
                self.combinedLine.items.append(SectionController.CombineItem(text: nil))
                NotificationCenter.default.post(name: combineDidChangeNotification, object: self.combinedLine)
            }
        })
        
        _ = numbers1.zip(numbers2) { "\($0 ?? "")\($1 ?? "")" }
            .sink { combined in
                _ = self.currentFirstLine.popLast()
                _ = self.currentSecondLine.popLast()
                self.combinedLine.items.append(SectionController.CombineItem(text: combined))
                NotificationCenter.default.post(name: combineDidChangeNotification, object: self.combinedLine)
        }
    }
    
    init() {
        setupSubscription()
    }
    
    func reset() {
        sendValues = self.randomValues
        
        self.isCombined = false
        
        currentFirstLine = []
        currentSecondLine = []
        
        self.firstLine.items.removeAll()
        self.secondLine.items.removeAll()
        self.combinedLine.items.removeAll()
        
        numbers1 = PassthroughSubject<String?, Error>()
        numbers2 = PassthroughSubject<String?, Error>()
        
        setupSubscription()
    }
    
    func send() {
        guard let value = sendValues.popLast() else {
            self.isCombined = true
            return
        }
        
        if let _ = Int(value) {
            currentFirstLine.append(value)
            numbers1.send(value)
            
        } else {
            currentSecondLine.append(value)
            numbers2.send(value)
        }
    }
}
