import SwiftUI

/// Mixes (03 §5, surfaces 12 and 13): "which mix do I load?".
///
/// A sheet on `hoja`, like Layers: the person's mixes, with the live one
/// first while it is still "Tonight", and the four of the house. Each row is
/// a name and its recipe in words; a layer that needs Pro is said at the end
/// of the recipe, never struck through. A tap loads the mix and goes back to
/// the page: with something sounding the mix gives way to it, with nothing
/// sounding it starts like a Play. A mix with Pro layers loads trimmed and
/// never raises the Pro sheet (C18).
///
/// The live mix is saved from its row, or from its name on the page. Three
/// saved mixes are free; the row of a fourth says "pro", and its touch asks
/// for the Pro sheet only while something may be sold. Renaming, deleting
/// and reordering are things of the day: on the night page a touch loads,
/// and that is all.
///
/// By day the four rows of the house carry their painted band, bled off
/// the left edge (exploration 12 §6.1, decided 19-11-2026): the house
/// paints, what is yours is yours. Whether a row is laid out with its band
/// is decided when the sheet opens (`PaintPolicy`) and holds for the visit,
/// so nothing moves; when the rule turns false with the sheet open (21:00,
/// the night page) the band fades and does not come back by itself. Opened
/// with the rule false, the row is exactly the row without paint.
///
/// The bar stays, so the Disc is always in reach.
struct MixesSheet: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var store: MixStore
    @ObservedObject var purchases: PurchaseManager
    /// A mix was loaded: the caller closes this sheet.
    var onLoaded: () -> Void
    /// "Night" on the bar: the caller closes this sheet first.
    var onNight: () -> Void
    /// "Settings", the last row: the caller puts Settings in this place.
    var onSettings: () -> Void

    @Environment(\.nightPhase) private var phase
    @Environment(\.dynamicTypeSize) private var dynamicType
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.isLuminanceReduced) private var luminanceReduced
    @Environment(\.scenePhase) private var scenePhase
    /// The box of a section header: 18 pt at Large.
    @ScaledMetric(relativeTo: .footnote) private var headerLine: CGFloat = 18
    @State private var naming = MixNaming()
    @State private var deleting: SavedMix?
    /// What `PaintPolicy` said when the sheet opened: the layout of the
    /// house rows for the whole visit. Nil until the first draw.
    @State private var paintsOnOpen: Bool?
    /// The band has faded with the sheet open and stays faded.
    @State private var paintFaded = false

    private static let contentID = "mixes.content"

    init(
        model: MixerModel,
        purchases: PurchaseManager,
        onLoaded: @escaping () -> Void,
        onNight: @escaping () -> Void,
        onSettings: @escaping () -> Void
    ) {
        self.model = model
        store = model.mixStore
        self.purchases = purchases
        self.onLoaded = onLoaded
        self.onNight = onNight
        self.onSettings = onSettings
    }

    private var list: MixesList {
        MixesList(MixesList.Input(
            saved: store.mixes,
            levels: model.levels,
            loaded: model.loadedMix,
            isPlaying: model.isPlaying,
            hasFullAccess: purchases.hasFullAccess
        ))
    }

    /// The rule of the house paint, now. `saleClock` redraws the sheet at
    /// 21:00 with the app in front; coming back to the foreground after
    /// 21:00 does not touch the model's clock, so the scene phase is read
    /// here too and the return redraws the sheet.
    private var showsPaintNow: Bool {
        _ = scenePhase
        // The one rule of the paint, with the setting "never" and the two
        // switches together, as the window and Layers read it. The sheet
        // is in front, so nothing dims it.
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
        let list = self.list
        // Read once per draw; the model checks again on the tap.
        let canSell = model.canSell
        let showsPaint = showsPaintNow
        let paintsLayout = paintsOnOpen ?? showsPaint
        VStack(spacing: 0) {
            SheetHeader(title: Localized.string("mezclas.titulo"))
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header("mezclas.seccion.tuyas")
                            .padding(.top, Grid.inner)
                        if let live = list.live {
                            liveRow(live, canSell: canSell)
                        }
                        ForEach(list.yours) { row in
                            savedRow(row, in: list)
                        }
                        if list.showsEmptyNote {
                            emptyNote
                        }
                        header("mezclas.seccion.casa")
                            .padding(.top, Grid.group)
                        ForEach(list.house) { row in
                            MixRow(
                                name: row.name,
                                recipe: row.recipe,
                                stateWord: row.isSounding ? Localized.string("mezclas.sonando") : nil,
                                paint: paintsLayout ? housePaint(of: row) : nil,
                                paintShows: !paintFaded
                            ) {
                                load(row.reference)
                            }
                            .accessibilityIdentifier("mix.\(row.id)")
                        }
                        settingsRow
                            .padding(.top, Grid.group)
                    }
                    .padding(.bottom, Grid.group)
                    .id(Self.contentID)
                }
                #if DEBUG
                .onAppear {
                    // Reference capture of the end of the sheet.
                    if PageArguments.scrollsMixesToEnd {
                        proxy.scrollTo(Self.contentID, anchor: .bottom)
                    }
                }
                #endif
            }
            PageBar(model: model, timer: model.timer, onMixes: nil, onNight: onNight)
        }
        // The keyboard of the naming alert does not lift the bar: nothing
        // changes position (03 §3.7).
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .grafitoSheet(surface: .sheet)
        .accessibilityAction(.magicTap) { model.togglePlayback() }
        .onAppear {
            if paintsOnOpen == nil { paintsOnOpen = showsPaint }
        }
        .onChange(of: showsPaint) { _, shows in
            // The band fades as a change of night phase does and does not
            // come back: the row keeps its layout and the gap reads as a
            // margin (content path, "fundir").
            guard !shows, paintsLayout, !paintFaded else { return }
            withAnimation(.easeInOut(duration: reduceMotion ? Motion.phaseReduced : Motion.phase)) {
                paintFaded = true
            }
        }
        #if DEBUG
        .task {
            // Reference captures of the two alerts, once the sheet is up.
            try? await Task.sleep(for: .milliseconds(900))
            if let staged = MixesArguments.naming(model) { naming = staged }
            if let staged = MixesArguments.deleting(model) { deleting = staged }
        }
        #endif
        .mixNaming($naming, model: model) { _ in
            AccessibilityNotification.Announcement(Localized.string("mezclas.guardada")).post()
        }
        // An alert, like saving and renaming: centred, with "Cancel". A
        // confirmation dialog hung from the sheet floated over rows it had
        // nothing to do with and showed no way out.
        .alert(
            Text(verbatim: Localized.format("mezclas.eliminar.titulo", deleting?.name ?? "")),
            isPresented: Binding(
                get: { deleting != nil },
                set: { if !$0 { deleting = nil } }
            ),
            presenting: deleting
        ) { mix in
            Button("comun.eliminar", role: .destructive) {
                model.deleteMix(mix.id)
            }
            Button("common.cancel", role: .cancel) {}
        } message: { _ in
            Text("mezclas.eliminar.nota")
        }
    }

    // MARK: Rows

    /// The house mix a row of "from the house" is, for its band.
    private func housePaint(of row: MixesList.Row) -> HouseMix? {
        if case .house(let mix) = row.reference { return mix }
        return nil
    }

    private func header(_ key: String) -> some View {
        Text(verbatim: Localized.string(key))
            .step(.stateWord)
            .foregroundStyle(Ink.secondary(phase))
            .frame(minHeight: headerLine)
            .padding(.horizontal, Grid.margin)
            .padding(.bottom, Grid.unit + 2)
            .accessibilityAddTraits(.isHeader)
    }

    /// "Settings" (08 §2.1): the last row and the only way in, in secondary
    /// ink and apart from the mixes, because it is a way out and not a mix.
    /// Words, not an icon.
    private var settingsRow: some View {
        Button(action: onSettings) {
            Text("ajustes.titulo")
                .step(.body)
                .foregroundStyle(Ink.secondary(phase))
                .padding(.vertical, Grid.unit * 3)
                .padding(.horizontal, Grid.margin)
                .frame(
                    maxWidth: .infinity,
                    minHeight: max(
                        Grid.row(subtitle: false, dynamicType: dynamicType),
                        Grid.textAction(dynamicType: dynamicType, night: phase.isNight)
                    ),
                    alignment: .leading
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(PressedReliefStyle())
        .accessibilityIdentifier("openSettings")
    }

    /// The live mix. Its touch saves it; the fourth without access says
    /// "pro" and offers the Pro sheet only while something may be sold.
    /// Saving is a thing of the day (08 §2.2): on the night page the row
    /// only says what is sounding.
    private func liveRow(_ live: MixesList.Live, canSell: Bool) -> some View {
        let isNight = phase.isNight
        // On the night page nothing says "requires Pro" (copy guide §3).
        let namesPro = live.needsPro && !isNight
        let hint: String
        if isNight || (live.needsPro && !canSell) {
            hint = ""
        } else {
            hint = Localized.string(live.needsPro ? "ax.guardar.pro.pista" : "ax.esta_noche.pista")
        }
        return MixRow(
            name: Localized.string("mezclas.esta_noche"),
            recipe: live.recipe,
            stateWord: live.needsPro ? Localized.string("comun.pro") : nil,
            spokenName: Localized.string(namesPro ? "ax.guardar.pro" : "ax.esta_noche"),
            hint: hint,
            // On the night page it only says what is sounding: words, not
            // a button that does nothing.
            isInert: isNight
        ) {
            if !isNight { beginSave() }
        }
        .contextMenu {
            if !isNight {
                Button {
                    beginSave()
                } label: {
                    Text("mezcla.menu.guardar")
                    // Its second line, as in the menu of the name.
                    if live.needsPro { Text("comun.pro") }
                }
                .disabled(live.needsPro && !canSell)
            }
        }
        .accessibilityActions {
            if !isNight {
                Button {
                    beginSave()
                } label: {
                    Text(live.needsPro ? "ax.guardar.pro" : "ax.accion.guardar")
                }
            }
        }
        .accessibilityIdentifier("mix.live")
    }

    private func savedRow(_ row: MixesList.Row, in list: MixesList) -> some View {
        let mix = store.mixes.first { MixReference.saved($0.id) == row.reference }
        let index = list.yours.firstIndex(of: row) ?? 0
        let canEdit = !phase.isNight && mix != nil
        return MixRow(
            name: row.name,
            recipe: row.recipe,
            stateWord: row.isSounding ? Localized.string("mezclas.sonando") : nil,
            isOwnName: true
        ) {
            load(row.reference)
        }
        .contextMenu {
            if canEdit, let mix {
                Button {
                    naming.beginRename(mix)
                } label: {
                    Text("comun.renombrar")
                }
                if index > 0 {
                    Button {
                        model.moveMix(mix.id, by: -1)
                    } label: {
                        Text("ax.accion.subir")
                    }
                }
                if index < list.yours.count - 1 {
                    Button {
                        model.moveMix(mix.id, by: 1)
                    } label: {
                        Text("ax.accion.bajar")
                    }
                }
                Button(role: .destructive) {
                    deleting = mix
                } label: {
                    Text("comun.eliminar")
                }
            }
        }
        .accessibilityActions {
            if canEdit, let mix {
                Button {
                    naming.beginRename(mix)
                } label: {
                    Text("comun.renombrar")
                }
                Button {
                    deleting = mix
                } label: {
                    Text("comun.eliminar")
                }
                if index > 0 {
                    Button {
                        model.moveMix(mix.id, by: -1)
                    } label: {
                        Text("ax.accion.subir")
                    }
                }
                if index < list.yours.count - 1 {
                    Button {
                        model.moveMix(mix.id, by: 1)
                    } label: {
                        Text("ax.accion.bajar")
                    }
                }
            }
        }
        .accessibilityIdentifier("mix.\(row.id)")
    }

    /// Takes the place of the rows of "yours" while nothing is saved. A
    /// sentence, not a button.
    private var emptyNote: some View {
        Text("mezclas.vacio")
            .step(.body)
            .foregroundStyle(Ink.secondary(phase))
            .frame(maxWidth: .infinity, minHeight: Grid.rowSubtitle - Grid.unit * 6, alignment: .leading)
            .padding(.vertical, Grid.unit * 3)
            .padding(.horizontal, Grid.margin)
            .overlay(alignment: .bottom) {
                Hairline().padding(.horizontal, Grid.margin)
            }
    }

    // MARK: Actions

    private func load(_ reference: MixReference) {
        model.playMix(reference)
        onLoaded()
    }

    private func beginSave() {
        guard model.canSaveMix else {
            // Dropped at night; by day this sheet steps aside for Pro.
            model.offerPro()
            return
        }
        naming.beginSave(model)
    }
}

/// A row of the Mixes sheet: the name, the recipe under it in as many lines
/// as it needs, and a state word on the line of the name. The whole row is
/// the button; pressed, it shows the relief for 200 ms.
///
/// A row of the house may carry its painted band: 64 pt bled off the left
/// edge, under a 12 % veil, the text 20 pt from it. The band is decoration:
/// VoiceOver does not know it is there, and the row is as tall as without
/// it. The band clips to the row from the top; at the text sizes where the
/// row is taller than the piece, the piece grows with the row.
private struct MixRow: View {
    var name: String
    var recipe: MixRecipe
    var stateWord: String?
    /// The house mix whose band the row is laid out with, or nil for a row
    /// without paint: a saved mix, or the house at night.
    var paint: HouseMix?
    /// False once the band has faded with the sheet open.
    var paintShows = true
    /// A name the person wrote may shrink a little before it is cut.
    var isOwnName = false
    /// What VoiceOver reads instead of the name.
    var spokenName: String?
    var hint: String?
    /// The row is text: no touch, no relief, no button trait.
    var isInert = false
    var action: () -> Void

    @Environment(\.nightPhase) private var phase
    @Environment(\.dynamicTypeSize) private var dynamicType

    var body: some View {
        Group {
            if isInert {
                face
            } else {
                Button(action: action) { face }
                    .buttonStyle(PressedReliefStyle())
            }
        }
        .overlay(alignment: .bottom) {
            Hairline().padding(.leading, textLeading).padding(.trailing, Grid.margin)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: MixesList.spokenLabel(
            name: spokenName ?? name,
            recipe: recipe.spoken(namesPro: !phase.isNight)
        )))
        .accessibilityValue(Text(verbatim: stateWord ?? ""))
        .accessibilityHint(Text(verbatim: isInert ? "" : hint ?? Localized.string("ax.mezcla.pista")))
        .accessibilityAddTraits(isInert ? .isStaticText : .isButton)
    }

    /// 12 + 22 + 2 + 20 per line of recipe + 16 (mock-up, plate 14): 72 pt
    /// with a recipe of one line and 92 with two. Every text takes whole
    /// lines of the scale, so the row stays on the grid however it wraps.
    private var face: some View {
        VStack(alignment: .leading, spacing: Grid.unit / 2) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: Grid.inner) {
                    title
                    Spacer(minLength: 0)
                    state
                }
                // Larger text: the state drops under the name.
                VStack(alignment: .leading, spacing: Grid.unit / 2) {
                    title
                    state
                }
            }
            // On the night page a recipe never says "is Pro".
            Text(verbatim: recipe.text(namesPro: !phase.isNight, loosePro: dynamicType >= .accessibility5))
                .step(.secondary)
                .monospacedDigit()
                .foregroundStyle(Ink.secondary(phase))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineBox(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Grid.unit * 3)
        .padding(.bottom, Grid.unit * 4)
        .padding(.leading, textLeading)
        .padding(.trailing, Grid.margin)
        .frame(minHeight: Grid.row(subtitle: true, dynamicType: dynamicType))
        .background(alignment: .leading) {
            if let paint { band(paint) }
        }
        .contentShape(Rectangle())
    }

    /// Where the text starts: 20 pt from the edge, or 20 pt from the band.
    private var textLeading: CGFloat {
        paint == nil ? Grid.margin : HousePaint.textLeading
    }

    /// The painted band: a clear column the height of the row, with the
    /// piece hung from its top and clipped to it. The piece is taller than
    /// any row (`HousePaint.bandSize`), so it is drawn at 1:1 and the row
    /// shows its top; `.fill` only covers a row taller than the piece.
    private func band(_ mix: HouseMix) -> some View {
        Color.clear
            .frame(width: HousePaint.bandSize.width)
            .overlay(alignment: .top) {
                Image(HousePaint.bandName(mix))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .clipped()
            .overlay(Color.black.opacity(HousePaint.veil))
            .opacity(paintShows ? 1 : 0)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private var title: some View {
        Text(verbatim: name)
            .step(.row)
            .foregroundStyle(Ink.primary(phase))
            .lineLimit(dynamicType.isAccessibilitySize ? 2 : 1)
            .minimumScaleFactor(isOwnName ? 0.8 : 1)
            .multilineTextAlignment(.leading)
            .lineBox(.row)
    }

    /// Small caps by day. On the night page a state is never set in small
    /// caps (03 §3.4): it takes the step of the recipe.
    @ViewBuilder private var state: some View {
        if let stateWord {
            if phase.isNight {
                Text(verbatim: stateWord)
                    .step(.secondary)
                    .foregroundStyle(Ink.secondary(phase))
            } else {
                StateWord(text: stateWord)
            }
        }
    }
}

// MARK: - Naming a mix

/// The one alert that asks for the name of a mix: to save the live one, or
/// to rename a saved one. The field and what it is for change together, so
/// the alert never opens on a stale name.
struct MixNaming: Equatable {
    enum Purpose: Equatable {
        case save
        case rename(UUID)
    }

    var isPresented = false
    var purpose = Purpose.save
    var draft = ""

    /// The field starts from the name the mix already has, or from the one
    /// its layers give it.
    @MainActor
    mutating func beginSave(_ model: MixerModel) {
        purpose = .save
        draft = model.suggestedMixName
        isPresented = true
    }

    mutating func beginRename(_ mix: SavedMix) {
        purpose = .rename(mix.id)
        draft = mix.name
        isPresented = true
    }

    /// What the field keeps of what was typed: no more characters than a
    /// stored name has (`MixCodec.maxNameLength`).
    static func bounded(_ typed: String) -> String {
        typed.count > MixCodec.maxNameLength ? String(typed.prefix(MixCodec.maxNameLength)) : typed
    }
}

private struct MixNamingAlert: ViewModifier {
    @Binding var naming: MixNaming
    @ObservedObject var model: MixerModel
    var onSaved: (SavedMix) -> Void

    func body(content: Content) -> some View {
        content.alert(
            Text(naming.purpose == .save ? "mezcla.guardar.titulo" : "comun.renombrar"),
            isPresented: $naming.isPresented
        ) {
            TextField("mezcla.guardar.campo", text: $naming.draft)
            Button("common.save") {
                switch naming.purpose {
                case .save:
                    if case .saved(let mix) = model.saveCurrent(name: naming.draft) {
                        onSaved(mix)
                    }
                case .rename(let id):
                    model.renameMix(id, to: naming.draft)
                }
            }
            Button("common.cancel", role: .cancel) {}
        }
        .onChange(of: naming.draft) { _, typed in
            // The field stops at the length a name is stored with, so
            // nothing is cut behind the person's back after "Save".
            let kept = MixNaming.bounded(typed)
            if kept != typed { naming.draft = kept }
        }
    }
}

extension View {
    /// The system alert with a field that saves the live mix or renames a
    /// saved one (08 §2.2). `onSaved` runs after a save that went through.
    func mixNaming(
        _ naming: Binding<MixNaming>,
        model: MixerModel,
        onSaved: @escaping (SavedMix) -> Void = { _ in }
    ) -> some View {
        modifier(MixNamingAlert(naming: naming, model: model, onSaved: onSaved))
    }
}
