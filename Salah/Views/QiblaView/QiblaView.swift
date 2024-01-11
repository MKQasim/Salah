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
    @StateObject private var locationManager = LocationManager()
    @StateObject private var deviceOrientation = OrientationManager()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(locationState.cities, id: \.self) { location in
                    let coordinate = CLLocationCoordinate2D(latitude: location.lat ?? 0, longitude: location.lng ?? 0)
                    let makkahCoordinates = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
                    let userToMakkahDirection = coordinate.angleToCoordinate(to: makkahCoordinates)
                    let makkahToUserDirection = makkahCoordinates.angleToCoordinate(to: coordinate)
                    let qiblaDirection = makkahCoordinates.angleToCoordinate(to: coordinate)
                    let userDirection = userToMakkahDirection - makkahToUserDirection

                    QiblaDirectionView(
                        locationName: location.city ?? "",
                        coordinate: coordinate,
                        deviceOrientation: deviceOrientation,
                        startDeviceMotionUpdates: startDeviceMotionUpdates,
                        stopDeviceMotionUpdates: stopDeviceMotionUpdates,
                        qiblaDirection: qiblaDirection,
                        userDirection: userDirection
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Qibla Directions")
    }

    private func startDeviceMotionUpdates() {
        let motionManager = CMMotionManager()
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
                guard let motion = motion else { return }
                let attitude = motion.attitude
                deviceOrientation.updateDeviceDirection(attitude: attitude)
            }
        }
    }

    private func stopDeviceMotionUpdates() {
        let motionManager = CMMotionManager()
        motionManager.stopDeviceMotionUpdates()
    }
}

struct QiblaDirectionView: View {
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    @ObservedObject private var deviceOrientation: OrientationManager
    let startDeviceMotionUpdates: () -> Void
    let stopDeviceMotionUpdates: () -> Void

    @State private var qiblaDirection: CLLocationDegrees = 0
    @State private var userDirection: CLLocationDegrees = 0

    var body: some View {
        VStack {
            Text(locationName)
                .font(.system(size: 12))
                .foregroundColor(.blue)

            ZStack {
                Image(systemName: "lock.fill") // Use an appropriate system image for a secret place
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.black)
                    .frame(width: 20, height: 20)
                    .offset(y: 0)
                    .overlay(
                        Text("Secret Place")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    )

                Image(systemName: "arrow.right.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.red)
                                    .frame(width: 40, height: 40)
                                    .offset(y: 100)
                                    .rotationEffect(.degrees(userDirection), anchor: .center)
                                    .overlay(
                                        GeometryReader { geometry in
                                            Path { path in
                                                let startPoint = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                                let endPoint = calculateEndPoint(geometry, userDirection: userDirection)
                                                path.move(to: startPoint)
                                                path.addLine(to: endPoint)
                                            }
                                            .stroke(Color.green, lineWidth: 2)
                                        }
                                    )
                // Arrange all 8 directions in a circle
                ForEach(DeviceDirection.allCases.filter { $0 != .unknown }, id: \.self) { direction in
                    let angle = calculateAngle(for: direction)
                    let offset = calculateOffset(for: direction)

                    Text(direction.rawValue)
                        .foregroundColor(.red)
                        .rotationEffect(.degrees(Double(angle)), anchor: .center)
                        .offset(x: offset.x, y: offset.y)
                }
            }
            .frame(width: 600, height: 600) // Adjust the frame size as needed
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.vertical, 10)
            .onAppear {
                calculateDirections()
                startDeviceMotionUpdates()
            }
            .onDisappear {
                stopDeviceMotionUpdates()
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func calculateEndPoint(_ geometry: GeometryProxy, userDirection: CLLocationDegrees) -> CGPoint {
            // Replace with actual coordinates of the secret place
            let secretPlaceCoordinates = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
            // Calculate the angle between the user and the secret place coordinates
            let userToSecretPlaceDirection = coordinate.angleToCoordinate(to: secretPlaceCoordinates)

            // Calculate the distance to cover based on the geometry size
            let distanceToCover = min(geometry.size.width, geometry.size.height) / 4

            // Calculate the end point coordinates
            let endPointX = geometry.size.width / 2 + distanceToCover * CGFloat(cos(userToSecretPlaceDirection.radians))
            let endPointY = geometry.size.height / 2 + distanceToCover * CGFloat(sin(userToSecretPlaceDirection.radians))

            return CGPoint(x: endPointX, y: endPointY)
        }

    init(locationName: String, coordinate: CLLocationCoordinate2D, deviceOrientation: OrientationManager, startDeviceMotionUpdates: @escaping () -> Void, stopDeviceMotionUpdates: @escaping () -> Void, qiblaDirection: CLLocationDegrees, userDirection: CLLocationDegrees) {
        self.locationName = locationName
        self.coordinate = coordinate
        self.deviceOrientation = deviceOrientation
        self.startDeviceMotionUpdates = startDeviceMotionUpdates
        self.stopDeviceMotionUpdates = stopDeviceMotionUpdates
        self.qiblaDirection = qiblaDirection
        self.userDirection = userDirection
    }

    private func calculateDirections() {
        let makkahCoordinates = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
        let userToMakkahDirection = coordinate.angleToCoordinate(to: makkahCoordinates)
        let makkahToUserDirection = makkahCoordinates.angleToCoordinate(to: coordinate)
        qiblaDirection = makkahCoordinates.angleToCoordinate(to: coordinate)
        userDirection = userToMakkahDirection - makkahToUserDirection
    }

    private func calculateAngle(for direction: DeviceDirection) -> CGFloat {
        let directionAngle = direction.angle
        let adjustedAngle = CGFloat(directionAngle) - userDirection
        return (adjustedAngle + 360).truncatingRemainder(dividingBy: 360)
    }

    private func calculateOffset(for direction: DeviceDirection) -> CGPoint {
        let radius: CGFloat = 150
        let angle = calculateAngle(for: direction)
        let x = radius * cos(angle * .pi / 180)
        let y = radius * sin(angle * .pi / 180)
        return CGPoint(x: x, y: y)
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

    private let motionManager = CMMotionManager()

    init() {
        startDeviceMotionUpdates()
    }

    private func startDeviceMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let motion = motion else { return }
                self?.updateDeviceDirection(attitude: motion.attitude)
            }
        }
    }

    func updateDeviceDirection(attitude: CMAttitude) {
        let azimuth = attitude.yaw.toDegrees()
        let index = (Int((azimuth + 22.5) / 45.0) + 8) % 8

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
