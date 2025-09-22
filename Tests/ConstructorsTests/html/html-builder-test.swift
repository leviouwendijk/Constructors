// import XCTest
// @testable import Constructors
import Testing
@testable import Constructors

@Suite("HTML DSL")
struct HTMLDSLTests {
// final class HTMLDSLTests: XCTestCase {
    var HMFooter: HTMLFragment {
        [
            HTML.div(.class(["footer"])) {
                HTML.text("Hondenmeesters | Ondersteuning bij hondengedrag"); HTML.br()
                HTML.text("Marterkoog 7B"); HTML.br()
                HTML.text("1822BK Alkmaar"); HTML.br(); HTML.br()
                HTML.text("Telefoon: +31 6 23 62 13 90")
            }
        ]
    }

    public struct TestModel: Equatable {
        public let heading: String
        public let subheading: String
        public let details: String
        public init(_ heading: String, _ subheading: String, _ details: String) {
            self.heading = heading
            self.subheading = subheading
            self.details = details
        }
    }

    let tests: [TestModel] = {
        var r: [TestModel] = []
        for i in 0..<4 {
            let x = i + 1
            r.append(
                .init(
                    "Appointment #\(x)",
                    "Here we do \(x * 2) things",
                    "Address for number \(x)",
                )
            )
        }
        return r
    }()

    var testComp: HTMLFragment {
        var comps: [any HTMLNode] = []
        for i in tests {
            comps.append(contentsOf: [
                HTML.div(.class(["fictitious-class"])) {
                    HTML.text(i.heading); HTML.br()
                    HTML.text(i.subheading); HTML.br()
                    HTML.text(i.details)
                },
                HTML.br()
            ])
        }
        return comps
    }

    // prepping for templater/v1 usage
    @Test("basicDocumentRendersAndEscapes")
    func basicDocumentRendersAndEscapes() throws {
        let doc = HTMLDocument.basic(
            lang: "nl",
            title: "Bevestiging",
            stylesheets: ["/assets/mail.css"],
            inlineStyle: "body{font-family:-apple-system,Segoe UI,Arial,sans-serif}"
        ) {
            HTML.div(.class(["container"])) {
                HTML.img(src: "/img/logo.png", alt: "Hondenmeesters", .class(["logo"]))
                HTML.hr()
                HTML.p {
                    HTML.text("Beste ")
                    HTML.text("{{name}}")        // safe text
                    HTML.raw("<br>")             // deliberate raw to test mixing
                }
                HTML.ul {
                    for i in 1...3 {
                        HTML.li { HTML.text("punt \(i)") }
                    }
                }
                HTML.p(.aria("live", "polite")) {
                    HTML.a("https://hondenmeesters.nl/support") { HTML.text("Geef jouw feedback") }
                }
                HTML.br() // void
                HTML.table(.class(["table","table-compact"])) {
                    HTML.thead {
                        HTML.tr {
                            HTML.th { HTML.text("Kolom A") }
                            HTML.th { HTML.text("Kolom B") }
                        }
                    }
                    HTML.tbody {
                        HTML.tr {
                            HTML.td { HTML.text("<escaped> & \"quotes\"") } // ensure escaping
                            HTML.td { HTML.text("✓ boolean attrs next") }
                        }
                    }
                }
                // Boolean attribute example: disabled button (presence implies true)
                HTML.el("button", HTMLAttribute.bool("disabled", true)) { HTML.text("Versturen") }

                HMFooter
                testComp
            }
        }

        // compact vs pretty render
        let prettyHTML  = doc.render(pretty: true,  indentStep: 4)
        let compactHTML = doc.render(pretty: false, indentStep: 0)

        // head/doc bits
        #expect(prettyHTML.contains(#"<html lang="nl">"#))
        #expect(prettyHTML.contains("body{font-family:-apple-system"))

        #expect(compactHTML.contains("<title>Bevestiging</title>"))
        #expect(compactHTML.contains(#"<link href="/assets/mail.css" rel="stylesheet">"#))

        // void elements
        #expect(prettyHTML.contains("<br>"))
        #expect(prettyHTML.contains("<hr>"))
        #expect(prettyHTML.contains(#"<img class="logo" src="/img/logo.png" alt="Hondenmeesters">"#))

        // escaping
        #expect(prettyHTML.contains("&lt;escaped&gt; &amp; &quot;quotes&quot;"))

        // boolean attribute
        #expect(compactHTML.contains("<button disabled>Versturen</button>"))

        // footer
        #expect(prettyHTML.contains("Hondenmeesters | Ondersteuning bij hondengedrag"))
        #expect(prettyHTML.contains("Marterkoog 7B"))
        #expect(prettyHTML.contains("1822BK Alkmaar"))
        #expect(prettyHTML.contains("Telefoon: +31 6 23 62 13 90")) 

        for x in 1...4 {
            #expect(prettyHTML.contains("Appointment #\(x)"))
            #expect(prettyHTML.contains("Here we do \(x * 2) things"))
            #expect(prettyHTML.contains("Address for number \(x)"))
        }
    }

    @Test
    func bodyOnlyConvenience() {
        let bodyOnly = HTML.body {
            HTML.p { HTML.text("Body only mode") }
        }
        let bodyDoc = HTMLDocument(children: [bodyOnly]).render(pretty: false)
        #expect(bodyDoc.contains("<p>Body only mode</p>"))
        #expect(bodyDoc.contains("<body>"))
    }
}
