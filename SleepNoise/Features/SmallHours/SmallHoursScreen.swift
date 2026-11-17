import SwiftUI

/// Small Hours (03 §5, surface 11): "can I go back to sleep without
/// thinking?".
///
/// The same full-screen control as Night with another question, and less
/// on it: the water line of the tide (or the Horizon once the tide has
/// gone), the minutes left, and "Stop". No hour, on purpose. One ink, no
/// accent of any kind. For the last five minutes one word, "Winding down ·
/// n min" (C60). When it ends nothing happens: the screen gives way to the
/// night page without a sound or a word.
///
/// It is the fixed recipe for everyone (C05): nothing here knows about
/// access, the trial or the mix, and nothing is ever sold from it.
struct SmallHoursScreen: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var session: SmallHoursController

    @Environment(\.dynamicTypeSize) private var dynamicType

    private var status: SmallHoursStatus {
        SmallHoursStatus.resolve(SmallHoursStatus.Input(
            isPlaying: model.isPlaying,
            minutesLeft: session.minutesLeft,
            windingDownMinutes: session.windingDownMinutes,
            startFailures: model.startFailures
        ))
    }

    /// The tide still has a course: the line is water. Once it has
    /// dissolved, and in a pause, there is no water to draw.
    private func showsWater(_ status: SmallHoursStatus) -> Bool {
        status.isSounding && session.tideAnchor != nil
    }

    var body: some View {
        let status = self.status
        let water = showsWater(status)
        FullScreenControl(
            model: model,
            allowsBack: false,
            spoken: spoken(status),
            onTap: { touched(status) }
        ) { layout in
            VStack(spacing: 0) {
                line(status, water: water)
                    .padding(.top, layout.horizonY - TideLine.band / 2)
                figure(status)
                    .padding(.top, NightLayout.figureDrop - TideLine.band / 2)
                word(status)
                    .padding(.top, NightLayout.lineGap)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        } actions: {
            NightAction(title: Localized.string("comun.parar")) {
                model.endSmallHours()
            }
            .accessibilityIdentifier("smallHoursStop")
        }
    }

    // MARK: What it shows

    /// The band of the water line exists as geometry and is never drawn:
    /// no marks. The line is the breath the engine renders, from the same
    /// anchor; when the tide has gone it has faded at low water and the
    /// Horizon is there instead, at the middle of the band. Neither ever
    /// travels to the other.
    private func line(_ status: SmallHoursStatus, water: Bool) -> some View {
        ZStack {
            SoundLineMark(rms: 0, isSounding: status.isSounding && !water, ownsAccent: false)
                .frame(height: Grid.horizonBand)
            if water {
                TideLine(
                    mode: .moving,
                    level: { date in
                        SmallHoursWater.level(
                            at: date,
                            anchor: session.tideAnchor,
                            elapsed: session.elapsed,
                            recipe: session.recipe
                        )
                    },
                    showsMarks: false,
                    lineThickness: 1.5
                )
                .transition(.opacity)
            }
        }
        .frame(height: TideLine.band)
        .padding(.horizontal, Grid.margin)
        .animation(Motion.stopCurve, value: water)
    }

    /// The minutes left. They go down by the minute, in place.
    private func figure(_ status: SmallHoursStatus) -> some View {
        Text(verbatim: status.figure())
            .step(.figure)
            .foregroundStyle(Ink.textNight)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, Grid.margin)
            .frame(maxWidth: .infinity, minHeight: TypeStep.figure.scaledLineHeight(for: dynamicType))
    }

    /// Empty except during the last minutes. Its line is always there.
    private func word(_ status: SmallHoursStatus) -> some View {
        let text = status.word() ?? ""
        return Text(verbatim: text)
            .step(.nightState)
            .monospacedDigit()
            .foregroundStyle(Ink.textNight)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .contentTransition(.opacity)
            .animation(Motion.contentCurve, value: text)
            .padding(.horizontal, Grid.margin)
            .frame(maxWidth: .infinity, minHeight: TypeStep.nightState.scaledLineHeight(for: dynamicType), alignment: .top)
    }

    // MARK: What it does

    private func touched(_ status: SmallHoursStatus) {
        if status.isSounding {
            model.pause()
        } else {
            model.play()
        }
        let key = self.status.isSounding ? "noche.estado.sonando" : "noche.estado.pausa"
        AccessibilityNotification.Announcement(Localized.string(key)).post()
    }

    private func spoken(_ status: SmallHoursStatus) -> FullScreenSpoken {
        FullScreenSpoken(
            label: Localized.string("madrugada.titulo"),
            value: status.spoken(),
            hint: Localized.string(status.hintKey),
            actions: [(Localized.string("comun.parar"), { model.endSmallHours() })]
        )
    }
}
