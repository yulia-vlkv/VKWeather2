//
//  LocationSelectorViewModel.swift
//  VKWeather
//
//  Created by Iuliia Volkova on 23.03.2024.
//

import Foundation
import CoreLocation


protocol LocationSelectorViewOutput: AnyObject {
    
    var onSuccess: ((Location) -> Void)? { get set }
    var onClose: (() -> Void)? { get set }
}


class LocationSelectorViewModel: LocationSelectorViewOutput {
    
    public var onSuccess: ((Location) -> Void)?
    public var onClose: (() -> Void)?
    private let locationService = LocationService.shared
    private let key: String = "selectedLocation"
    
    public func cancel() {
        self.onClose?()
    }
    
    public func findLocation(for text: String) {
        locationService.getLocationFromString(from: text, completion: { location in
            guard let location = location else { return }
            
            self.locationService.getLocationFromCoordinates(for: CLLocation(latitude: location.latitude, longitude: location.longitude), completion: { placemark in
                
                guard let placemark = placemark else { return }
                
                let placeForWeather = Location(
                    city: placemark.locality ?? "Неизвестно",
                    country: placemark.country ?? "Неизвестно",
                    longitude: String(location.longitude),
                    latitude: String(location.latitude)
                )
                self.onSuccess?(placeForWeather)
                self.saveSelectedLocation(location: placeForWeather)
            })
        })
    }
    
    private func saveSelectedLocation(location: Location) {
        do {
            let data = try JSONEncoder().encode(location)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Unable to encode weather (\(error))")
        }
    }
}
