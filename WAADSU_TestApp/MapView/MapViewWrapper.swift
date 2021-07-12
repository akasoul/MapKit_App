//
//  MapViewWrapper.swift
//  WAADSU_TestApp
//
//  Created by Anton Voloshuk on 08.07.2021.
//

import Foundation
import UIKit
import SwiftUI
import MapKit

struct MapViewWrapper: UIViewRepresentable{
    
    typealias UIViewType = MKMapView
    let mapView=MKMapView()
    
    func makeUIView(context: Context) -> MKMapView {
        self.mapView.delegate=context.coordinator
        return self.mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    func drawOverlay(overlay: MKPolygon){
        self.mapView.addOverlay(overlay)
    }
    
    func showRouteOnMap(route: MKRoute,showRegion:Bool=true){
        self.mapView.addOverlay(route.polyline)
        if(showRegion){
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    
    
    func removeAllItems(){
        for i in self.mapView.overlays{
            self.mapView.removeOverlay(i)
        }
    }
    
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
}

class MapViewCoordinator: NSObject,MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = .orange
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        } else if overlay is MKPolygon {
            let renderer=MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = .magenta
            return renderer
        }
        return MKPolylineRenderer(overlay: overlay)
    }
}
