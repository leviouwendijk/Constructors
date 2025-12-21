import Foundation
import HTML

public final class GateTallySink: @unchecked Sendable {
    private var _rendered: [GateEvent] = []
    private var _skipped:  [GateEvent] = []
    private let lock = NSLock()

    func record(_ e: GateEvent) {
        lock.lock()
        if e.rendered { _rendered.append(e) } else { _skipped.append(e) }
        lock.unlock()
    }

    func snapshot() -> GateTally {
        lock.lock()
        let snap = GateTally(rendered: _rendered, skipped: _skipped)
        lock.unlock()
        return snap
    }
}
