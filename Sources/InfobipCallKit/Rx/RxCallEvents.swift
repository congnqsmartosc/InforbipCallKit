#if canImport(RxSwift)
import RxSwift

public extension InfobipCallClient {

    /// RxSwift view of the discrete call-event stream (see ``InfobipCallEvent``) — the event
    /// companion to `rx_activeSession`. Emits each new event after subscription (it does not
    /// replay a current value). Available only when depending on the `InfobipCallKit/Rx` subspec.
    var rx_callEvents: Observable<InfobipCallEvent> {
        Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            let token = self.observeEvents { observer.onNext($0) }
            return Disposables.create { token.cancel() }
        }
    }
}
#endif
