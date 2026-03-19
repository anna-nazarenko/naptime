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
            TodayView()
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

private struct TodayView: View {
    @State private var screenState: TodayScreenState

    init(screenState: TodayScreenState = .previewDefault) {
        _screenState = State(initialValue: screenState)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    TodayHeaderView()
                    TodayCTAButton(isSessionActive: screenState.isSessionActive) {
                        screenState.toggleSessionState()
                    }
                    if let activeSession = screenState.activeSession {
                        TodayActiveSessionCard(session: activeSession)
                    }
                    TodaySummaryBlock(summary: screenState.summary)
                    TodaySessionListBlock(sessions: screenState.sessions)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}

private struct TodayHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Today")
                .font(.largeTitle.weight(.bold))

            Text("Track the current sleep session and review today's summary.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct TodayCTAButton: View {
    let isSessionActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isSessionActive ? "Stop" : "Start")
                        .font(.title2.weight(.semibold))

                    Text(isSessionActive ? "End the current sleep session" : "Begin tracking a new sleep session")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.88))
                }

                Spacer()

                Image(systemName: isSessionActive ? "stop.fill" : "play.fill")
                    .font(.title3.weight(.bold))
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.18), in: Circle())
            }
            .foregroundStyle(.white)
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 92)
            .background(
                LinearGradient(
                    colors: [Color.indigo, Color.blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct TodayActiveSessionCard: View {
    let session: TodayActiveSession

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Active Session")
                    .font(.headline)

                Spacer()

                Label(
                    session.status,
                    systemImage: "moon.zzz.fill"
                )
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.indigo)
            }

            TimelineView(.periodic(from: .now, by: 60)) { context in
                VStack(alignment: .leading, spacing: 18) {
                    DetailRow(title: "Started at", value: session.startedAt.formatted(date: .omitted, time: .shortened))
                    DetailRow(title: "Elapsed time", value: Self.elapsedTimeString(from: session.startedAt, now: context.date))
                }
            }
        }
        .cardStyle()
    }

    private static func elapsedTimeString(from startDate: Date, now: Date) -> String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: now)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }

        return "\(minutes)m"
    }
}

private struct TodaySummaryBlock: View {
    let summary: TodaySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Summary")
                .font(.headline)

            HStack(spacing: 12) {
                SummaryMetricCard(title: "Total Sleep", value: summary.totalSleep)
                SummaryMetricCard(title: "Sessions", value: "\(summary.sessionCount)")
                SummaryMetricCard(title: "Awakenings", value: "\(summary.totalAwakenings)")
            }
        }
    }
}

private struct TodaySessionListBlock: View {
    let sessions: [TodaySessionItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Sessions")
                    .font(.headline)

                Spacer()

                Text("\(sessions.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            if sessions.isEmpty {
                TodayEmptyStateCard(
                    title: "No sessions yet",
                    message: "Start tracking when sleep begins. Today's sessions will appear here."
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(sessions) { session in
                        TodaySessionRow(session: session)
                    }
                }
            }
        }
    }
}

private struct TodaySessionRow: View {
    let session: TodaySessionItem

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: session.iconName)
                .font(.headline)
                .foregroundStyle(.indigo)
                .frame(width: 40, height: 40)
                .background(Color.indigo.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(session.title)
                        .font(.body.weight(.semibold))

                    Spacer()

                    Text(session.duration)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Text(session.timeRange)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let note = session.note {
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct SummaryMetricCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(value)
                .font(.title3.weight(.semibold))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct TodayEmptyStateCard: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.body.weight(.semibold))

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }
}

private struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.weight(.semibold))
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

private struct TodayActiveSession {
    let startedAt: Date
    let status: String
}

private struct TodaySummary {
    let totalSleep: String
    let sessionCount: Int
    let totalAwakenings: Int
}

private struct TodaySessionItem: Identifiable {
    let id = UUID()
    let title: String
    let timeRange: String
    let duration: String
    let iconName: String
    let note: String?

    static let stubbed: [TodaySessionItem] = [
        TodaySessionItem(
            title: "Morning Nap",
            timeRange: "09:10 - 09:52",
            duration: "42m",
            iconName: "sun.horizon.fill",
            note: "Woke up once after 18 minutes."
        ),
        TodaySessionItem(
            title: "Afternoon Nap",
            timeRange: "13:25 - 14:40",
            duration: "1h 15m",
            iconName: "bed.double.fill",
            note: nil
        ),
        TodaySessionItem(
            title: "Evening Sleep",
            timeRange: "18:55 - 20:23",
            duration: "1h 28m",
            iconName: "moon.stars.fill",
            note: "Settled quickly and slept steadily."
        )
    ]
}

private extension View {
    func cardStyle() -> some View {
        padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct TodayScreenState {
    var activeSession: TodayActiveSession?
    var summary: TodaySummary
    var sessions: [TodaySessionItem]

    var isSessionActive: Bool {
        activeSession != nil
    }

    mutating func toggleSessionState() {
        if activeSession == nil {
            activeSession = Self.mockActiveSession
        } else {
            activeSession = nil
        }
    }
}

private extension TodayScreenState {
    static let previewDefault = noActiveSessionWithData

    static let noActiveSessionEmptyDay = TodayScreenState(
        activeSession: nil,
        summary: TodaySummary(totalSleep: "0m", sessionCount: 0, totalAwakenings: 0),
        sessions: []
    )

    static let noActiveSessionWithData = TodayScreenState(
        activeSession: nil,
        summary: TodaySummary(totalSleep: "3h 25m", sessionCount: 3, totalAwakenings: 2),
        sessions: [
            TodaySessionItem(
                title: "Morning Nap",
                timeRange: "09:10 - 09:52",
                duration: "42m",
                iconName: "sun.horizon.fill",
                note: "Woke up once after 18 minutes."
            ),
            TodaySessionItem(
                title: "Afternoon Nap",
                timeRange: "13:25 - 14:40",
                duration: "1h 15m",
                iconName: "bed.double.fill",
                note: nil
            ),
            TodaySessionItem(
                title: "Evening Sleep",
                timeRange: "18:55 - 20:23",
                duration: "1h 28m",
                iconName: "moon.stars.fill",
                note: "Settled quickly and slept steadily."
            )
        ]
    )

    static let activeSessionEmptyDay = TodayScreenState(
        activeSession: mockActiveSession,
        summary: TodaySummary(totalSleep: "0m", sessionCount: 0, totalAwakenings: 0),
        sessions: []
    )

    static let activeSessionWithData = TodayScreenState(
        activeSession: mockActiveSession,
        summary: TodaySummary(totalSleep: "4h 08m", sessionCount: 2, totalAwakenings: 1),
        sessions: [
            TodaySessionItem(
                title: "Morning Nap",
                timeRange: "08:45 - 09:30",
                duration: "45m",
                iconName: "sunrise.fill",
                note: nil
            ),
            TodaySessionItem(
                title: "Afternoon Nap",
                timeRange: "13:05 - 14:28",
                duration: "1h 23m",
                iconName: "bed.double.fill",
                note: "Brief awakening after 30 minutes."
            )
        ]
    )

    static let mockActiveSession = TodayActiveSession(
        startedAt: Calendar.current.date(byAdding: .minute, value: -43, to: .now) ?? .now,
        status: "Sleeping"
    )
}

#Preview("Today / No Active / Empty") {
    TodayView(screenState: .noActiveSessionEmptyDay)
}

#Preview("Today / No Active / With Data") {
    TodayView(screenState: .noActiveSessionWithData)
}

#Preview("Today / Active / Empty Day") {
    TodayView(screenState: .activeSessionEmptyDay)
}

#Preview("Today / Active / With Data") {
    TodayView(screenState: .activeSessionWithData)
}

#Preview("App Tabs") {
    ContentView()
}
