//
//  GeocoderService.swift
//  tidegen
//
//  Created by Ben on 2/24/26.
//

import CoreLocation
import Foundation

public struct GeocoderService {
    public enum GeocoderError: LocalizedError {
        case noResults(String)
        case geocodingFailed(Error)

        public var errorDescription: String? {
            switch self {
            case .noResults(let city):
                return "Could not find coordinates for '\(city)'"
            case .geocodingFailed(let err):
                return "Geocoding failed: \(err.localizedDescription)"
            }
        }
    }

    public static func geocode(city: String) async throws -> (latitude: Double, longitude: Double) {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(city)
            guard let location = placemarks.first?.location else {
                throw GeocoderError.noResults(city)
            }
            return (location.coordinate.latitude, location.coordinate.longitude)
        } catch let error as GeocoderError {
            throw error
        } catch {
            throw GeocoderError.geocodingFailed(error)
        }
    }
}
