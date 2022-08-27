//
//  PostalCode.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import Foundation
import RealmSwift

class PostalCode: Object, Codable {
    
    @Persisted var local: String = ""
    @Persisted var codPostal: String
    @Persisted var extCodPostal: String = ""

    enum CodingKeys: String, CodingKey {
        case local = "nome_localidade"
        case codPostal = "num_cod_postal"
        case extCodPostal = "ext_cod_postal"

    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        local = try values.decode(String.self, forKey: .local)
        codPostal = try values.decode(String.self, forKey: .codPostal)
        extCodPostal = try values.decode(String.self, forKey: .extCodPostal)
    }
}
