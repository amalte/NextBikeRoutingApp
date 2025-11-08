import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Static information about a NextBike station, defined by the GBFS specification.
/// Includes the station's ID, name, and geographic coordinates.
public struct StationInformation: Decodable, Sendable {
    public let station_id: String, name: String
    public let lat: Double, lon: Double
}

/// Dynamic status information for a NextBike station.
/// Reflects current bike availability and operational status for a specific station ID.
public struct StationStatus: Decodable, Sendable {
    public let station_id: String
    public let num_bikes_available: Int
    public let is_renting: Bool?
    public let is_returning: Bool?
}

/// A client for fetching GBFS station data (General Bikeshare Feed Specification)
// TODO: Make this more robust, allowing for users to select city in the app, after that we can select the correct GBFS url.
public struct GBFSClient: Sendable {
    // Base URL for the Gothenburg NextBike GBFS feed
    public let session: URLSession
    private let stationInfoURL = URL(string: "https://gbfs.nextbike.net/maps/gbfs/v2/nextbike_zg/en/station_information.json")!
    private let stationStatusURL = URL(string: "https://gbfs.nextbike.net/maps/gbfs/v2/nextbike_zg/en/station_status.json")!
    private struct Root<U: Decodable>: Decodable { let data: DataWrap; struct DataWrap: Decodable { let stations: [U] } }


    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetchStationInformation() async throws -> [StationInformation] {
        try await fetchStations(from: stationInfoURL, as: StationInformation.self)
    }
    
    public func fetchStationStatus() async throws -> [StationStatus] {
        try await fetchStations(from: stationStatusURL, as: StationStatus.self)
    }
    
    private func fetchStations<T: Decodable>(from url: URL, as type: T.Type) async throws -> [T] {
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(Root<T>.self, from: data).data.stations
    }
}
