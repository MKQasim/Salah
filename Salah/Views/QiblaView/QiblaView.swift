//
//  QiblaView.swift
//  Salah
//
//  Created by Qassim on 1/9/24.
//
import SwiftUI
import CoreLocation
import CoreMotion

struct QiblaView: View {
    @EnvironmentObject private var locationState: LocationState
    @StateObject var locationManager = LocationManager()
//    @StateObject var deviceOrientation = DeviceOrientation() // Create a StateObject for deviceOrientation
       
    var body: some View {
        ScrollView {
//            LazyVStack(spacing: 20) {
//                ForEach(locationState.cities, id: \.self) { location in
//                    let coordinate = CLLocationCoordinate2D(latitude: location.lat ?? 0, longitude: location.lng ?? 0)
//                    QiblaDirectionView(locationName: location.city ?? "Unknown", coordinate: coordinate, deviceOrientation: DeviceOrientation())
//                }
//            }
//            .padding()
        }
        .navigationTitle("Qibla Directions")
    }
}

struct QiblaDirectionView: View {
    let locationName: String
    let coordinate: CLLocationCoordinate2D
//    @ObservedObject var deviceOrientation: DeviceOrientation // Use ObservedObject for deviceOrientation
    
    @State private var qiblaDirection: CLLocationDegrees = 0
    @State private var userDirection: CLLocationDegrees = 0
    @State private var locationOrientation: DeviceOrientation?
    
    var body: some View {
        VStack {
            Text(locationName)
                .font(.system(size: 12))
                .foregroundColor(.blue)
            
            ZStack {
                ZStack {
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                        .offset(y: 0)
                    Text("Makkah")
                        .font(.system(size: 12))
                }
                .rotationEffect(.degrees(qiblaDirection), anchor: .center)
                
                ZStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                        .frame(width: 40, height: 40)
                        .offset(y: 180)
                    VStack {
                        Text(locationName)
                            .font(.system(size: 10))
                        Spacer()
                        HStack {
                            Spacer()
                            HStack(spacing: 5) {
                                ForEach(locationOrientation?.allDirections ?? [], id: \.self) { direction in
                                    Text(direction.rawValue.capitalized)
                                        .font(.system(size: 8))
                                        .padding()
                                        .background(Color.gray.opacity(0.5))
                                        .cornerRadius(5)
                                }
                            }
                        }
                    }
                }
                .rotationEffect(.degrees((qiblaDirection - userDirection + 360).truncatingRemainder(dividingBy: 360)), anchor: .center)
            }.frame(width: 300, height: 380)
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .padding(.vertical, 10)
        .onAppear {
            calculateDirections()
//            startDeviceMotionUpdates()
        }
        .onDisappear {
            stopDeviceMotionUpdates()
        }
//        .onChange(of: deviceOrientation.directionLabel) { _ in
//            // Update orientation when device orientation changes
////            updateLocationOrientation()
//        }
    }
    func calculateDirections() {
        let makkahCoordinates = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
        let userToMakkahDirection = coordinate.angleToCoordinate(to: makkahCoordinates)
        let makkahToUserDirection = makkahCoordinates.angleToCoordinate(to: coordinate)
        qiblaDirection = makkahCoordinates.angleToCoordinate(to: coordinate) + 180
        userDirection = userToMakkahDirection - makkahToUserDirection
    }
    
//    func startDeviceMotionUpdates() {
//           let motionManager = CMMotionManager()
//           if motionManager.isDeviceMotionAvailable {
//               motionManager.deviceMotionUpdateInterval = 0.1
//               motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
//                   guard let self = self else { return }
//                   guard let motion = motion else { return }
//                   let attitude = motion.attitude
////                   self.deviceOrientation = DeviceOrientation(attitude: attitude)
//               }
//           }
//       }

       func stopDeviceMotionUpdates() {
           let motionManager = CMMotionManager()
           motionManager.stopDeviceMotionUpdates()
       }
}

struct DeviceOrientation {
    enum CardinalDirection: String, CaseIterable {
        case north, northEast, east, southEast, south, southWest, west, northWest
    }
    
    var directionLabel: CardinalDirection = .north
    
    var allDirections: [CardinalDirection] {
        return CardinalDirection.allCases
    }
    
    private var azimuth: Double = 0
    
    init() {}
    
    init(attitude: CMAttitude) {
        azimuth = attitude.yaw.toDegrees()
    }
}

extension CLLocationCoordinate2D {
    func angleToCoordinate(to coordinate: CLLocationCoordinate2D) -> Double {
        let lat1 = self.latitude.toRadians()
        let lon1 = self.longitude.toRadians()
        let lat2 = coordinate.latitude.toRadians()
        let lon2 = coordinate.longitude.toRadians()
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return (radiansBearing.toDegrees() + 360).truncatingRemainder(dividingBy: 360)
    }
}

extension BinaryFloatingPoint {
    var radians: Self { return self * .pi / 180 }
    var degrees: Self { return self * 180 / .pi }
    func toRadians() -> Self { return self * .pi / 180 }
    func toDegrees() -> Self { return self * 180 / .pi }
}
