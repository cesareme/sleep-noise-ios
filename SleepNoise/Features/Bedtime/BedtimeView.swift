import SwiftUI
import UIKit

/// Near-empty black screen. A dim clock, and the timer when one is running.
/// A tap brings the controls back; after `BedtimeScreenPolicy.dimAfter` they
/// fade. The idle timer is left enabled and system brightness is not touched.
struct BedtimeView: View {
    @ObservedObject var model: MixerModel
    @ObservedObject private var timer: SleepTimerController

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var chromeVisible = true
    @State private var dimTask: Task<Void, Never>?

    init(model: MixerModel) {
        self.model = model
        _timer = ObservedObject(wrappedValue: model.timer)
    }

    var body: some View {
        ZStack {
            DesignTokens.Colors.bedtime.ignoresSafeArea()
            VStack(spacing: DesignTokens.Spacing.l) {
                clock
                if let remaining = timer.remaining {
                    Text(TimeFormat.clock(remaining))
                        .font(DesignTokens.Typography.clock())
                        .monospacedDigit()
                        .foregroundStyle(DesignTokens.Colors.bedtimeInk.opacity(chromeVisible ? 0.55 : 0.16))
                        .accessibilityLabel(Text("timer.remaining"))
                        .accessibilityValue(Text(TimeFormat.clock(remaining)))
                }
                if chromeVisible {
                    Text("bedtime.hint")
                        .tokenFont(.footnote)
                        .foregroundStyle(DesignTokens.Colors.bedtimeInk.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignTokens.Spacing.xl)
                    controls
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.l)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: wake)
        .accessibilityAction(named: Text("bedtime.wake"), wake)
        .preferredColorScheme(.dark)
        .persistentSystemOverlays(.hidden)
        .statusBarHidden(true)
        .onAppear {
            if BedtimeScreenPolicy.systemIdleTimerStaysEnabled {
                UIApplication.shared.isIdleTimerDisabled = false
            }
            scheduleDim()
        }
        .onDisappear {
            dimTask?.cancel()
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    private var clock: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            Text(context.date, format: .dateTime.hour().minute())
                .font(DesignTokens.Typography.display(.light))
                .monospacedDigit()
                .foregroundStyle(DesignTokens.Colors.bedtimeInk.opacity(chromeVisible ? 0.42 : 0.14))
        }
        .accessibilityLabel(Text("bedtime.clock"))
    }

    private var controls: some View {
        HStack(spacing: DesignTokens.Spacing.m) {
            Button {
                model.togglePlayback()
                wake()
            } label: {
                Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(DesignTokens.Colors.bedtimeInk.opacity(0.8))
                    .frame(width: 64, height: 64)
                    .background(Circle().strokeBorder(DesignTokens.Colors.bedtimeInk.opacity(0.25), lineWidth: 1))
            }
            .accessibilityLabel(Text(model.isPlaying ? "control.pause" : "control.play"))
            .accessibilityIdentifier("bedtimePlay")

            Button {
                model.leaveBedtime()
            } label: {
                Text("bedtime.leave")
                    .tokenFont(.body, weight: .medium)
                    .foregroundStyle(DesignTokens.Colors.bedtimeInk.opacity(0.8))
                    .padding(.horizontal, 18)
                    .frame(minHeight: 64)
                    .background(Capsule().strokeBorder(DesignTokens.Colors.bedtimeInk.opacity(0.25), lineWidth: 1))
            }
            .accessibilityIdentifier("bedtimeLeave")
        }
        .padding(.top, DesignTokens.Spacing.s)
    }

    private func wake() {
        dimTask?.cancel()
        if reduceMotion {
            chromeVisible = true
        } else {
            withAnimation(.easeInOut(duration: 0.35)) { chromeVisible = true }
        }
        scheduleDim()
    }

    private func scheduleDim() {
        dimTask?.cancel()
        dimTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(BedtimeScreenPolicy.dimAfter))
            guard !Task.isCancelled else { return }
            if reduceMotion {
                chromeVisible = false
            } else {
                withAnimation(.easeInOut(duration: 1.2)) { chromeVisible = false }
            }
        }
    }
}
