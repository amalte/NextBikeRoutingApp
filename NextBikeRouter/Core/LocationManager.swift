import CoreLocation

/// Manages location services and provides the user's current position.
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?
    private var authContinuation: CheckedContinuation<Bool, Never>?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() async -> CLLocationCoordinate2D? {
        if locationManager.authorizationStatus == .notDetermined {
            let granted = await requestAuthorization()
            if !granted { return nil }
        } else {
            guard locationManager.authorizationStatus == .authorizedWhenInUse ||
                    locationManager.authorizationStatus == .authorizedAlways else {
                return nil
            }
        }

        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            locationManager.requestLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if let continuation = authContinuation {
            let status = manager.authorizationStatus
            let granted = (status == .authorizedAlways || status == .authorizedWhenInUse)
            continuation.resume(returning: granted)
            authContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentPosition = locations.first?.coordinate
        continuation?.resume(returning: currentPosition)
        continuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(returning: nil)
        continuation = nil
    }
    
    private func requestAuthorization() async -> Bool {
        return await withCheckedContinuation { continuation in
            self.authContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
