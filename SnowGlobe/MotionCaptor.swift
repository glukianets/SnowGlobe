import CoreMotion

internal final class MotionСaptor {
    private let motionManager = CMMotionManager()

    init(motionHandler: @escaping (CMDeviceMotion) -> Void) throws  {
        guard self.motionManager.isDeviceMotionAvailable else { throw "Device motion unavailable" }

        let availableFrames = CMMotionManager.availableAttitudeReferenceFrames()
        let preferredFrames: [CMAttitudeReferenceFrame] = [
            .xTrueNorthZVertical,
            .xArbitraryCorrectedZVertical,
            .xArbitraryZVertical
        ]

        let frame = preferredFrames.first { availableFrames.contains($0) } ?? preferredFrames.last!

        self.motionManager.startDeviceMotionUpdates(using: frame, to: .main) { data, error in
            data.map(motionHandler)
        }
    }

    deinit {
        self.motionManager.stopGyroUpdates()
    }
}
