#if canImport(RxSwift)
import RxSwift

public extension InfobipCallClient {

    /// RxSwift view of ``activeSession`` — the closest analogue to Android's
    /// `StateFlow<CallSession?>`. Emits the current value on subscription and every change after.
    /// Available only when depending on the `InfobipCallKit/Rx` subspec.
    var rx_activeSession: Observable<CallSession?> {
        Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            let token = self.observeSession { observer.onNext($0) }
            return Disposables.create { token.cancel() }
        }
    }
}
#endif
