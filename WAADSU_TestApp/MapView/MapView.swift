//
//  MapView.swift
//  WAADSU_TestApp
//
//  Created by Anton Voloshuk on 08.07.2021.
//

import SwiftUI
import MapKit
struct MapView: View  {
    @ObservedObject var model = MapViewModel()
    @State var addRouteViewIsPresented = false
    
    let map = MapViewWrapper()
    
    var body: some View {
        GeometryReader{ g in
            Group{
                self.map
                    .frame(width:g.size.width,height:g.size.height)
                    .onReceive(self.model.$routes, perform: { routes in
                        self.addRouteViewIsPresented=false
                        self.map.removeAllItems()
                        for i in routes{
                            self.map.showRouteOnMap(route: i, showRegion: true)
                        }
                    })
                    .onReceive(self.model.$overlays, perform: { overlays in
                        self.map.removeAllItems()
                        for i in overlays{
                            self.map.drawOverlay(overlay: i)
                        }
                    })
                
                HStack(spacing:10){
                    btnAdd
                        .frame(width: 50, height: 50)
                    
                    btnMenu
                        .frame(width: 50, height: 50)
                    
                }
                .offset(x: -10, y: 10)
            }
            .frame(width: g.size.width,height:g.size.height,alignment: .topTrailing)
            .popover(isPresented: self.$addRouteViewIsPresented, content: {
                let routeView=AddRouteView()
                routeView
                    .onAppear(perform: {
                        routeView.model.receiver=self.model
                    })
            })
        }
    }
    
    var btnAdd: some View{
        GeometryReader{ g in
            Group{
                Button(action: {
                    self.addRouteViewIsPresented=true
                }, label: {
                    ZStack{
                        Circle()
                            .fill(Color.blue)
                        Image(systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up")
                            .foregroundColor(.white)
                    }
                })
            }
            .frame(width: g.size.width, height: g.size.height, alignment: .center)
        }
    }
    
    var btnMenu: some View{
        GeometryReader{ g in
            Group{
                Menu(content: {
                    VStack{
                        BtnMenuItem(text: "URL to GeoJSON", action: {
                            self.model.loadGeoJSON()
                        })
                        
                        BtnMenuItem(text: "Cached file to GeoJSON", action: {
                            self.model.loadGeoJSONFromBundle()
                        })
                        
                        BtnMenuItem(text: "URL to Geo", action: {
                            self.model.loadGeo()
                        })
                        
                        BtnMenuItem(text: "URL to Geo (some polygons are removed)", action: {
                            self.model.loadGeoAndRemovePolygons()
                        })
                        
                        
                    }
                }, label: {
                    ZStack{
                        Circle()
                            .fill(Color.blue)
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                    }
                    
                })
            }
            .frame(width: g.size.width, height: g.size.height, alignment: .center)
        }
    }
    
    struct BtnMenuItem: View{
        let text: String
        var action: ()->Void
        var body: some View{
            GeometryReader{ g in
                Button(action: {
                    self.action()
                }, label: {
                    ZStack{
                        Color.clear.contentShape(Rectangle())
                        Text(self.text)
                    }
                    .frame(alignment:.center)
                })
            }
        }
    }
}

