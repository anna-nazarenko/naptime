//
//  ContentView.swift
//  Naptime
//
//  Created by Anna Nazarenko on 10/3/26.
//

import SwiftUI

struct ContentView: View {
    private let todayViewModel: TodayViewModel

    init(todayViewModel: TodayViewModel) {
        self.todayViewModel = todayViewModel
    }

    var body: some View {
        TabView {
            TodayView(viewModel: todayViewModel)
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
    @State private var viewModel: TodayViewModel

    init(viewModel: TodayViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    @MainActor
    private var sessionItems: [TodaySessionItem] {
        viewModel.sessions.map { TodaySessionItem(session: $0) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    TodayHeaderView()
                    TodayCTAButton(
                        isSessionActive: viewModel.isSessionActive,
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            await viewModel.toggleSession(now: .now)
                        }
                    }
                    if let errorMessage = viewModel.errorMessage {
                        TodayErrorCard(message: errorMessage)
                    }
                    if let activeSession = viewModel.activeSession {
                        TodayActiveSessionCard(session: activeSession)
                    }
                    TodaySummaryBlock(
                        summary: viewModel.summary,
                        state: viewModel.screenState
                    )
                    TodaySessionListBlock(
                        sessions: sessionItems,
                        state: viewModel.screenState
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .task {
            await viewModel.loadIfNeeded()
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
    let isLoading: Bool
    let action: () -> Void

    private var gradientColors: [Color] {
        isSessionActive ? [.indigo, .blue] : [.red, .orange]
    }

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isSessionActive ? "Stop" : "Start")
                        .font(.title2.weight(.semibold))

                    Text(isLoading ? "Updating session state" : (isSessionActive ? "End the current sleep session" : "Begin tracking a new sleep session"))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.88))
                }

                Spacer()

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(isSessionActive ? 0.18 : 0.22), in: Circle())
                } else {
                    Image(systemName: isSessionActive ? "stop.fill" : "play.fill")
                        .font(.title3.weight(.bold))
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(isSessionActive ? 0.18 : 0.22), in: Circle())
                }
            }
            .foregroundStyle(.white)
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 92)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

private struct TodayActiveSessionCard: View {
    let session: SleepSession

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Active Session")
                    .font(.headline)

                Spacer()

                Label(
                    "Sleeping",
                    systemImage: "moon.zzz.fill"
                )
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.indigo)
            }

            TimelineView(.periodic(from: .now, by: 60)) { context in
                VStack(alignment: .leading, spacing: 18) {
                    DetailRow(title: "Started at", value: session.startAt.formatted(date: .omitted, time: .shortened))
                    DetailRow(title: "Elapsed time", value: Self.elapsedTimeString(from: session.startAt, now: context.date))
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

private struct TodayErrorCard: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }
}

private struct TodaySummaryBlock: View {
    let summary: TodaySummary
    let state: TodayScreenState

    private var displayedSummary: TodaySummary {
        state == .loading ? .loadingPlaceholder : summary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Summary")
                    .font(.headline)

                if state == .loading || state == .partial {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            HStack(spacing: 12) {
                SummaryMetricCard(title: "Total Sleep", value: displayedSummary.totalSleep)
                SummaryMetricCard(title: "Sessions", value: displayedSummary.sessionCountLabel)
                SummaryMetricCard(title: "Awake Time", value: displayedSummary.totalAwakeTime)
            }
        }
    }
}

private struct TodaySessionListBlock: View {
    let sessions: [TodaySessionItem]
    let state: TodayScreenState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Sessions")
                    .font(.headline)

                if state == .partial {
                    ProgressView()
                        .controlSize(.small)
                }

                Spacer()

                Text("\(sessions.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            if state == .loading {
                TodayEmptyStateCard(
                    title: "Loading sessions",
                    message: "Today's sleep sessions are being loaded."
                )
            } else if sessions.isEmpty {
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
                .foregroundStyle(session.accentColor)
                .frame(width: 40, height: 40)
                .background(session.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.title)
                            .font(.body.weight(.semibold))

                        Text(session.stateLabel)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(session.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(session.accentColor.opacity(0.12), in: Capsule())
                    }

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

private struct TodaySessionItem: Identifiable {
    let id: UUID
    let title: String
    let timeRange: String
    let duration: String
    let iconName: String
    let accentColor: Color
    let stateLabel: String
    let note: String?

    init(
        id: UUID = UUID(),
        title: String,
        timeRange: String,
        duration: String,
        iconName: String,
        accentColor: Color,
        stateLabel: String,
        note: String?
    ) {
        self.id = id
        self.title = title
        self.timeRange = timeRange
        self.duration = duration
        self.iconName = iconName
        self.accentColor = accentColor
        self.stateLabel = stateLabel
        self.note = note
    }

    init(session: SleepSession) {
        id = session.id
        title = session.isActive ? "Sleep Session" : "Completed Sleep"
        timeRange = Self.makeTimeRange(for: session)
        duration = Self.makeDuration(for: session)
        iconName = session.isActive ? "moon.zzz.fill" : "checkmark.circle.fill"
        accentColor = session.isActive ? .indigo : .teal
        stateLabel = session.isActive ? "Running" : "Completed"
        note = session.isActive ? "Tracking now" : nil
    }

    static let stubbed: [TodaySessionItem] = [
        TodaySessionItem(
            title: "Morning Nap",
            timeRange: "09:10 - 09:52",
            duration: "42m",
            iconName: "sun.horizon.fill",
            accentColor: .orange,
            stateLabel: "Completed",
            note: "Woke up once after 18 minutes."
        ),
        TodaySessionItem(
            title: "Afternoon Nap",
            timeRange: "13:25 - 14:40",
            duration: "1h 15m",
            iconName: "bed.double.fill",
            accentColor: .teal,
            stateLabel: "Completed",
            note: nil
        ),
        TodaySessionItem(
            title: "Evening Sleep",
            timeRange: "18:55 - 20:23",
            duration: "1h 28m",
            iconName: "moon.stars.fill",
            accentColor: .indigo,
            stateLabel: "Completed",
            note: "Settled quickly and slept steadily."
        )
    ]

    private static func makeTimeRange(for session: SleepSession) -> String {
        let start = session.startAt.formatted(date: .omitted, time: .shortened)
        let end = session.endAt?.formatted(date: .omitted, time: .shortened) ?? "In Progress"
        return "\(start) - \(end)"
    }

    private static func makeDuration(for session: SleepSession) -> String {
        guard let duration = session.duration else {
            return "Live"
        }

        let totalMinutes = Int(duration / 60)
        if totalMinutes == 0 {
            return "<1m"
        }

        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }

        return "\(minutes)m"
    }
}

private extension View {
    func cardStyle() -> some View {
        padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct PreviewTodaySleepTracking: TodaySleepTracking {
    let activeSession: SleepSession?
    let sessions: [SleepSession]

    func loadActiveSession() async throws -> SleepSession? {
        activeSession
    }

    func loadSessions(for sleepDay: SleepDay) async throws -> [SleepSession] {
        sessions.filter { $0.overlaps(with: sleepDay.interval) }
    }

    func startSession(at startAt: Date) async throws -> SleepSession {
        try SleepSession(startAt: startAt, createdSource: .iphone)
    }

    func stopSession(at endAt: Date) async throws -> SleepSession {
        var session = try SleepSession(
            startAt: Calendar.current.date(byAdding: .minute, value: -43, to: endAt) ?? endAt.addingTimeInterval(-2580),
            createdSource: .iphone
        )
        try session.finish(at: endAt, source: .iphone)
        return session
    }
}

private extension TodayViewModel {
    static let previewInactive = TodayViewModel(
        tracking: PreviewTodaySleepTracking(
            activeSession: nil,
            sessions: TodaySessionItem.stubbedSessions
        )
    )

    static let previewActive = TodayViewModel(
        tracking: PreviewTodaySleepTracking(
            activeSession: try? SleepSession(
                startAt: Calendar.current.date(byAdding: .minute, value: -43, to: .now) ?? .now,
                createdSource: .iphone
            ),
            sessions: []
        )
    )

    static let previewActiveWithSessionList = TodayViewModel(
        tracking: PreviewTodaySleepTracking(
            activeSession: try? SleepSession(
                startAt: Calendar.current.date(byAdding: .minute, value: -43, to: .now) ?? .now,
                createdSource: .iphone
            ),
            sessions: TodaySessionItem.stubbedSessions
        )
    )
}

private extension TodaySessionItem {
    static var stubbedSessions: [SleepSession] {
        let calendar = Calendar.current
        let timeRanges = [(9, 10, 9, 52), (13, 25, 14, 40), (18, 55, 20, 23)]

        return timeRanges.compactMap { startHour, startMinute, endHour, endMinute in
            guard
                let startAt = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: .now),
                let endAt = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: .now)
            else {
                return nil
            }

            return try? SleepSession(
                startAt: startAt,
                endAt: endAt,
                createdSource: .iphone
            )
        }
    }
}

#Preview("Today / No Active / Empty") {
    TodayView(viewModel: .previewInactive)
}

#Preview("Today / No Active / With Data") {
    TodayView(viewModel: .previewInactive)
}

#Preview("Today / Active / Empty Day") {
    TodayView(viewModel: .previewActive)
}

#Preview("Today / Active / With Data") {
    TodayView(viewModel: .previewActiveWithSessionList)
}

#Preview("App Tabs") {
    ContentView(todayViewModel: .previewInactive)
}
