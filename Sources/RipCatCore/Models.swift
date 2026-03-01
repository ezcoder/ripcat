//
//  Models.swift
//  RipCatCore
//

import Foundation

// MARK: - NOAA Station List Response

public struct NOAAStationListResponse: Codable {
    public let count: Int?
    public let stations: [NOAAStation]
}

public struct NOAAStation: Codable {
    public let id: String
    public let name: String
    public let lat: Double
    public let lng: Double
    public let state: String?
}

// MARK: - NOAA Predictions Response

public struct NOAAPredictionResponse: Codable {
    public let predictions: [NOAAPrediction]?
    public let error: NOAAErrorDetail?
}

public struct NOAAPrediction: Codable {
    public let t: String
    public let v: String
}

// MARK: - NOAA Hi/Lo Response

public struct NOAAHiLoResponse: Codable {
    public let predictions: [NOAAHiLoPrediction]?
    public let error: NOAAErrorDetail?
}

public struct NOAAHiLoPrediction: Codable {
    public let t: String
    public let v: String
    public let type: String
}

// MARK: - NOAA Error

public struct NOAAErrorDetail: Codable {
    public let message: String
}

// MARK: - Internal App Models

public struct TideDataPoint {
    public let time: Date
    public let height: Double

    public init(time: Date, height: Double) {
        self.time = time
        self.height = height
    }
}

public struct HiLoPoint {
    public let time: Date
    public let height: Double
    public let type: HiLoType

    public init(time: Date, height: Double, type: HiLoType) {
        self.time = time
        self.height = height
        self.type = type
    }
}

public enum HiLoType: String {
    case high = "H"
    case low = "L"
}

public struct TideData {
    public let stationID: String
    public let stationName: String
    public let date: String
    public let predictions: [TideDataPoint]
    public let hiloPoints: [HiLoPoint]

    public init(stationID: String, stationName: String, date: String, predictions: [TideDataPoint], hiloPoints: [HiLoPoint]) {
        self.stationID = stationID
        self.stationName = stationName
        self.date = date
        self.predictions = predictions
        self.hiloPoints = hiloPoints
    }
}

// MARK: - Output Format

public enum OutputFormat: String, CaseIterable {
    case json
    case text
}

// MARK: - JSON Output Models

public struct TideDataJSON: Codable {
    public let station: StationInfoJSON
    public let date: String
    public let predictions: [PredictionJSON]
    public let highLow: [HiLoJSON]

    public struct StationInfoJSON: Codable {
        public let id: String
        public let name: String
    }

    public struct PredictionJSON: Codable {
        public let time: String
        public let height: Double
    }

    public struct HiLoJSON: Codable {
        public let time: String
        public let height: Double
        public let type: String
    }
}
