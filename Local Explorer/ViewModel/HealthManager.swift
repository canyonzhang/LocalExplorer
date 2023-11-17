//
//  HealthManager.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/26/23.
//

import Foundation
import HealthKit

class HealthManager: ObservableObject {
    // Create a HealthKit Store
    let healthStore = HKHealthStore()
    
    // Dictionary to store and display activity cards
    @Published var activities: [String: Activity] = [:]
    @Published var mockActivities: [String : Activity] = [
        "todaySteps" : Activity(id: 0, title: "Today steps", subtitle: "Goal 10,000", image: "figure.walk", amount: "12,123"),
        "todayCalories": Activity(id: 1, title: "Today calories", subtitle: "Goal 900", image: "flame", amount: "1,241")
    ]

    
    init() {
        // Define the type of health data we want to read, here, steps, calories and workouts
        let steps = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calories = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let workout = HKObjectType.workoutType() // Gives access to all the user's workouts
        // Create a set of the types of health data we will read
        let healthTypes: Set = [steps, calories, workout]
        
        // Start a new task to request authorization to read the health data
        Task {
            do {
                // Request authorization to read the specified types of health data
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchDailySteps()
                fetchCaloriesBurned()
                fetchCurrentWorkoutWeekStats()
            } catch {
                // If there is an error requesting authorization, print an error message
                print("error fetching health data")
            }
        }
    }
    
    
    func fetchDailySteps() {
        // Define the quantity type for steps
        guard let steps = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        guard HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) != nil else { return }
        // Create a predicate to filter the data starting from the beginning of the current day to now
        let predicate = HKQuery.predicateForSamples(withStart: .startOfToday(), end: Date())
        
        // Fetch the sum of steps with a stats query
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error fetching todays step data")
                return
            }
            
            let stepCount = quantity.doubleValue(for: .count())
            let activity = Activity(id: 0, title: "Today's steps", subtitle: "Goal: 10,000", image: "figure.walk", amount: stepCount.formattedString())
            
            print("STEPS IS: ", stepCount.formattedString())
            DispatchQueue.main.async {
                self.activities["todaySteps"] = activity
            }
        }
        
        // Execute the query on the health store.
        healthStore.execute(query)
    }
    
    // Same as above, only we are querying for different identifiers (calories and workouts)
    func fetchCaloriesBurned() {
        guard let calories = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Unable to retrieve HKQuantityType for activeEnergyBurned")
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: .startOfToday(), end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error fetching today's calorie data")
                return
            }

            let caloriesBurned = quantity.doubleValue(for: .kilocalorie())
            let activity = Activity(id: 1, title: "Calories Burned Today", subtitle: "Goal 750", image: "flame", amount: caloriesBurned.formattedString())

            DispatchQueue.main.async {
                self.activities["todayCalories"] = activity
            }

            print(caloriesBurned.formattedString())
        }
        healthStore.execute(query)
    }
    
    // Instead of writing separate functions for each workout type, refactor it so that we set our activites set all in one function
    func fetchCurrentWorkoutWeekStats() {
        let workout = HKSampleType.workoutType()
        let timePredicate = HKQuery.predicateForSamples(withStart: .startOfWeek(), end: Date())
        let query = HKSampleQuery(sampleType: workout, predicate: timePredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, sample, error in
            guard let workouts = sample as? [HKWorkout], error == nil else {
                print("error fetching week running data")
                return
            }

            var ellipticalMins: Int = 0
            var runningMins: Int = 0
            var liftingMins: Int = 0
            var cyclingMins: Int = 0
            var climbingMins: Int = 0
            var stairsMins: Int = 0
            for workout in workouts {
                // Check the workout type and accumulate the minutes for each type
                if workout.workoutActivityType == .elliptical {
                    let duration = Int(workout.duration)/60
                    ellipticalMins += duration
                }
                else if workout.workoutActivityType == .running {
                    let duration = Int(workout.duration)/60
                    runningMins += duration
                }
                else if workout.workoutActivityType == .traditionalStrengthTraining {
                    let duration = Int(workout.duration)/60
                    liftingMins += duration
                }
                else if workout.workoutActivityType == .cycling {
                    let duration = Int(workout.duration)/60
                    cyclingMins += duration
                }
                else if workout.workoutActivityType == .climbing {
                    let duration = Int(workout.duration)/60
                    climbingMins += duration
                }
                else if workout.workoutActivityType == .stairClimbing {
                    let duration = Int(workout.duration)/60
                    stairsMins += duration
                }
            }
            
            // Create the activity objects and update our activities set, which will be rendered on our ActivityView
            let elliptical = Activity(id: 2, title: "Elliptical", subtitle: "Mins this week", image: "figure.elliptical", amount: "\(ellipticalMins) minutes")
            let running = Activity(id: 3, title: "Weight Lifting", subtitle: "This week", image: "dumbbell", amount: "\(liftingMins) minutes")
            let lifting = Activity(id: 4, title: "Running", subtitle: "Mins this week", image: "figure.run", amount: "\(runningMins) minutes")
            let cycling = Activity(id: 5, title: "Cycling", subtitle: "Mins this week", image: "figure.indoor.cycle", amount: "\(cyclingMins) minutes")
            let climbing = Activity(id: 6, title: "Climbing", subtitle: "Mins this week", image: "figure.climbing", amount: "\(climbingMins) minutes")
            let stairs = Activity(id: 7, title: "Stair Stepper", subtitle: "Mins this week", image: "figure.stair.stepper", amount: "\(stairsMins) minutes")
            
            

            DispatchQueue.main.async {
                self.activities["weeklyElliptical"] = elliptical
                self.activities["weeklyRunning"] = running
                self.activities["weeklyLifting"] = lifting
                self.activities["weeklyCycling"] = cycling
                self.activities["weeklyClimbing"] = climbing
                self.activities["weeklyStairs"] = stairs
            }
        }
        healthStore.execute(query)
    }

}



// Extension that returns the start of today's date
extension Date {
    static func startOfToday() -> Date {
        return Calendar.current.startOfDay(for: Date())
    }
}

// Extension that returns the start of the current week starting from Sunday in the US and Monday in Asia/Europe
extension Date {
    static func startOfWeek() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        return calendar.date(from: components) ?? now
    }
}

// Extension that formats steps calories etc.. into a string
extension Double {
    func formattedString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0 // No decimal places
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}

