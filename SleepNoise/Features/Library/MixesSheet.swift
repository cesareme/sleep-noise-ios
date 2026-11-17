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
/// The bar stays, so the Disc is always in reach.
struct MixesSheet: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var store: MixStore
    @ObservedObject var purchases: PurchaseManager
    /// A mix was loaded: the caller closes this sheet.
    var onLoaded: () -> Void
    /// "Night" on the bar: the caller closes this sheet first.
    var onNight: () -> Void

    @Environment(\.nightPhase) private var phase
    /// The box of a section header: 18 pt at Large.
    @ScaledMetric(relativeTo: .footnote) private var headerLine: CGFloat = 18
    @State private var naming = MixNaming()
    @State private var deleting: SavedMix?

    init(
        model: MixerModel,
        purchases: PurchaseManager,
        onLoaded: @escaping () -> Void,
        onNight: @escaping () -> Void
    ) {
        self.model = model
        store = model.mixStore
        self.purchases = purchases
        self.onLoaded = onLoaded
        self.onNight = onNight
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

    var body: some View {
        let list = self.list
        // Read once per draw; the model checks again on the tap.
        let canSell = model.canSell
        VStack(spacing: 0) {
            SheetHeader(title: Localized.string("mezclas.titulo"))
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
                            stateWord: row.isSounding ? Localized.string("mezclas.sonando") : nil
                        ) {
                            load(row.reference)
                        }
                        .accessibilityIdentifier("mix.\(row.id)")
                    }
                }
                .padding(.bottom, Grid.group)
            }
            PageBar(model: model, timer: model.timer, onMixes: nil, onNight: onNight)
        }
        .grafitoSheet(surface: .sheet)
        .accessibilityAction(.magicTap) { model.togglePlayback() }
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

    private func header(_ key: String) -> some View {
        Text(verbatim: Localized.string(key))
            .step(.stateWord)
            .foregroundStyle(Ink.secondary(phase))
            .frame(minHeight: headerLine)
            .padding(.horizontal, Grid.margin)
            .padding(.bottom, Grid.unit + 2)
            .accessibilityAddTraits(.isHeader)
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
                    Text(live.needsPro ? "mezcla.menu.guardar.pro" : "mezcla.menu.guardar")
                }
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
private struct MixRow: View {
    var name: String
    var recipe: MixRecipe
    var stateWord: String?
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
            Hairline().padding(.horizontal, Grid.margin)
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
            Text(verbatim: recipe.text(namesPro: !phase.isNight))
                .step(.secondary)
                .monospacedDigit()
                .foregroundStyle(Ink.secondary(phase))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Grid.unit * 3)
        .padding(.horizontal, Grid.margin)
        .frame(minHeight: Grid.row(subtitle: true, dynamicType: dynamicType))
        .contentShape(Rectangle())
    }

    private var title: some View {
        Text(verbatim: name)
            .step(.row)
            .foregroundStyle(Ink.primary(phase))
            .lineLimit(dynamicType.isAccessibilitySize ? 2 : 1)
            .minimumScaleFactor(isOwnName ? 0.8 : 1)
            .multilineTextAlignment(.leading)
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
