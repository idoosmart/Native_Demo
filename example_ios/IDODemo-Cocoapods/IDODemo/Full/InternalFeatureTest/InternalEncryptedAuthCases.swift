//
//  InternalEncryptedAuthCases.swift
//  IDODemo (native Full temp — temp sync to native Full)
//
//  加密鉴权：连接前 setEncryptedAuthData + 标记本地已绑定（联调用例）。
//

import Foundation
import protocol_channel

enum InternalEncryptedAuthCases {

    /// C 库 JSON（主键 auth_data）；联调时可替换。
    static let sampleJson = """
    {"auth_data":[80,61,187,119,250,50,234,10,21,16,32,9],"encrypted_version":0,"auth_length":12}
    """

    static func parseSampleJson(_ json: String = sampleJson) -> IDOEncryptedAuthData? {
        return IDOEncryptedAuthData(jsonString: json)
    }
}
