import Foundation
import Combine



struct Worker: Codable, Identifiable {
    let userID: Int
    let userName: String
    var locationName: String?
    var id: Int { userID }
}

enum SortOption: String, CaseIterable, Identifiable {
    case name     = "Name"
    case location = "Standort"
    var id: Self { self }
}

// J json decoder
func decodeMitarbeiter() -> [Worker] {
    let url  = Bundle.main.url(forResource: "Mitarbeiter", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    return try! JSONDecoder().decode([Worker].self, from: data)
}



final class WorkersListViewModel: ObservableObject {

    @Published var sortOption: SortOption = .name
    @Published var searchText: String = ""
    
    @Published private(set) var allWorkers: [Worker] = []
    
    // sfilter plius sortier funktion
    var filteredWorkers: [Worker] {
        let filtered = allWorkers.filter {
            searchText.isEmpty
            || $0.userName.localizedCaseInsensitiveContains(searchText)
        }
        switch sortOption {
        case .name:
            return filtered.sorted { $0.userName < $1.userName }
        case .location:
            return filtered.sorted {
                switch ($0.locationName, $1.locationName) {
                case let (a?, b?):    return a < b
                case (_?, nil):       return true
                case (nil, _?):       return false
                case (nil, nil):      return $0.userName < $1.userName
                }
            }
        }
    }
    
    init() {
        loadWorkers()
    }
    
    private func loadWorkers() {
        allWorkers = decodeMitarbeiter()
    }
}
