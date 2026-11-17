import SwiftUI

/// The sheet (03 §4.10): another room.
///
/// A system sheet on `hoja` with `trazo-hoja` hairlines, the real drag
/// indicator and no Close button: it is dismissed with the gesture. The
/// header is a step-3 title on the left over a hairline.
///
/// A sheet is never black on black (PLAN-SIMPLE §4.1), Layers included.
/// `.black` stays as a surface for whoever needs the page's black and its
/// `trazo` hairlines; no sheet of 1.0 asks for it.
struct GrafitoSheet<Content: View>: View {
    var title: String
    var surface = InkSurface.sheet
    var detents: Set<PresentationDetent> = [.large]
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SheetHeader(title: title)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .grafitoSheet(surface: surface, detents: detents)
    }
}

/// Title of a sheet: step 3, 20 pt from the edge, over a hairline. A sheet
/// opened from the night page takes its one ink, title included.
struct SheetHeader: View {
    var title: String

    @Environment(\.nightPhase) private var phase

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(verbatim: title)
                .step(.header)
                .foregroundStyle(Ink.primary(phase))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Grid.margin)
                .padding(.top, Grid.unit * 6)
                .padding(.bottom, Grid.inner)
                .accessibilityAddTraits(.isHeader)
            Hairline().padding(.horizontal, Grid.margin)
        }
    }
}

extension View {
    /// Styles the content of a `.sheet` as a Grafito sheet: surface colour,
    /// matching hairlines for everything inside, the system indicator, dark
    /// only and no inherited tint.
    func grafitoSheet(
        surface: InkSurface = .sheet,
        detents: Set<PresentationDetent> = [.large]
    ) -> some View {
        self
            .environment(\.inkSurface, surface)
            .tint(Ink.text)
            .presentationBackground(surface == .sheet ? Ink.sheet : Ink.background)
            .presentationDragIndicator(.visible)
            .presentationDetents(detents)
            .preferredColorScheme(.dark)
    }
}

#Preview("Sheet") {
    Color.black
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            GrafitoSheet(title: "Sleep timer", detents: [.medium, .large]) {
                EditorialRow(title: "45 min", isSelected: true) {}
                EditorialRow(title: "Off") {}
                HairlineAction(title: "Save") {}
                    .padding(.top, Grid.group)
            }
        }
}
