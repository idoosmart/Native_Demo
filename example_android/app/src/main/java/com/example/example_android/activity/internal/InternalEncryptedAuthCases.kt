package com.example.example_android.activity.internal

import com.idosmart.model.IDOEncryptedAuthData

/**
 * 加密鉴权：连接前 setEncryptedAuthData + 标记本地已绑定（联调用例）。
 * 临时从 channel example 同步到 native Full（联调）。
 */
object InternalEncryptedAuthCases {

    /** C 库 JSON（主键 auth_data）；联调时可替换。 */
    const val SAMPLE_JSON =
        """{"auth_data":[80,61,187,119,250,50,234,10,21,16,48,42],"encrypted_version":0,"auth_length":12}"""

    fun parseSampleJson(json: String = SAMPLE_JSON): IDOEncryptedAuthData? {
        return IDOEncryptedAuthData.fromJsonString(json)
    }
}
