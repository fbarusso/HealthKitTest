//
//  ViewController.swift
//  HealthKitTest
//
//  Created by Felipe Barusso on 17/10/23.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemCyan
        configureHealthKit()
    }


    func configureHealthKit() {
        let healthStore = HKHealthStore()
        
        if HKHealthStore.isHealthDataAvailable() {
            let allTypes = Set([
                HKObjectType.workoutType(),
                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                HKObjectType.quantityType(forIdentifier: .heartRate)!
            ])
            
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
                    print("Health store authorization error: \(String(describing: error?.localizedDescription))")
                } else {
                    let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate)!
                    
                    let calendar = Calendar.current
                    var components = calendar.dateComponents([.year, .month, .day], from: Date())
                    components.day = components.day! - 7
                    let oneWeekAgo = calendar.date(from: components)
                    
                    let inLastWeek = HKQuery.predicateForSamples(withStart: oneWeekAgo, end: nil, options: [.strictStartDate])
                    
                    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
                    
                    let sampleQuery = HKSampleQuery(sampleType: quantityType, predicate: inLastWeek, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, results, error in
                            
                        
                        guard let samples = results as? [HKQuantitySample] else {
                            print(error?.localizedDescription ?? "null error")
                            return
                        }
                        
                        for sample in samples {
                            let mSample = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                            print("Heart rate: \(mSample)")
                        }
                    }
                    
                    healthStore.execute(sampleQuery)
                }
            }
        } else {
            print("Health data is not available")
        }
    }
}

