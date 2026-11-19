import SwiftUI

/// Layers (03 §5, surface 5): "which layers, and how loud?".
///
/// Every texture as a level row, the three colours and then the beds, with
/// no slots and no gaps. A sheet on `hoja` with `trazo-hoja` hairlines, the
/// real drag indicator and no Close button. The bar stays, so the Disc is
/// always in reach: nothing blocks the sound.
///
/// Six layers may sound at once. That is a rule of the model, so the sheet
/// draws nothing for it: the row of a seventh says "Six at once" and does
/// not move, and in a mix that already holds more than six the rows that
/// wait say it for as long as they wait. A Pro layer without access says "pro" in words (and keeps its
/// saved level, "pro · 30"); a tap on it opens the Pro sheet only while
/// something may be sold. At night nothing here sells.
///
/// By day each row carries the painted rule of its texture in the left
/// margin (`LevelRulePaint`, camino-contenido.md): live while the layer
/// sounds, dry at zero. Whether the rows carry it is decided when the
/// sheet opens (`PaintPolicy.phase`) and holds for the visit; if the rule
/// turns absent with the sheet open (21:00) the rules fade and stay faded.
/// At night, on the night page and with the switches on there is none.
struct LayersSheet: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var purchases: PurchaseManager
    /// "Mixes" on the bar: the caller swaps this sheet for that one.
    var onMixes: () -> Void
    /// "Night" on the bar: the caller closes this sheet first, because
    /// Night never opens over one.
    var onNight: () -> Void

    @Environment(\.nightPhase) private var phase
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.isLuminanceReduced) private var luminanceReduced
    /// The box of a section header: 18 pt at Large (05 §2.7).
    @ScaledMetric(relativeTo: .footnote) private var headerLine: CGFloat = 18
    @State private var arbiter = IndexArbiter()
    @State private var sliderDismissal = 0
    /// What the paint rule said when the sheet opened. Nil until the first draw.
    @State private var paintsOnOpen: Bool?
    /// The rules faded with the sheet open and stay faded.
    @State private var paintFaded = false

    private static let contentID = "layers.content"

    /// Whether the rows paint their rule now. The sheet is in front, so
    /// nothing dims it; the scene phase is read so a return from the
    /// background after 21:00 redraws the sheet.
    private var paintsNow: Bool {
        _ = scenePhase
        let conditions = PaintConditions(
            model: model,
            isLuminanceReduced: luminanceReduced,
            contrast: contrast,
            reduceTransparency: reduceTransparency,
            reduceMotion: reduceMotion,
            sheetPresented: false,
            scenePhase: .active
        )
        return PaintPolicy.phase(conditions).exists
    }

    var body: some View {
        // Read once per draw; the model checks again on the tap.
        let canSell = model.canSell
        let paints = paintsNow
        let paint: LevelRulePaint? = (paintsOnOpen ?? paints)
            ? LevelRulePaint(sound: .white, shows: !paintFaded, fade: Motion.phase(reduceMotion: reduceMotion))
            : nil
        VStack(spacing: 0) {
            SheetHeader(title: Localized.string("capas.titulo"))
                .contentShape(Rectangle())
                .onTapGesture { sliderDismissal += 1 }
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        section("capas.seccion.colores", PageLayers.colors, canSell: canSell, paint: paint)
                            .padding(.top, Grid.inner)
                        section("capas.seccion.camas", PageLayers.beds, canSell: canSell, paint: paint)
                            .padding(.top, Grid.group)
                        notes
                    }
                    .padding(.bottom, Grid.group)
                    .id(Self.contentID)
                }
                #if DEBUG
                .onAppear {
                    // Reference captures of the end of the sheet.
                    if PageArguments.scrollsLayersToEnd {
                        proxy.scrollTo(Self.contentID, anchor: .bottom)
                    }
                }
                #endif
            }
            PageBar(model: model, timer: model.timer, onMixes: onMixes, onNight: onNight)
        }
        .environment(\.fineSliderDismissal, sliderDismissal)
        .indexArbiter(arbiter)
        .grafitoSheet(surface: .sheet)
        .accessibilityAction(.magicTap) { model.togglePlayback() }
        .onAppear {
            if paintsOnOpen == nil { paintsOnOpen = paints }
        }
        .onChange(of: paints) { _, shows in
            // The rules fade as the window of the page does and do not
            // come back while the sheet is up.
            if !shows, paintsOnOpen == true { paintFaded = true }
        }
        .sheet(isPresented: Binding(
            get: { model.showPaywall },
            set: { if !$0 { model.dismissPro() } }
        )) {
            ProSheet(purchases: purchases, model: model)
                #if DEBUG
                .modifier(DebugDynamicType())
                #endif
        }
    }

    private func section(_ titleKey: String, _ sounds: [SoundID], canSell: Bool, paint: LevelRulePaint?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(verbatim: Localized.string(titleKey))
                .step(.stateWord)
                .foregroundStyle(Ink.secondary(phase))
                .frame(minHeight: headerLine)
                .padding(.horizontal, Grid.margin)
                .padding(.bottom, Grid.unit + 2)
                .accessibilityAddTraits(.isHeader)
            ForEach(sounds) { sound in
                LayerRow(
                    model: model,
                    sound: sound,
                    hasFullAccess: purchases.hasFullAccess,
                    canSell: canSell,
                    paint: paint.map { LevelRulePaint(sound: sound, shows: $0.shows, fade: $0.fade) }
                )
            }
        }
    }

    /// One paragraph, so the two notes keep the line height of the step
    /// between them as well.
    private var notes: some View {
        Text(verbatim: Localized.string("capas.nota") + "\n" + Localized.string("capas.cero"))
            .step(.secondary)
            .foregroundStyle(Ink.secondary(phase))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Grid.margin)
            .padding(.top, Grid.inner)
    }
}
