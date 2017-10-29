import Foundation

class TestServerListResponseProcessor: ResponseProcessor {
    override func process() {
        
        super.process()
        
        guard let _ = responseArray() else {
            return
        }
        
        WSettingsManager.setValidValuesForTestHeader(WSettingTestServerHeaderName, values: responseArray())
    }
}