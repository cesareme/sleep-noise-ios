import SwiftUI
import UIKit

/// The touch layer of a level row.
///
/// A level row lives inside a scroll view (the page, the Layers sheet), and
/// the two must share one finger: sideways is the level, anything else is the
/// scroll or the sheet's own dismissal. UIKit settles that the way it does
/// for every list with a sideways gesture: the row's pan recognizer only
/// begins when the first movement is within 30° of the horizontal, and when
/// it does not begin the touch simply belongs to the scroll view. A SwiftUI
/// `DragGesture` on the row, simultaneous or not, kept the scroll view from
/// scrolling at all when the touch started on the row.
///
/// The layer is transparent and draws nothing.
struct LevelTouchSurface: UIViewRepresentable {
    /// Sideways drag and long press. Off for a locked row.
    var adjusts: Bool
    /// Tap. Only a locked row has one, and a row showing its slider.
    var taps: Bool
    /// Tangent of the cone a drag must start inside: 30° by day, 20° on the
    /// night page.
    ///
    /// Pending (spike I0-2): 04 §2.2 also asks for 16 pt of travel before a
    /// night drag begins. The recognizer begins at the system's distance,
    /// about 10 pt, in every phase; holding it back needs the scroll view's
    /// own pan to wait for this one, and that is the spike's question.
    var coneTangent = LevelDrag.coneTangent
    var onPanBegan: () -> Void
    /// Horizontal translation since the touch began, in points.
    var onPanChanged: (CGFloat) -> Void
    var onPanEnded: () -> Void
    var onHold: () -> Void
    var onTap: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isAccessibilityElement = false

        let coordinator = context.coordinator
        let pan = UIPanGestureRecognizer(target: coordinator, action: #selector(Coordinator.handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = coordinator
        view.addGestureRecognizer(pan)
        coordinator.pan = pan

        let hold = UILongPressGestureRecognizer(target: coordinator, action: #selector(Coordinator.handleHold(_:)))
        hold.minimumPressDuration = Grid.longPress
        hold.allowableMovement = Grid.longPressSlop
        hold.delegate = coordinator
        view.addGestureRecognizer(hold)
        coordinator.hold = hold

        let tap = UITapGestureRecognizer(target: coordinator, action: #selector(Coordinator.handleTap(_:)))
        tap.delegate = coordinator
        view.addGestureRecognizer(tap)
        coordinator.tap = tap

        apply(to: coordinator)
        return view
    }

    func updateUIView(_ view: UIView, context: Context) {
        context.coordinator.surface = self
        apply(to: context.coordinator)
    }

    private func apply(to coordinator: Coordinator) {
        coordinator.pan?.isEnabled = adjusts
        coordinator.hold?.isEnabled = adjusts
        coordinator.tap?.isEnabled = taps
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var surface: LevelTouchSurface
        weak var pan: UIPanGestureRecognizer?
        weak var hold: UILongPressGestureRecognizer?
        weak var tap: UITapGestureRecognizer?

        init(_ surface: LevelTouchSurface) {
            self.surface = surface
        }

        @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
            switch recognizer.state {
            case .began:
                surface.onPanBegan()
                surface.onPanChanged(recognizer.translation(in: recognizer.view).x)
            case .changed:
                surface.onPanChanged(recognizer.translation(in: recognizer.view).x)
            case .ended, .cancelled, .failed:
                surface.onPanEnded()
            default:
                break
            }
        }

        @objc func handleHold(_ recognizer: UILongPressGestureRecognizer) {
            if recognizer.state == .began {
                surface.onHold()
            }
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            if recognizer.state == .ended {
                surface.onTap()
            }
        }

        /// The cone: the pan begins only when the movement so far is within
        /// 30° of the horizontal (20° on the night page). Otherwise it fails and the scroll gets the
        /// touch; that is decided once and holds until the finger lifts.
        func gestureRecognizerShouldBegin(_ recognizer: UIGestureRecognizer) -> Bool {
            guard let pan = recognizer as? UIPanGestureRecognizer, pan === self.pan else { return true }
            var movement = pan.translation(in: pan.view)
            if movement == .zero {
                movement = pan.velocity(in: pan.view)
            }
            return LevelDrag.axis(
                for: CGSize(width: movement.x, height: movement.y),
                coneTangent: surface.coneTangent
            ) == .level
        }

        /// The row's own recognizers work together (hold, then drag without
        /// lifting). With anything else, the scroll included, never.
        func gestureRecognizer(
            _ recognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool {
            let own: [UIGestureRecognizer?] = [pan, hold, tap]
            return own.contains { $0 === recognizer } && own.contains { $0 === other }
        }
    }
}
