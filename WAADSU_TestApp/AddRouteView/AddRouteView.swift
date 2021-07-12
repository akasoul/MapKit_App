//
//  AddRouteView.swift
//  WAADSU_TestApp
//
//  Created by Anton Voloshuk on 10.07.2021.
//

import Foundation
import SwiftUI


struct AddRouteView: View {
    @ObservedObject var model = AddRouteViewModel()
    
    var body: some View{
        GeometryReader{ g in
            VStack{
                VStack(spacing:10){
                    TextField("Откуда", text: self.$model.src)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Куда", text: self.$model.dst)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                }
                if(self.model.fieldsAreEmpty() || !self.model.fieldsCompareLocations()){
                    ScrollView{
                        VStack{
                            ForEach(self.model.matchingItems,id:\.self){ i in
                                ZStack{
                                    Color.clear.contentShape(Rectangle())
                                    Text(i.name ?? "").frame(width:g.size.width,alignment: .leading)
                                }
                                .frame(width:g.size.width,alignment:.leading)
                                .onTapGesture {
                                    self.model.setLocation(location: i)
                                }
                            }
                        }
                    }
                }
                else{
                    Group{
                        HStack{
                            self.btnRoute
                                .frame(width: 75, height: 75,alignment: .leading)
                            
                            if(self.model.route != nil){
                                self.btnShowOnMap
                                    .frame(width: 75, height: 75,alignment: .leading)
                            }
                        }.frame(alignment:.topLeading)
                        if(self.model.route != nil){
                            VStack{
                                Text("Время в пути: \(String(format: "%.1f ч",self.model.route!.expectedTravelTime/3600) )")
                                    .frame(width:g.size.width,alignment:.leading)
                                Text("Расстояние: \(String(format: "%.1f км",self.model.route!.distance/1000) )")
                                    .frame(width:g.size.width,alignment:.leading)
                            }
                            .offset(y: 50)
                        }
                    }
                    .frame(width:g.size.width,alignment: .topLeading)
                }
            }
        }.padding(20)
    }
    
    func showOnMap(){
        self.model.sendRoute()
    }
    
    var btnRoute: some View{
        GeometryReader{ g in
            Group{
                Button(action: {
                    self.model.calculateRoute()
                }, label: {
                    VStack{
                        ZStack{
                            Circle()
                                .fill(Color.blue)
                            Image(systemName: "arrowshape.turn.up.forward.fill")
                                .foregroundColor(.white)
                        }
                        Text("Проложить").font(Font.system(size: 10))
                    }
                })
            }
            .frame(width: g.size.width, height: g.size.height, alignment: .center)
        }
    }
    
    
    var btnShowOnMap: some View{
        GeometryReader{ g in
            Group{
                Button(action: {
                    self.showOnMap()
                }, label: {
                    VStack{
                        ZStack{
                            Circle()
                                .fill(Color.blue)
                            Image(systemName: "map.fill")
                                .foregroundColor(.white)
                        }
                        Text("Показать").font(Font.system(size: 10))
                    }
                })
            }
            .frame(width: g.size.width, height: g.size.height, alignment: .center)
        }
    }
    
    
    
}
