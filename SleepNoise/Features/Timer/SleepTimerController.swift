import Combine
import Foundation

@MainActor
final class SleepTimerController: ObservableObject {
    @Published private(set) var selectedMinutes: Int?
    @Published private(set) var remaining: TimeInterval?
    @Published private(set) var isFading = false

    var onFade: (@MainActor (TimeInterval) -> Void)?
    var onComplete: (@MainActor () -> Void)?

    private var endDate: Date?
    private var ticker: Timer?
    private var isRunning = false
    private var didRequestFade = false
    private var fadeDuration: TimeInterval = 20

    func choose(_ minutes: Int?) {
        stopTicking()
        selectedMinutes = minutes
        isFading = false
        didRequestFade = false
        remaining = nil
        endDate = nil
    }

    func start() {
        guard let minutes = selectedMinutes else { return }
        let from = remaining ?? TimeInterval(minutes * 60)
        guard from > 0.2 else {
            finish()
            return
        }
        begin(from: from)
    }

    func pause() {
        guard isRunning else { return }
        if let endDate {
            remaining = max(0, endDate.timeIntervalSinceNow)
        }
        stopTicking()
    }

    private func begin(from duration: TimeInterval) {
        guard let minutes = selectedMinutes else { return }
        isRunning = true
        didRequestFade = false
        isFading = false
        fadeDuration = TimerMath.fadeDuration(totalSeconds: TimeInterval(minutes * 60))
        endDate = Date().addingTimeInterval(duration)
        remaining = duration
        startTicking()
    }

    private func startTicking() {
        ticker?.invalidate()
        let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.tick()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer
        tick()
    }

    private func stopTicking() {
        isRunning = false
        ticker?.invalidate()
        ticker = nil
    }

    private func tick() {
        guard isRunning, let endDate else { return }
        let left = endDate.timeIntervalSinceNow
        if left <= 0 {
            remaining = 0
            finish()
            return
        }
        remaining = left
        if !didRequestFade, left <= fadeDuration {
            didRequestFade = true
            isFading = true
            onFade?(left)
        }
    }

    private func finish() {
        stopTicking()
        endDate = nil
        remaining = nil
        isFading = false
        didRequestFade = false
        onComplete?()
    }
}
