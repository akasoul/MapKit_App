//
//  AddRouteViewModel.swift
//  WAADSU_TestApp
//
//  Created by Anton Voloshuk on 10.07.2021.
//

import Foundation
import SwiftUI
import Combine
import MapKit

protocol RouteReceiver: class{
    func didReceiveRoute(route: MKRoute)
}

class AddRouteViewModel: ObservableObject{
    enum Location {
        case src
        case dst
    }
    weak var receiver: RouteReceiver?
    var locationOnEdit: Location?
    @Published var src: String=""{
        didSet{
            self.locationOnEdit = .src
            self.searchLocation(text: self.src)
        }
    }
    @Published var dst: String=""{
        didSet{
            self.locationOnEdit = .dst
            self.searchLocation(text: self.dst)
        }
    }
    @Published var matchingItems=[MKMapItem]()
    
    @Published var route: MKRoute?
    var srcMapItem: MKMapItem?{
        didSet{
            guard let tmp = self.srcMapItem
            else{
                return
            }
            guard let name = tmp.name
            else{
                return
            }
            self.src=name
        }
    }
    var dstMapItem: MKMapItem?{
        didSet{
            guard let tmp = self.dstMapItem
            else{
                return
            }
            guard let name = tmp.name
            else{
                return
            }
            self.dst=name
        }
    }
    
    func searchLocation(text: String){
        let request  = MKLocalSearch.Request()
        request.naturalLanguageQuery=text
        let search=MKLocalSearch(request: request)
        search.start(completionHandler: { response,error in
            guard let items = response?.mapItems
            else{ return }
            self.matchingItems=[]
            for i in items{
                self.matchingItems.append(i)
            }
        })
    }
    
    func setLocation(location: MKMapItem){
        for i in self.matchingItems{
            if(location == i){
                guard let current = self.locationOnEdit
                else{
                    return
                }
                if(current == .src){
                    self.srcMapItem = i
                }
                if(current == .dst){
                    self.dstMapItem = i
                }
            }
        }
    }
    
    func fieldsAreEmpty()->Bool{
        if(self.src == "" || self.dst == ""){
            return true
        }
        return false
    }
    
    func fieldsCompareLocations()->Bool{
        guard let srcName = self.srcMapItem?.name
        else{
            return false
        }
        guard let dstName = self.dstMapItem?.name
        else{
            return false
        }
        if(srcName == "" || dstName == ""){
            return false
        }
        if(self.src == srcName && self.dst == dstName){
            return true
        }
        return false
    }
    
    func calculateRoute(){
        
        
        guard let sourceMapItem = self.srcMapItem
        else{
            return
        }
        guard let destinationMapItem = self.dstMapItem
        else{
            return
        }
        
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
            
            self.route = response.routes.first
        }
        
    }
    
    func sendRoute(){
        guard let route = self.route
        else{
            return
        }
        self.receiver?.didReceiveRoute(route: route)
    }
}
