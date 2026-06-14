//
//  ResourcesView.swift
//  Snap2Snack
//
//  Created by Paul Lieber on 9/1/25.
//

import SwiftUI

struct ResourcesView: View {
    @State private var resources: [Resource] = []
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "building.2.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Local Resources")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                        
                        Text("Find diabetes clinics, dietitians, and support groups near you")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search resources...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    
                    // Resources List
                    if resources.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "building.2")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("No resources found")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Placeholder for local diabetes resources")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(resources) { resource in
                                ResourceCard(resource: resource)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadSampleResources()
        }
    }
    
    private func loadSampleResources() {
        resources = [
            Resource(
                name: "Diabetes Care Center",
                type: "Clinic",
                address: "123 Health St, Medical City, MC 12345",
                phone: "(555) 123-4567",
                acceptsInsurance: true,
                cost: "Insurance Accepted",
                services: ["Blood sugar monitoring", "Diabetes education", "Nutrition counseling"],
                hours: "Mon-Fri 8AM-6PM, Sat 9AM-2PM"
            ),
            Resource(
                name: "Nutrition Specialist",
                type: "Dietitian",
                address: "456 Wellness Ave, Healthy Town, HT 67890",
                phone: "(555) 987-6543",
                acceptsInsurance: false,
                cost: "$150/session",
                services: ["Personalized meal planning", "Glycemic index education", "Weight management"],
                hours: "Tue-Thu 9AM-5PM, Sat 10AM-3PM"
            ),
            Resource(
                name: "Diabetes Support Group",
                type: "Support",
                address: "789 Community Center, Support City, SC 54321",
                phone: "(555) 456-7890",
                acceptsInsurance: false,
                cost: "Free",
                services: ["Peer support", "Monthly meetings", "Educational workshops"],
                hours: "2nd Tuesday of each month, 7PM-9PM"
            )
        ]
    }
}
