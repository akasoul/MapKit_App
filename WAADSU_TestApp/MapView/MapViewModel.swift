//
//  MapViewModel.swift
//  WAADSU_TestApp
//
//  Created by Anton Voloshuk on 08.07.2021.
//

import Foundation
import MapKit
import Combine

class MapViewModel: ObservableObject,RouteReceiver{
    func didReceiveRoute(route: MKRoute) {
        self.routes=[]
        self.routes.append(route)
    }
    
    
    @Published var mapRect: MKMapRect
    @Published var region: MKCoordinateRegion
    @Published var overlays: [MKPolygon]=[]
    @Published var geo: Geo?
    @Published var routes: [MKRoute]=[]
    let urlString="https://waadsu.com/api/russia.geo.json"
    init() {
        self.mapRect=MKMapRect(x: 10, y: 10, width: 200, height: 100)
        self.region=MKCoordinateRegion(center: .init(latitude: 20, longitude: 20), latitudinalMeters: 3000000, longitudinalMeters: 3000000)
    }
    
    
    
    func calculateOverlay(points: [[Double]])->MKPolygon{
        var coordinates: [CLLocationCoordinate2D]=[]
        for i in points{
            coordinates.append(CLLocationCoordinate2D(latitude: i[1], longitude: i[0]))
        }
        let overlay: MKPolygon=MKPolygon(coordinates: &coordinates, count: coordinates.count)
        return overlay
    }
    
    func calculateRoute(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D){
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .any
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { response, error in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            self.routes.append(response.routes[0])
        }
        
    }
    
    func loadGeoJSON(){
        guard let url = URL(string: self.urlString)
        else{
            return
        }
        let task = URLSession.shared.dataTask(with: url){data,response,error in
            guard let data = data
            else{
                return
            }
            var geoJson=[MKGeoJSONObject]()
            do{
                try geoJson = MKGeoJSONDecoder().decode(data)
            }
            catch{
                print(error)
                return
            }
            for i in geoJson{
                if let feature = i as? MKGeoJSONFeature{
                    for geo in feature.geometry{
                        if let polygon = geo as? MKPolygon{
                            self.overlays.append(polygon)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func loadGeoJSONFromBundle(){
        if let bundleURL = Bundle.main.url(forResource: "russia", withExtension: "geojson"){
            guard let data = try? Data(contentsOf: bundleURL)
            else{
                return
            }
            var geoJson = [MKGeoJSONObject]()
            do{
                geoJson = try MKGeoJSONDecoder().decode(data)
            }
            catch{
                print(error)
            }
            for i in geoJson{
                if let feature = i as? MKGeoJSONFeature{
                    for geo in feature.geometry{
                        if let polygon = geo as? MKPolygon{
                            self.overlays.append(polygon)
                        }
                    }
                }
            }
        }
    }
    
    func loadGeo(){
        
        guard let url = URL(string: self.urlString)
        else{
            return
        }
        
        let task = URLSession.shared.dataTask(with: url){data,response,error in
            guard let data = data
            else{
                return
            }
            var geo: Geo?
            do{
                try  geo = JSONDecoder().decode(Geo.self, from: data)
            }
            catch{
                print(error)
                return
            }
            var overlays=[MKPolygon]()
            for j in 0..<geo!.features[0].geometry.coordinates.count{
                let coordinates=geo!.features[0].geometry.coordinates[j][0]
                overlays.append(self.calculateOverlay(points: coordinates))
            }
            DispatchQueue.main.async{
                self.overlays=overlays
            }
            
        }
        task.resume()
        
    }
    
    func loadGeoAndRemovePolygons(){
        
        guard let url = URL(string: self.urlString)
        else{
            return
        }
        
        let task = URLSession.shared.dataTask(with: url){data,response,error in
            guard let data = data
            else{
                return
            }
            var geo: Geo?
            do{
                try  geo = JSONDecoder().decode(Geo.self, from: data)
            }
            catch{
                print(error)
                return
            }
            var overlays=[MKPolygon]()
            for j in 0..<geo!.features[0].geometry.coordinates.count{
                if j != 91 && j != 159{
                    let coordinates=geo!.features[0].geometry.coordinates[j][0]
                    overlays.append(self.calculateOverlay(points: coordinates))
                    
                }
            }
            DispatchQueue.main.async{
                self.overlays=overlays
            }
            
        }
        task.resume()
        
    }
    
}

