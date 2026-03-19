//
//  ContentView.swift
//  Naptime
//
//  Created by Anna Nazarenko on 10/3/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            AppSectionView(
                title: "Today",
                systemImage: "sun.max.fill",
                headline: "Today's sleep at a glance",
                message: "Start here to review the latest nap, active sleep, and quick actions."
            )
            .tabItem {
                Label("Today", systemImage: "sun.max.fill")
            }

            AppSectionView(
                title: "Sessions",
                systemImage: "list.bullet.rectangle",
                headline: "All sleep sessions",
                message: "This screen will show the full history of naps and overnight sleep sessions."
            )
            .tabItem {
                Label("Sessions", systemImage: "list.bullet.rectangle")
            }

            AppSectionView(
                title: "Week",
                systemImage: "chart.bar.xaxis",
                headline: "Weekly trends",
                message: "Use this area for weekly summaries, totals, and sleep pattern insights."
            )
            .tabItem {
                Label("Week", systemImage: "chart.bar.xaxis")
            }

            AppSectionView(
                title: "Settings",
                systemImage: "gearshape.fill",
                headline: "App preferences",
                message: "Configuration, notifications, data sources, and other preferences will live here."
            )
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
    }
}

private struct AppSectionView: View {
    let title: String
    let systemImage: String
    let headline: String
    let message: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Image(systemName: systemImage)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(.tint)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(headline)
                            .font(.title2.weight(.semibold))

                        Text(message)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    PlaceholderCard(
                        title: "Coming Next",
                        description: "This placeholder keeps the navigation structure visible while the feature content is still being built."
                    )

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(title)
        }
    }
}

private struct PlaceholderCard: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    ContentView()
}
