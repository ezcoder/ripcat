//
//  NOAAClient.swift
//  tidegen
//
//  Created by Ben on 2/24/26.
//

import Foundation

public enum NOAAClientError: LocalizedError {
    case invalidURL(String)
    case networkError(Error)
    case decodingError(Error)
    case noData
    case apiError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url): return "Invalid URL: \(url)"
        case .networkError(let err): return "Network error: \(err.localizedDescription)"
        case .decodingError(let err): return "Failed to decode NOAA response: \(err.localizedDescription)"
        case .noData: return "No data returned from NOAA API"
        case .apiError(let msg): return "NOAA API error: \(msg)"
        }
    }
}

public struct NOAAClient {
    private static let baseURL = "https://api.tidesandcurrents.noaa.gov"
    private static let dataGetterPath = "/api/prod/datagetter"
    private static let stationsPath = "/mdapi/prod/webapi/stations.json"

    public static func fetchStations() async throws -> [NOAAStation] {
        let urlString = "\(baseURL)\(stationsPath)?type=tidepredictions"
        let data = try await fetch(urlString: urlString)
        do {
            let response = try JSONDecoder().decode(NOAAStationListResponse.self, from: data)
            return response.stations
        } catch {
            throw NOAAClientError.decodingError(error)
        }
    }

    public static func fetchPredictions(stationID: String, date: String) async throws -> [NOAAPrediction] {
        let urlString = "\(baseURL)\(dataGetterPath)"
            + "?product=predictions"
            + "&station=\(stationID)"
            + "&begin_date=\(date)"
            + "&end_date=\(date)"
            + "&datum=MLLW"
            + "&units=english"
            + "&time_zone=lst_ldt"
            + "&format=json"
        let data = try await fetch(urlString: urlString)
        do {
            let response = try JSONDecoder().decode(NOAAPredictionResponse.self, from: data)
            if let error = response.error {
                throw NOAAClientError.apiError(error.message)
            }
            guard let predictions = response.predictions, !predictions.isEmpty else {
                throw NOAAClientError.noData
            }
            return predictions
        } catch let error as NOAAClientError {
            throw error
        } catch {
            throw NOAAClientError.decodingError(error)
        }
    }

    public static func fetchHiLo(stationID: String, date: String) async throws -> [NOAAHiLoPrediction] {
        let urlString = "\(baseURL)\(dataGetterPath)"
            + "?product=predictions"
            + "&station=\(stationID)"
            + "&begin_date=\(date)"
            + "&end_date=\(date)"
            + "&datum=MLLW"
            + "&units=english"
            + "&time_zone=lst_ldt"
            + "&format=json"
            + "&interval=hilo"
        let data = try await fetch(urlString: urlString)
        do {
            let response = try JSONDecoder().decode(NOAAHiLoResponse.self, from: data)
            if let error = response.error {
                throw NOAAClientError.apiError(error.message)
            }
            guard let predictions = response.predictions, !predictions.isEmpty else {
                throw NOAAClientError.noData
            }
            return predictions
        } catch let error as NOAAClientError {
            throw error
        } catch {
            throw NOAAClientError.decodingError(error)
        }
    }

    private static func fetch(urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NOAAClientError.invalidURL(urlString)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw NOAAClientError.networkError(error)
        }
    }
}
