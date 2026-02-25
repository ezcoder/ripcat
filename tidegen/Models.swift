//
//  Models.swift
//  tidegen
//
//  Created by Ben on 2/24/26.
//

import Foundation

// MARK: - NOAA Station List Response

struct NOAAStationListResponse: Codable {
    let count: Int?
    let stations: [NOAAStation]
}

struct NOAAStation: Codable {
    let id: String
    let name: String
    let lat: Double
    let lng: Double
    let state: String?
}

// MARK: - NOAA Predictions Response

struct NOAAPredictionResponse: Codable {
    let predictions: [NOAAPrediction]?
    let error: NOAAErrorDetail?
}

struct NOAAPrediction: Codable {
    let t: String   // "2026-02-24 00:00"
    let v: String   // "3.887"
}

// MARK: - NOAA Hi/Lo Response

struct NOAAHiLoResponse: Codable {
    let predictions: [NOAAHiLoPrediction]?
    let error: NOAAErrorDetail?
}

struct NOAAHiLoPrediction: Codable {
    let t: String   // "2026-02-24 03:56"
    let v: String   // "6.019"
    let type: String // "H" or "L"
}

// MARK: - NOAA Error

struct NOAAErrorDetail: Codable {
    let message: String
}

// MARK: - Internal App Models

struct TideDataPoint {
    let time: Date
    let height: Double
}

struct HiLoPoint {
    let time: Date
    let height: Double
    let type: HiLoType
}

enum HiLoType: String {
    case high = "H"
    case low = "L"
}

struct TideData {
    let stationID: String
    let stationName: String
    let date: String
    let predictions: [TideDataPoint]
    let hiloPoints: [HiLoPoint]
}

// MARK: - JSON Output Models

struct TideDataJSON: Codable {
    let station: StationInfoJSON
    let date: String
    let predictions: [PredictionJSON]
    let highLow: [HiLoJSON]

    struct StationInfoJSON: Codable {
        let id: String
        let name: String
    }

    struct PredictionJSON: Codable {
        let time: String
        let height: Double
    }

    struct HiLoJSON: Codable {
        let time: String
        let height: Double
        let type: String
    }
}
