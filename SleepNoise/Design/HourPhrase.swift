import Foundation

/// A sentence that says an hour of the clock ("Fades at 3:42").
///
/// Spanish says "a las 3:42" and "a la 1:30": the article follows the hour
/// that is read, and one is singular. Every key that says an hour has a
/// second one, with the suffix `.una`, for the hour that reads "one". In
/// English both say the same.
enum HourPhrase {
    static let oneSuffix = ".una"

    /// The keys that say an hour. Each has its `.una` in the catalog.
    static let keys = [
        "ax.anuncio.hasta",
        "marea.retira.hora",
        "noche.estado.funde",
        "noche.estado.hasta",
        "noche.estado.termino",
        "pagina.estado.sonando.funde",
        "pagina.estado.sonando.hasta",
        "temporizador.estado.manto",
        "temporizador.manto.detalle",
    ]

    /// The key for an hour as it will be shown: "1:30", "01:30" and
    /// "1:30 p. m." read "one"; "13:30", "0:30" and "11:30" do not.
    static func key(_ key: String, at time: String) -> String {
        readsOne(time) ? key + oneSuffix : key
    }

    /// True when the first figure of a formatted time is a one.
    static func readsOne(_ time: String) -> Bool {
        let hour = time.drop { !$0.isNumber }.prefix { $0.isNumber }
        return Int(hour) == 1
    }
}
