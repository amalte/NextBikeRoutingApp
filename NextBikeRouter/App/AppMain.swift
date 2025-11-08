import Foundation
import CoreLocation

/// App entry point called when a Google Maps url is shared to the app.
/// Calculates which NextBike stations to take and then redirects the user back to Google Maps.
public func appMain(_ url: URL) async {
    
    guard let destinationPos = await URLParser.getLonLatCoordinatesFromShareExtensionUrl(url) else {
        print("Failed to get destination position coordinates.")
        return
    }
    
    let locationManager = LocationManager()
    guard let startPos = await locationManager.requestLocation() else {
        print("Unable to obtain current location.")
        return
    }
    let stations: [StationInformation]
    do {
        stations = try await GBFSClient().fetchStationInformation()
    } catch {
        print("Error: \(error.localizedDescription)")
        return
    }
    
    guard let firstStation = CoordsHelper.findClosestStation(startPos, stations) else { return }
    guard let secondStation = CoordsHelper.findClosestStation(destinationPos, stations) else { return }
    let firstStationPos = CLLocationCoordinate2D(latitude: firstStation.lat, longitude: firstStation.lon)
    let secondStationPos = CLLocationCoordinate2D(latitude: secondStation.lat, longitude: secondStation.lon)
    
    URLParser.redirectToGoogleMaps(origin: startPos, waypoint1: firstStationPos, waypoint2: secondStationPos, destination: destinationPos)
}

