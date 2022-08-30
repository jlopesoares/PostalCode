//
//  PostalCode.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import Foundation

class LocalPostalCode: Codable {
    
    var local: String = ""
    var codPostal: String
    var extCodPostal: String = ""

    enum CodingKeys: String, CodingKey {
        case local = "nome_localidade"
        case codPostal = "num_cod_postal"
        case extCodPostal = "ext_cod_postal"
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        local = try values.decode(String.self, forKey: .local)
        codPostal = try values.decode(String.self, forKey: .codPostal)
        extCodPostal = try values.decode(String.self, forKey: .extCodPostal)
    }
}
