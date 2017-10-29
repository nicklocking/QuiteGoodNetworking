import Foundation

@objc enum SearchQueryType: Int {
    case tribe
    case place
    case placeAutoComplete
    case whisper
    
    func name() -> String {
        switch(self) {
        case .tribe: return "tribe"
        case .place: return "place"
        case .placeAutoComplete: return "feeds"
        case .whisper: return "whisper"
        }
    }
}
