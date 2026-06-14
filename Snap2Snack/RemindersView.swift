//
//  RemindersView.swift
//  Snap2Snack
//
//  Created by Paul Lieber on 9/1/25.
//

import SwiftUI

struct RemindersView: View {
    @State private var showingAddReminder = false
    @State private var reminders: [Reminder] = []
    
    var body: some View {
        VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "bell.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Reminders")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                        
                        Text("Set and manage your health reminders")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Reminders Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Reminders")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button("Add") {
                                showingAddReminder = true
                            }
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                        }
                        .padding(.horizontal)
                        
                        if reminders.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "bell.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                
                                Text("No reminders set")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("Tap 'Add' to set your first reminder")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(reminders) { reminder in
                                    ReminderCard(reminder: reminder)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView(reminders: $reminders, showingAddReminder: $showingAddReminder)
            }
            .onAppear {
                loadSampleReminders()
            }
        }
    
    private func loadSampleReminders() {
        let calendar = Calendar.current
        let now = Date()
        
        reminders = [
            Reminder(title: "Morning Glucose Check", time: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now, type: .glucose),
            Reminder(title: "Take Medication", time: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now) ?? now, type: .medication),
            Reminder(title: "Evening Glucose Check", time: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: now) ?? now, type: .glucose)
        ]
    }
}