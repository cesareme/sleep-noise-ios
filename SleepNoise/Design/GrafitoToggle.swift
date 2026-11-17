import SwiftUI

/// The switch (03 §4.12), drawn with tokens.
///
/// The system's switch has a white knob: on the night page it was the
/// brightest thing on screen, above the one ink the night allows (03 §3.1
/// rule 3). This one is the same control in the same place and size, and
/// nothing in it is lighter than the ink of the phase:
///
/// - off: a track in the hairline of its surface and a knob in `texto3`;
/// - on: a track in the ink of the phase and a knob in the colour of the
///   surface it sits on, so it reads as a hole in the track.
///
/// Never the accent: a switch is not sound. It is still a `Toggle`: for
/// VoiceOver and Switch Control it is the system's own switch, with its
/// value and its traits.
struct GrafitoToggleStyle: ToggleStyle {
    /// The label is drawn beside the switch. False where the row draws its
    /// own words and the toggle is only the switch (VoiceOver still reads
    /// the label).
    var showsLabel = true

    private static let reach = max(0, (Grid.target - GrafitoSwitch.size.height) / 2)

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: Grid.inner) {
            if showsLabel {
                configuration.label
                Spacer(minLength: 0)
            }
            GrafitoSwitch(isOn: configuration.isOn)
                // The switch is 31 pt tall and its touch area 44, taken
                // from the air around it: the row keeps its height.
                .padding(.vertical, Self.reach)
                .contentShape(Rectangle())
                .padding(.vertical, -Self.reach)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) {
                configuration.label
            }
        }
    }
}

/// The drawing of the switch for one state. No state of its own.
struct GrafitoSwitch: View {
    var isOn: Bool

    @Environment(\.nightPhase) private var phase
    @Environment(\.inkSurface) private var surface

    /// The size of the system's switch before iOS 26, which every row was
    /// measured for.
    static let size = CGSize(width: 51, height: 31)
    static let knobInset: CGFloat = 2

    private var track: Color {
        isOn ? Ink.primary(phase) : Ink.rule(on: surface)
    }

    private var knob: Color {
        if isOn { return surface == .sheet ? Ink.sheet : Ink.background }
        return Ink.text3
    }

    var body: some View {
        Capsule()
            .fill(track)
            .frame(width: Self.size.width, height: Self.size.height)
            .overlay(alignment: isOn ? .trailing : .leading) {
                Circle()
                    .fill(knob)
                    .padding(Self.knobInset)
            }
            .animation(Motion.controlCurve, value: isOn)
    }
}

#Preview("Switch") {
    VStack(spacing: Grid.inner) {
        GrafitoSwitch(isOn: false)
        GrafitoSwitch(isOn: true)
        GrafitoSwitch(isOn: true)
            .environment(\.nightPhase, .nightPage)
    }
    .frame(maxHeight: .infinity)
    .grafitoRoot()
}
