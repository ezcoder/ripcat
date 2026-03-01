//
//  StationFinder.swift
//  tidegen
//
//  Created by Ben on 2/24/26.
//

import Foundation

public struct StationFinder {
    public static func findNearest(
        latitude: Double,
        longitude: Double,
        stations: [NOAAStation]
    ) -> (station: NOAAStation, distanceMiles: Double)? {
        var bestStation: NOAAStation?
        var bestDistance = Double.greatestFiniteMagnitude

        for station in stations {
            let distance = haversineDistance(
                lat1: latitude, lon1: longitude,
                lat2: station.lat, lon2: station.lng
            )
            if distance < bestDistance {
                bestDistance = distance
                bestStation = station
            }
        }

        guard let station = bestStation else { return nil }
        return (station, bestDistance)
    }

    public static func haversineDistance(
        lat1: Double, lon1: Double,
        lat2: Double, lon2: Double
    ) -> Double {
        let R = 3958.8 // Earth radius in miles
        let dLat = (lat2 - lat1) * .pi / 180.0
        let dLon = (lon2 - lon1) * .pi / 180.0
        let a = sin(dLat / 2) * sin(dLat / 2)
            + cos(lat1 * .pi / 180.0) * cos(lat2 * .pi / 180.0)
            * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }
}
