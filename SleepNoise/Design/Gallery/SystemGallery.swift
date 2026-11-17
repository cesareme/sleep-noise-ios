#if DEBUG
import SwiftUI

/// Debug-only gallery of the Grafito system. Not a product screen: it is the
/// instrument for reviewing the design on a device and the source of the
/// reference captures.
///
/// Launch the app with `-gallery` to open it. `-gallerySection <name>` opens
/// one section alone (see `Section`), `-galleryType <size>` forces a Dynamic
/// Type size (for example `accessibility3`) and `-gallerySheet` opens the
/// sheet sample at once. Add `-silentOutput` to exercise the live section
/// without making a sound.
///
/// The gallery is a catalogue, so it shows the accent many times on one
/// screen. A product screen never does: one element, and only while it sounds
/// or under a finger. Its labels are not localized; the samples use the
/// catalog where a string exists.
struct SystemGallery: View {
    enum Section: String, CaseIterable {
        case tokens
        case type
        case horizon
        case live
        case rows
        case disc
        case actions
        case sheet
    }

    @ObservedObject var model: MixerModel

    @State private var arbiter = IndexArbiter()
    @State private var showsSheet = GalleryArguments.opensSheet

    private var sections: [Section] {
        GalleryArguments.section.map { [$0] } ?? Section.allCases
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Grid.group) {
                ForEach(sections, id: \.self) { section in
                    VStack(alignment: .leading, spacing: 0) {
                        GalleryCaption(text: "grafito · \(section.rawValue)")
                            .padding(.bottom, Grid.unit * 2)
                        content(for: section)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, Grid.group)
        }
        .scrollBounceBehavior(.basedOnSize)
        .indexArbiter(arbiter)
        .environment(\.sheetPresented, showsSheet)
        .grafitoRoot()
        .dynamicTypeSize(GalleryArguments.dynamicType ?? .large)
        .sheet(isPresented: $showsSheet) {
            GallerySheetSample()
                .dynamicTypeSize(GalleryArguments.dynamicType ?? .large)
        }
        .onAppear { model.startIfNeeded() }
    }

    @ViewBuilder
    private func content(for section: Section) -> some View {
        switch section {
        case .tokens: GalleryTokens()
        case .type: GalleryType()
        case .horizon: GalleryHorizon()
        case .live: GalleryLive(model: model)
        case .rows: GalleryRows()
        case .disc: GalleryDisc()
        case .actions: GalleryActions()
        case .sheet:
            EditorialRow(title: "Open the sheet sample", rule: .top) { showsSheet = true }
        }
    }
}

/// Launch arguments of the gallery.
enum GalleryArguments {
    private static var arguments: [String] { ProcessInfo.processInfo.arguments }

    static var isRequested: Bool { arguments.contains("-gallery") }
    static var opensSheet: Bool { arguments.contains("-gallerySheet") }

    private static func value(after flag: String) -> String? {
        guard let index = arguments.firstIndex(of: flag), index + 1 < arguments.count else { return nil }
        return arguments[index + 1]
    }

    static var section: SystemGallery.Section? {
        value(after: "-gallerySection").flatMap(SystemGallery.Section.init(rawValue:))
    }

    static var dynamicType: DynamicTypeSize? {
        switch value(after: "-galleryType") {
        case "xSmall": return .xSmall
        case "large": return .large
        case "xLarge": return .xLarge
        case "xxxLarge": return .xxxLarge
        case "accessibility1": return .accessibility1
        case "accessibility3": return .accessibility3
        case "accessibility5": return .accessibility5
        default: return nil
        }
    }
}

// MARK: Pieces

private struct GalleryCaption: View {
    var text: String

    var body: some View {
        Text(verbatim: text)
            .step(.stateWord)
            .foregroundStyle(Ink.text2)
            .padding(.horizontal, Grid.margin)
            .accessibilityAddTraits(.isHeader)
    }
}

private struct GalleryCase<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Grid.unit * 2) {
            Text(verbatim: title)
                .step(.note)
                .foregroundStyle(Ink.text3)
                .padding(.horizontal, Grid.margin)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Grid.inner)
    }
}

// MARK: Tokens

private struct GalleryTokens: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Grid.unit * 2) {
            ForEach(InkTokens.all, id: \.name) { entry in
                HStack(spacing: Grid.unit * 3) {
                    swatch(entry.token.hex(highContrast: false))
                    swatch(entry.token.hex(highContrast: true))
                    Text(verbatim: entry.name)
                        .step(.secondary)
                        .foregroundStyle(Ink.text)
                    Spacer(minLength: 0)
                    Text(verbatim: label(entry.token))
                        .step(.data)
                        .foregroundStyle(Ink.text2)
                }
            }
            Text(verbatim: "Left: regular. Right: Increase Contrast. Margin 20, unit 4, hairline one pixel, radius 0.")
                .step(.note)
                .foregroundStyle(Ink.text2)
                .padding(.top, Grid.unit * 2)
        }
        .padding(.horizontal, Grid.margin)
    }

    private func swatch(_ hex: UInt32) -> some View {
        Rectangle()
            .fill(Color(uiColor: UIColor(grafitoHex: hex)))
            .frame(width: Grid.unit * 8, height: Grid.unit * 8)
            .overlay(Rectangle().strokeBorder(Ink.text3, lineWidth: 0.5))
    }

    private func label(_ token: InkToken) -> String {
        let regular = String(format: "#%06X", token.hex)
        guard token.highContrastHex != token.hex else { return regular }
        return regular + String(format: " · #%06X", token.highContrastHex)
    }
}

// MARK: Type

private struct GalleryType: View {
    private let samples: [(TypeStep, String, String)] = [
        (.figure, "1 · figure 72/80", "23:41"),
        (.figureSmall, "1 · figure small 56/64", "45:00"),
        (.name, "2 · name 28/34", "Esta noche"),
        (.header, "3 · header 22/28", "Temporizador"),
        (.nightAction, "4 · night action 20/25", "+15 min"),
        (.row, "5 · row 17/22 semibold", "Lluvia"),
        (.value, "5 · value 17 medium tabular", "65"),
        (.body, "6 · body 17/22", "Se mezclan en tu iPhone mientras suenan."),
        (.bar, "6 · bar 17 medium", "Mezclas"),
        (.secondary, "7 · secondary 15/20", "Hasta dormirme · 45 min"),
        (.note, "8 · note 13/18", "El sonido se funde; tu alarma no se toca."),
        (.data, "9 · datum 13/18 medium tabular", "65"),
        (.stateWord, "9 · state word, small caps", "guiando · 6 por minuto"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Grid.unit * 3) {
            ForEach(samples, id: \.1) { step, title, sample in
                VStack(alignment: .leading, spacing: 0) {
                    Text(verbatim: title)
                        .step(.note)
                        .foregroundStyle(Ink.text3)
                    Text(verbatim: sample)
                        .step(step)
                        .foregroundStyle(step.scaleStep >= 7 ? Ink.text2 : Ink.text)
                }
            }
        }
        .padding(.horizontal, Grid.margin)
    }
}

// MARK: Horizon

private struct GalleryHorizon: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GalleryCase(title: "rest · hairline, no colour") {
                mark(rms: 0, sounding: false, accent: false)
            }
            GalleryCase(title: "sounding · one quiet layer (−40 dBFS)") {
                mark(rms: 0.01, sounding: true, accent: true)
            }
            GalleryCase(title: "sounding · default mix (−18 dBFS)") {
                mark(rms: 0.125, sounding: true, accent: true)
            }
            GalleryCase(title: "sounding · everything at full (−6 dBFS)") {
                mark(rms: 0.5, sounding: true, accent: true)
            }
            GalleryCase(title: "sounding · a finger holds a level: plain ink") {
                mark(rms: 0.125, sounding: true, accent: false)
            }
            GalleryCase(title: "night page · one ink, never the accent") {
                mark(rms: 0.125, sounding: true, accent: true)
                    .environment(\.nightPhase, .nightPage)
            }
            GalleryCase(title: "night screen · sounding: continuous 2 pt") {
                mark(rms: 0.125, sounding: true, accent: false)
                    .environment(\.nightPhase, .night)
            }
            GalleryCase(title: "night screen · paused: absent") {
                mark(rms: 0, sounding: false, accent: false)
                    .environment(\.nightPhase, .night)
            }
        }
    }

    private func mark(rms: Float, sounding: Bool, accent: Bool) -> some View {
        SoundLineMark(rms: rms, isSounding: sounding, ownsAccent: accent)
            .frame(height: Grid.horizonBand)
            .padding(.horizontal, Grid.margin)
    }
}

// MARK: Live

/// The real thing: the Horizon reads the engine's RMS, the Disc starts and
/// stops it and two rows set real levels.
private struct GalleryLive: View {
    @ObservedObject var model: MixerModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GalleryCase(title: "engine · the line is the RMS the render thread publishes") {
                SoundLine(isSounding: model.isPlaying) { tau in
                    model.outputLevel(tau: tau)
                }
            }
            ForEach([SoundID.pink, .rain], id: \.self) { sound in
                LevelRule(
                    id: sound.rawValue,
                    name: sound.localizedName,
                    subtitle: Localized.string(sound.detailKey),
                    level: Binding(
                        get: { model.levels[sound] ?? 0 },
                        set: { model.setLevel(sound, $0) }
                    )
                )
            }
            .padding(.top, Grid.inner)
            HStack {
                Spacer()
                PlayDisc(isPlaying: model.isPlaying) { model.togglePlayback() }
                Spacer()
            }
        }
    }
}

// MARK: Rows

private struct GalleryRows: View {
    @State private var rain: Float = 0.3
    @State private var pink: Float = 0
    @State private var ocean: Float = 0.5
    @State private var wind: Float = 0.4
    @State private var lockedTaps = 0
    @State private var switchIsOn = true

    private func name(_ sound: SoundID) -> String { sound.localizedName }
    private func detail(_ sound: SoundID) -> String { Localized.string(sound.detailKey) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GalleryCase(title: "level row · live (drag sideways; a tap does nothing; hold for the slider)") {
                LevelRule(id: "gallery.rain", name: name(.rain), subtitle: detail(.rain), level: $rain)
                LevelRule(id: "gallery.pink", name: name(.pink), subtitle: detail(.pink), level: $pink)
            }
            GalleryCase(title: "level row · rest at 65") {
                face(.wind, 0.65, .rest)
            }
            GalleryCase(title: "level row · at 0: track only, value hidden") {
                face(.brown, 0, .rest)
            }
            GalleryCase(title: "level row · under the finger: the accent") {
                face(.rain, 0.38, .underFinger(accent: true))
            }
            GalleryCase(title: "level row · under the finger, night page") {
                face(.rain, 0.38, .underFinger(accent: true))
                    .environment(\.nightPhase, .nightPage)
            }
            GalleryCase(title: "level row · live, night page (20° cone; hold for the slider in one ink)") {
                LevelRule(id: "gallery.wind", name: name(.wind), subtitle: detail(.wind), level: $wind)
                    .environment(\.nightPhase, .nightPage)
            }
            GalleryCase(title: "level row · slider standing in for the line: labels and value unchanged") {
                face(.pink, 0.63, .fineSlider)
            }
            GalleryCase(title: "level row · Pro without access, saved level kept · taps \(lockedTaps)") {
                LevelRule(
                    id: "gallery.ocean",
                    name: name(.ocean),
                    subtitle: detail(.ocean),
                    level: $ocean,
                    isLocked: true,
                    onLockedTap: { lockedTaps += 1 }
                )
            }
            GalleryCase(title: "level row · Pro without access, no level") {
                face(.fan, 0, .locked)
            }
            GalleryCase(title: "level row · waiting: six others sound, its level kept") {
                face(.wind, 0.15, .waiting)
            }
            GalleryCase(title: "editorial row · 56, hairline above (page)") {
                EditorialRow(title: "Todas las capas", value: "y 2 más", rule: .top) {}
                EditorialRow(title: Localized.string("temporizador.titulo"), value: "Hasta dormirme · 45 min", rule: .top) {}
            }
            GalleryCase(title: "editorial row · 72 with subtitle, option chosen, state word") {
                EditorialRow(title: "Mar y viento", subtitle: "océano 50 · viento 20") {}
                EditorialRow(title: "45 min", isSelected: true) {}
                EditorialRow(title: name(.thunder), stateWord: Localized.string("comun.pro")) {}
            }
            GalleryCase(title: "switch · tokens only: off, on, on at night (nothing lighter than the ink); live") {
                HStack(spacing: Grid.group) {
                    GrafitoSwitch(isOn: false)
                    GrafitoSwitch(isOn: true)
                    GrafitoSwitch(isOn: true)
                        .environment(\.nightPhase, .nightPage)
                    Toggle(isOn: $switchIsOn) {
                        Text(verbatim: Localized.string("marea.titulo"))
                    }
                    .toggleStyle(GrafitoToggleStyle(showsLabel: false))
                }
                .padding(.horizontal, Grid.margin)
                .padding(.vertical, Grid.unit * 3)
            }
        }
    }

    private func face(_ sound: SoundID, _ level: Float, _ mode: LevelRuleFace.Mode) -> some View {
        VStack(spacing: 0) {
            LevelRuleFace(name: name(sound), subtitle: detail(sound), level: level, mode: mode)
            Color.clear.frame(height: Grid.layerChannel)
        }
    }
}

// MARK: Disc

private struct GalleryDisc: View {
    @State private var isPlaying = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GalleryCase(title: "disc · rest, sounding, final fade, night page") {
                HStack(spacing: Grid.inner) {
                    PlayDisc(isPlaying: false) {}
                    PlayDisc(isPlaying: true) {}
                    PlayDisc(isPlaying: true, isFading: true) {}
                    PlayDisc(isPlaying: false) {}
                        .environment(\.nightPhase, .nightPage)
                }
                .padding(.horizontal, Grid.margin - (Grid.largeTarget - Grid.disc) / 2)
            }
            GalleryCase(title: "disc · live (the whole 64 pt circle answers; hold to see the relief deepen)") {
                PlayDisc(isPlaying: isPlaying) { isPlaying.toggle() }
                    .padding(.horizontal, Grid.margin - (Grid.largeTarget - Grid.disc) / 2)
            }
            GalleryCase(title: "state word · small caps, never a badge") {
                HStack(spacing: Grid.inner) {
                    StateWord(text: Localized.string("comun.pro"))
                    StateWord(text: Localized.format("comun.pro.nivel", Int64(30)))
                    StateWord(text: "en pausa")
                }
                .padding(.horizontal, Grid.margin)
            }
        }
    }
}

// MARK: Actions

private struct GalleryActions: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GalleryCase(title: "primary action · a word between two hairlines, 64 pt (80 from AX1)") {
                HairlineAction(title: Localized.string("common.save")) {}
            }
            GalleryCase(title: "primary action · disabled, with its reason") {
                HairlineAction(
                    title: "Comprar",
                    isEnabled: false,
                    note: "La tienda no responde. Nada cambia: sigue sonando."
                ) {}
            }
            GalleryCase(title: "primary action · purchase with the price loaded: the only accent border") {
                HairlineAction(title: "Comprar · {displayPrice}", rules: .accent) {}
            }
            GalleryCase(title: "text action · secondary, 44 pt (56 from xL, 64 from AX3)") {
                TextAction(title: "Restaurar compra") {}
            }
            GalleryCase(title: "text action · night page: 64 pt, medium, one ink") {
                TextAction(title: "Ahora no") {}
                    .environment(\.nightPhase, .nightPage)
            }
            GalleryCase(title: "night action · Night and Small Hours: step 4, 64 pt (96 from AX3), one ink") {
                NightAction(title: Localized.string("comun.mas15")) {}
                    .environment(\.nightPhase, .night)
            }
        }
    }
}

// MARK: Sheet

private struct GallerySheetSample: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GrafitoSheet(title: Localized.string("temporizador.titulo"), detents: [.medium, .large]) {
            EditorialRow(title: "Hasta dormirme", value: "45 min", isSelected: false) {}
            EditorialRow(title: "45 min", isSelected: true) {}
            EditorialRow(title: Localized.string("temporizador.apagado")) {}
            HairlineAction(title: Localized.string("common.save")) { dismiss() }
                .padding(.top, Grid.group)
            TextAction(title: "Ahora no") { dismiss() }
        }
    }
}

#Preview("Gallery") {
    let purchases = PurchaseManager(trialStorage: InMemoryTrialStorage(), store: ScriptedProStore())
    return SystemGallery(model: MixerModel(purchases: purchases))
}
#endif
