import Foundation
import MapKit

/// URLParser used for parsing and manipulating URLs
class URLParser {
    
    /// Constructs the google maps nextbike route URL and redirects the user to the Google Maps app
    public static func redirectToGoogleMaps(origin: CLLocationCoordinate2D, waypoint1: CLLocationCoordinate2D, waypoint2: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let urlString = """
            https://www.google.com/maps/dir/?api=1\
            &origin=\(coordToString(origin))\
            &destination=\(coordToString(destination))\
            &waypoints=\(coordToString(waypoint1))|\(coordToString(waypoint2))\
            &travelmode=bicycling
            """
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    /// Returns the lon/lat coordinates from a shared google destination url
    public static func getLonLatCoordinatesFromShareExtensionUrl(_ shareExtensionUrl: URL) async -> CLLocationCoordinate2D? {
        guard let sharedUrl = extractShortUrl(url: shareExtensionUrl) else {
            print("Couldn't get shared url")
            return nil }
        guard let longUrl = await getLongUrl(shortUrl: sharedUrl) else {
            print("Couldn't get long url")
            return nil }
        guard let address = extractQueryParameter(from: longUrl) else {
            print("Couldn't get address")
            return nil }
        
        // Address is a placed pin, meaning it contains the lon lat coordinates
        if qParameterIsCoords(address) {
            return stringToCoord(address)
        }
        else if let coords = await CoordsHelper.getCoordsFromAddress(address) {
            return coords
        }
        
        return nil
    }
    
    /// Returns the shared short google url from the share extension
    private static func extractShortUrl(url: URL) -> URL? {
        let urlStr = url.absoluteString
        guard let startIndexUrl = urlStr.range(of: "sharedURL=") else { return nil }
        var urlSubstring = urlStr[startIndexUrl.upperBound...]
        
        // Remove trailing query params (like ?g_st=...) from the shared URL
        if let questionMarkRange = urlSubstring.firstIndex(of: "?") {
            urlSubstring = urlSubstring[..<questionMarkRange]
        }
        let decodedUrl = urlSubstring.removingPercentEncoding ?? String(urlSubstring)
        return URL(string: decodedUrl)
    }
    
    /// Expands the short google url to the long full one
    private static func getLongUrl(shortUrl: URL) async -> URL? {
        var request = URLRequest(url: shortUrl)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let url = response.url else { return nil }
            if url.host?.contains("consent.google.com") == true {
                return extractContinueUrl(from: url)
            }
            return url
        } catch {
            return nil
        }
    }
    
    /// Removes the consent info from a google url
    private static func extractContinueUrl(from url: URL) -> URL? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let continueParam = components.queryItems?.first(where: { $0.name == "continue" })?.value,
              let decoded = continueParam.removingPercentEncoding,
              let decodedUrl = URL(string: decoded) else {
            return nil
        }
        return decodedUrl
    }
    
    /// Gets the "q" parameter from the google url (contains the address)
    private static func extractQueryParameter(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return nil }
        return queryItems.first(where: { $0.name == "q" })?.value
    }
    
    /// Checks if the "q" parameter already is the lon/lat coordinates, happens if user shares using a placed pin
    private static func qParameterIsCoords(_ qParameter: String) -> Bool {
        let latLonRegex = try! NSRegularExpression(pattern: #"^-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?$"#)
        let range = NSRange(qParameter.startIndex..<qParameter.endIndex, in: qParameter)
        return latLonRegex.firstMatch(in: qParameter, range: range) != nil
    }
    
    /// Converts a String to a CLLocationCoordinate2D
    private static func stringToCoord(_ string: String) -> CLLocationCoordinate2D? {
        let parts = string.split(separator: ",")
        guard parts.count == 2 else { return nil }
        guard
              let lat = Double(parts[0].trimmingCharacters(in: .whitespaces)),
              let lon = Double(parts[1].trimmingCharacters(in: .whitespaces))
        else { return nil }
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    /// Converts a CLLocationCoordinate2D to a String
    private static func coordToString(_ coord: CLLocationCoordinate2D) -> String {
        return "\(coord.latitude),\(coord.longitude)"
    }
    
}
