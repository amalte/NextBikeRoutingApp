import MapKit

/// Helper for positions and coordinates.
class CoordsHelper {
    /// Returns the closest position from a starting position and list of positions to check
    static func findClosestStation(_ startPos: CLLocationCoordinate2D, _ stations: [StationInformation]) -> StationInformation? {
        let startLocation = CLLocation(latitude: startPos.latitude, longitude: startPos.longitude)
        
        return stations.min {
            let d1 = startLocation.distance(from: CLLocation(latitude: $0.lat, longitude: $0.lon))
            let d2 = startLocation.distance(from: CLLocation(latitude: $1.lat, longitude: $1.lon))
            return d1 < d2
        }
    }
    
    /// Converts the inputted string address into lon/lat coordinates
    static func getCoordsFromAddress(_ address: String) async -> CLLocationCoordinate2D? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            if let loc = response.mapItems.first {
                return loc.placemark.coordinate
            }
            return nil
        } catch {
            print("Geocoding error:", error.localizedDescription)
            return nil
        }
    }
    
}
