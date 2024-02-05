//
//  QiblaView.swift
//  Salah
//
//  Created by Qassim on 1/9/24.
//
import SwiftUI
import CoreLocation
import CoreMotion

//struct QiblaView: View {
//    @EnvironmentObject private var locationState: LocationState
//    @StateObject var locationManager = LocationManager()
//    @StateObject var deviceOrientation = DeviceOrientation()
//
//    var body: some View {
//        ScrollView {
//            LazyVStack(spacing: 20) {
//                ForEach($locationState.cities, id: \.self) { location in
//                    if let location = location.wrappedValue as? Location {
//                        let coordinate = CLLocationCoordinate2D(latitude: location.lat ?? 0, longitude: location.lng ?? 0)
//                        QiblaDirectionView(locationName: location.city ?? "Unknown", coordinate: coordinate, deviceOrientation: deviceOrientation)
//                    } else {
//                        Text("Empty location")
//                    }
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Qibla Directions")
//    }
//}
//
//struct QiblaDirectionView: View {
//    let locationName: String
//    let coordinate: CLLocationCoordinate2D
//    @ObservedObject var deviceOrientation: DeviceOrientation
//
//    @State private var qiblaDirection: CLLocationDegrees = 0
//    @State private var userDirection: CLLocationDegrees = 0
//
//    var body: some View {
//        VStack {
//            Text(locationName)
//                .font(.system(size: 12))
//                .foregroundColor(.blue)
//            ZStack {
//                Image(systemName: "mappin.circle.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .foregroundColor(.blue)
//                    .frame(width: 140, height: 140)
//                    .offset(y: 0)
//                    .rotationEffect(.degrees(qiblaDirection), anchor: .center)
//                Text("Makkah")
//                    .font(.system(size: 12))
//                    .rotationEffect(.degrees(qiblaDirection), anchor: .center)
//                Image(systemName: "person.circle.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .foregroundColor(.red)
//                    .frame(width: 40, height: 40)
//                    .offset(y: 180)
//                    .rotationEffect(.degrees(userDirection), anchor: .center)
//            }
//            .frame(width: 300, height: 380)
//            .background(Color.gray.opacity(0.2))
//            .cornerRadius(10)
//            .padding(.vertical, 10)
//            .onAppear {
//                calculateDirections()
//                startDeviceMotionUpdates()
//            }
//            .onDisappear {
//                stopDeviceMotionUpdates()
//            }
//        }
//        .frame(maxWidth: .infinity)
//    }
//
//    func calculateDirections() {
//        let makkahCoordinates = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
//
//        // Use azimuth from deviceOrientation
//        let userToMakkahDirection = deviceOrientation.azimuth
//        let makkahToUserDirection = makkahCoordinates.angleToCoordinate(to: coordinate)
//
//        // Calculate qiblaDirection (stick to a fixed value)
//        qiblaDirection = makkahToUserDirection  // Adjust this value as needed
//
//        // Calculate userDirection based on azimuth
//        userDirection = (userToMakkahDirection - makkahToUserDirection + 360).truncatingRemainder(dividingBy: 360)
//
//        print("userDirection", userDirection)
//        print("qiblaDirection", qiblaDirection)
//    }
//
//    func startDeviceMotionUpdates() {
//        deviceOrientation.startDeviceMotionUpdates { [self] in
//            calculateDirections()
//        }
//    }
//
//    func stopDeviceMotionUpdates() {
//        deviceOrientation.stopDeviceMotionUpdates()
//    }
//}
//
class DeviceOrientation: ObservableObject {
    @Published var azimuth: Double = 0
    private let motionManager = CMMotionManager()

    func updateDirection(attitude: CMAttitude) {
        azimuth = attitude.yaw.toDegrees()
    }

    func startDeviceMotionUpdates(updateHandler: @escaping () -> Void) {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let self = self, let motion = motion else { return }
                let attitude = motion.attitude
                self.updateDirection(attitude: attitude)
                updateHandler()
            }
        }
    }

    func stopDeviceMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

// Extensions and utility functions remain the same

// Extension and other utility functions remain the same

extension QiblaDirectionView {
    func calculateDirections() {
        let makkahCoordinates = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)

        // Use azimuth from deviceOrientation
        let userToMakkahDirection = deviceOrientation.azimuth
        let makkahToUserDirection = makkahCoordinates.angleToCoordinate(to: coordinate)

        // Calculate qiblaDirection (stick to a fixed value)
        qiblaDirection = makkahToUserDirection  // Adjust this value as needed

        // Calculate userDirection based on azimuth
        userDirection = (userToMakkahDirection - makkahToUserDirection + 360).truncatingRemainder(dividingBy: 360)

        print("userDirection", userDirection)
        print("qiblaDirection", qiblaDirection)
    }
}



struct QiblaView: View {
    @EnvironmentObject var locationState: LocationState
    @ObservedObject var locationManager = LocationManager()
    @StateObject var deviceOrientation = OrientationManager()

    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(locationState.cities, id: \.self) { location in
                    if let location = location as? Location{
                        let coordinate = CLLocationCoordinate2D(latitude: location.lat ?? 0.0, longitude: location.lng ?? 0.0)

                        QiblaDirectionView(locationName: location.city ?? "Unknown City", locationState: locationState, coordinate: coordinate, deviceOrientation: deviceOrientation, startLocationUpdates: {
                            locationManager.startLocationUpdates()
                        }, stopLocationUpdates: {
                            locationManager.stopLocationUpdates()
                        }, qiblaDirection: 0, userDirection: 0, userHeading: locationManager.currentHeading)
                        .padding(.bottom, 20)
                    } else {
                        Text("Empty location")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Qibla Directions")
    }
}

struct QiblaDirectionView: View {
    let locationName: String
    let locationState: LocationState
    let coordinate: CLLocationCoordinate2D
    @ObservedObject private var deviceOrientation: OrientationManager
    let startLocationUpdates: () -> Void
    let stopLocationUpdates: () -> Void
    let locationManager = LocationManager()
    @State private var qiblaDirection: CLLocationDegrees? = 0
    @State private var userDirection: CLLocationDegrees? = 0
    @State private var userHeading: CLHeading?


    init(locationName: String, locationState: LocationState, coordinate: CLLocationCoordinate2D, deviceOrientation: OrientationManager, startLocationUpdates: @escaping () -> Void, stopLocationUpdates: @escaping () -> Void, qiblaDirection: CLLocationDegrees, userDirection: CLLocationDegrees, userHeading: CLHeading? = nil) {
        self.locationName = locationName
        self.locationState = locationState
        self.coordinate = coordinate
        self.deviceOrientation = deviceOrientation
        self.startLocationUpdates = startLocationUpdates
        self.stopLocationUpdates = stopLocationUpdates
        self.qiblaDirection = qiblaDirection
        self.userDirection = userDirection
        self.userHeading = userHeading
    }

    private var rotationEffect: Angle {
        if let heading = userHeading?.trueHeading {
            return Angle(degrees: heading - (userDirection ?? 0.0))
        } else {
            return Angle(degrees: -(userDirection ?? 0.0))
        }
    }
        func startDeviceMotionUpdates() {
            deviceOrientation.startDeviceMotionUpdates { [self] in
                calculateDirections()
            }
        }
    
        func stopDeviceMotionUpdates() {
            deviceOrientation.stopDeviceMotionUpdates()
        }
    
    var body: some View {
        VStack {
            Text(locationName)
                .font(.system(size: 12))
                .foregroundColor(.blue)

            ZStack {
                if let currentHeading = locationManager.currentHeading {
                        HeadingIndicator(
                            currentLocation: coordinate,
                            currentHeading: currentHeading,
                            targetLocation: locationManager.userLocation
                        ) {
                            Image(systemName: "arrow.up.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.red)
                                .frame(width: 140, height: 140)
                        }
                }
                
//                Image("makkah") // Replace with your image
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .foregroundColor(.black)
//                    .frame(width: 80, height: 80)
//                    .offset(y: 0)
//                    .overlay(
//                        Text("Secret Place")
//                            .font(.system(size: 12))
//                            .foregroundColor(.white)
//                    )
            

//                Image(systemName: "arrow.right.circle.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .foregroundColor(.red)
//                    .frame(width: 40, height: 40)
//                    .offset(y: 100)
//                    .rotationEffect(.degrees(userDirection), anchor: .center)
//                    .overlay(
//                        GeometryReader { geometry in
//                            Path { path in
//                                let startPoint = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
//                                let endPoint = calculateEndPoint(geometry, userDirection: userDirection)
//                                path.move(to: startPoint)
//                                path.addLine(to: endPoint)
//                            }
//                            .stroke(Color.green, lineWidth: 2)
//                        }
//                    )


                // Arrange all 8 directions in a circle
//                ForEach(DeviceDirection.allCases.filter { $0 != .unknown }, id: \.self) { direction in
//                    let (angle, angleNumber) = calculateAngle(for: direction, adjustedAzimuth: deviceOrientation.azimuth)
//                    let offset = calculateOffset(for: direction, adjustedAzimuth: deviceOrientation.azimuth)
//
//                    Text("\(direction.rawValue) : \(angleNumber)")
//                        .foregroundColor(.red)
//                        .font(angleNumber % 10 == 0 ? .headline : .subheadline)
//                        .rotationEffect(.degrees(Double(angle)), anchor: .center)
//                        .offset(x: offset.x, y: offset.y)
//                }

            }
            .frame(width: 600, height: 600) // Adjust the frame size as needed
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.vertical, 10)
            .onAppear {
                startLocationUpdates()
                locationManager.startHeadingUpdates()
                startDeviceMotionUpdates()
                calculateDirections()
            }
            .onDisappear {
                stopLocationUpdates()
                stopDeviceMotionUpdates()
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func calculateEndPoint(_ geometry: GeometryProxy, userDirection: CLLocationDegrees) -> CGPoint {
        let secretPlaceCoordinates = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
        let userToSecretPlaceDirection = coordinate.angleToCoordinate(to: secretPlaceCoordinates)
        let distanceToCover = min(geometry.size.width, geometry.size.height) / 4
        let endPointX = geometry.size.width / 2 + distanceToCover * CGFloat(cos(userToSecretPlaceDirection.radians))
        let endPointY = geometry.size.height / 2 + distanceToCover * CGFloat(sin(userToSecretPlaceDirection.radians))

        return CGPoint(x: endPointX, y: endPointY)
    }

    private func calculateOffset(for direction: DeviceDirection, adjustedAzimuth: Double) -> CGPoint {
        let radius: CGFloat = 150
        let (angle, angleNumber) = calculateAngle(for: direction, adjustedAzimuth: adjustedAzimuth)
        
        let x = radius * cos(angle.radians)
        let y = radius * sin(angle.radians)

        return CGPoint(x: x, y: y)
    }

    private func calculateAngle(for direction: DeviceDirection, adjustedAzimuth: Double) -> (CGFloat, Int) {
        let directionAngle = direction.angle
        print("direction.angle",direction.angle)
        print("adjustedAzimuth",adjustedAzimuth)
        let adjustedAngle = CGFloat(directionAngle - adjustedAzimuth)
        let finalAngle = (adjustedAngle + 360).truncatingRemainder(dividingBy: 360)
        let angleNumber = Int(finalAngle)

        return (finalAngle, angleNumber)
    }


}

class LocationDelegate: NSObject, CLLocationManagerDelegate {
    var didUpdateHeading: ((CLHeading) -> Void)?

    func setUpdateHeadingClosure(_ closure: @escaping (CLHeading) -> Void) {
        didUpdateHeading = closure
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        didUpdateHeading?(newHeading)
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

class OrientationManager: ObservableObject {
    @Published var deviceDirection: DeviceDirection = .unknown
    @Published var azimuth: Double = 0
    #if os(iOS)
    private let motionManager = CMMotionManager()
    #endif

    func startDeviceMotionUpdates(updateHandler: @escaping () -> Void) {
#if os(iOS)
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard  let motion = motion else { return }
                let attitude = motion.attitude
                self?.updateDeviceDirection(attitude: motion.attitude)
                updateHandler()
            }
        }
#endif
    }
    
    func stopDeviceMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }

    func updateDeviceDirection(attitude: CMAttitude) {
        azimuth = attitude.yaw.toDegrees()
        
        // Adjust azimuth to be in the range [0, 360)
        let adjustedAzimuth = (azimuth + 360).truncatingRemainder(dividingBy: 360)
        
        // Calculate the index based on adjusted azimuth
        let index = (Int((adjustedAzimuth + 22.5) / 45.0) + 8) % 8
        
        // Set the deviceDirection
        deviceDirection = DeviceDirection.allCases[index]
    }


    func getOppositeDirection() -> DeviceDirection {
        return deviceDirection.opposite
    }

    func getPreviousDirection() -> DeviceDirection {
        return deviceDirection.previous
    }

    func getNextDirection() -> DeviceDirection {
        return deviceDirection.next
    }
}

extension DeviceDirection {
    static var allAngles: [Double] {
        return DeviceDirection.allCases.map { $0.angle }
    }
    var opposite: DeviceDirection {
        switch self {
        case .north(let angle): return .south(angle: (angle + 180).truncatingRemainder(dividingBy: 360))
        case .northEast(let angle): return .southWest(angle: (angle + 180).truncatingRemainder(dividingBy: 360))
        case .east(let angle): return .west(angle: (angle + 180).truncatingRemainder(dividingBy: 360))
        case .southEast(let angle): return .northWest(angle: (angle + 180).truncatingRemainder(dividingBy: 360))
        case .south(let angle): return .north(angle: (angle + 180).truncatingRemainder(dividingBy: 360))
        case .southWest(let angle): return .northEast(angle: (angle + 180).truncatingRemainder(dividingBy: 360))
        case .west(let angle): return .east(angle: (angle + 180).truncatingRemainder(dividingBy: 360))
        case .northWest(let angle): return .southEast(angle: (angle + 180).truncatingRemainder(dividingBy: 360))
        case .unknown: return .unknown
        }
    }

    var previous: DeviceDirection {
        let allCases = DeviceDirection.allCases
        guard let currentIndex = allCases.firstIndex(of: self) else { return .unknown }
        let previousIndex = (currentIndex - 1 + allCases.count) % allCases.count
        return allCases[previousIndex]
    }

    var next: DeviceDirection {
        let allCases = DeviceDirection.allCases
        guard let currentIndex = allCases.firstIndex(of: self) else { return .unknown }
        let nextIndex = (currentIndex + 1) % allCases.count
        return allCases[nextIndex]
    }
}

enum DeviceDirection: CaseIterable , Equatable , Hashable{
    
    case north(angle: Double), northEast(angle: Double), east(angle: Double), southEast(angle: Double), south(angle: Double), southWest(angle: Double), west(angle: Double), northWest(angle: Double), unknown
    
    static var allCases: [DeviceDirection] {
        return [
            .north(angle: 0),
            .northEast(angle: 45),
            .east(angle: 90),
            .southEast(angle: 135),
            .south(angle: 180),
            .southWest(angle: 225),
            .west(angle: 270),
            .northWest(angle: 315),
            .unknown
        ]
    }
    
    init(rawValue: String) {
        switch rawValue {
        case "north": self = .north(angle: 0)
        case "northEast": self = .northEast(angle: 45)
        case "east": self = .east(angle: 90)
        case "southEast": self = .southEast(angle: 135)
        case "south": self = .south(angle: 180)
        case "southWest": self = .southWest(angle: 225)
        case "west": self = .west(angle: 270)
        case "northWest": self = .northWest(angle: 315)
        default: self = .unknown
        }
    }
    
    var rawValue: String {
        switch self {
        case .north: return "north"
        case .northEast: return "northEast"
        case .east: return "east"
        case .southEast: return "southEast"
        case .south: return "south"
        case .southWest: return "southWest"
        case .west: return "west"
        case .northWest: return "northWest"
        case .unknown: return "unknown"
        }
    }
    
    var angle: Double {
        switch self {
        case .north(let angle), .northEast(let angle), .east(let angle), .southEast(let angle), .south(let angle), .southWest(let angle), .west(let angle), .northWest(let angle):
            return angle
        case .unknown:
            return 0
        }
    }
}


import CoreLocation
import SwiftUI

public struct HeadingIndicator<Content: View>: View {
    let currentLocation: CLLocationCoordinate2D
    let currentHeading: CLHeading?
    let targetLocation: CLLocationCoordinate2D
    let content: Content

    var targetBearing: Double {
        let deltaL = targetLocation.longitude.radians - currentLocation.longitude.radians
        let thetaB = targetLocation.latitude.radians
        let thetaA = currentLocation.latitude.radians

        let x = cos(thetaB) * sin(deltaL)
        let y = cos(thetaA) * sin(thetaB) - sin(thetaA) * cos(thetaB) * cos(deltaL)
        let bearing = atan2(x, y)

        return bearing.degrees
    }

    var targetHeading: Double {
        if let currentHeading = currentHeading {
            print("Current Heading: \(currentHeading)")
            return targetBearing - currentHeading.trueHeading
        } else {
            print("Current Heading is nil.")
            return 0
        }
    }


    public init(currentLocation: CLLocationCoordinate2D,
                currentHeading: CLHeading?,
                targetLocation: CLLocationCoordinate2D,
                content: Content)
    {
        self.currentLocation = currentLocation
        self.currentHeading = currentHeading
        self.targetLocation = targetLocation
        self.content = content
    }

    public init(currentLocation: CLLocationCoordinate2D,
                currentHeading: CLHeading?,
                targetLocation: CLLocationCoordinate2D,
                contentBuilder: () -> Content)
    {
        self.currentLocation = currentLocation
        self.currentHeading = currentHeading
        self.targetLocation = targetLocation
        self.content = contentBuilder()
    }

    public var body: some View {
        content
            .rotationEffect(.degrees(self.targetHeading))
    }
}

import Foundation

internal extension Double {
    var radians: Double {
        Measurement(value: self, unit: UnitAngle.degrees)
            .converted(to: .radians)
            .value
    }

    var degrees: Double {
        Measurement(value: self, unit: UnitAngle.radians)
            .converted(to: .degrees)
            .value
    }
}
