//
//  PostalCodesService.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import Foundation
import CodableCSV

final class PostalCodesService {
    
    var csvDecoder: CSVDecoder!
    
    init() {
        
        var decoderConfigurations = CSVDecoder.Configuration()
        decoderConfigurations.headerStrategy = .firstLine
        decoderConfigurations.nilStrategy = .empty
        decoderConfigurations.trimStrategy = .whitespaces
        decoderConfigurations.encoding = .utf8
        
        csvDecoder = CSVDecoder(configuration: decoderConfigurations)
    }
    
    func downloadPostalCodes() async -> Result<[PostalCode], Error> {

        guard let postalCodesURL = URL(string: "https://raw.githubusercontent.com/centraldedados/codigos_postais/master/data/codigos_postais.csv") else {
            return .failure(PostalCodeErrors.invalidUrl)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: postalCodesURL)
            let postalCodes = try csvDecoder.decode([PostalCode].self, from: data)
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                return .failure(PostalCodeErrors.failedToDownloadPostalCodes)
            }
            
            return .success(postalCodes)
            
        } catch let error {
            print(error)
            return .failure(error)
        }
    }
}

enum PostalCodeErrors: Error {
    case invalidUrl,
    failedToDownloadPostalCodes
}
