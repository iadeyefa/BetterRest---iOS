//
//  ContentView.swift
//  BetterRest
//
//  Created by Ife Adeyefa on 9/10/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("When do you want to wake up?") { // Challenge 1
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    
                }
                
                
                Section("Desired amount of sleep") { // Challenge 1
                    Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
                    
                }
                
                
                Section("Daily coffee intake") { // Challenge 1
                    Picker("Cups of Coffee", selection: $coffeeAmount) { // Challenge 2
                        ForEach(0..<21) {
                            Text("\($0) cup(s)")
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    //Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 0...20)
                    
                }
                
                
                Section { // Challenge 3
                    VStack {
                        calculateBedtime()
                    }
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    
                } header: {
                    Text("Your Optimal Sleep Time")
                        .fontWeight(.bold)
                        .font(.headline)
                }
            }
            .navigationTitle("BetterRest")
            
        }
    }
    
    func calculateBedtime() -> Text {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(Double(coffeeAmount)))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return Text("\(sleepTime.formatted(date: .omitted, time: .shortened))")
        } catch {
            //somethign went wrong
            return Text("Error: Sorry, there was a problem calculating your bedtime.")
        }
        
    }
}



#Preview {
    ContentView()
}
