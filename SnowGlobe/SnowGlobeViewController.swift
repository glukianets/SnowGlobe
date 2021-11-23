import Foundation
import UIKit
import CoreMotion

class SnowGlobeViewController: UIViewController {

    @IBOutlet private var sceneView: UIView!
    @IBOutlet private var jon: UIView!
    @IBOutlet private var giftView: UIView!
    @IBOutlet private var toyViews: [UIView]!

    private var dynamicAnimator: UIDynamicAnimator!
    private var motionCaptor: MotionСaptor!

    private var snowflakes: [UIView] = []
    private var timer: DispatchSourceTimer?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var time = Date.now
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.setEventHandler { [weak self] in
            self?.update(timeInterval: time.rewindToNow())
        }
        timer.schedule(deadline: .now(), repeating: 0.2)
        timer.activate()
        self.timer = timer
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.timer?.cancel()
        self.timer = nil
    }

    private func update(timeInterval: TimeInterval) {
        guard let snowflake = self.snowflakes.popLast() else { return }
        snowflake.frame = snowflakeFrame()
        snowflake.alpha = 0
        UIView.animate(withDuration: 0.3) {
            snowflake.alpha = 1
        }

        self.dynamicAnimator.updateItem(usingCurrentState: snowflake)
        self.snowflakes.insert(snowflake, at: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = UIColor.white.cgColor
        maskLayer.path = CGPath(ellipseIn: self.sceneView.bounds, transform: nil)
        self.sceneView.layer.mask = maskLayer

        self.dynamicAnimator = UIDynamicAnimator(referenceView: self.sceneView)

        let staticItemBehavior = UIDynamicItemBehavior(items: [self.sceneView])
        staticItemBehavior.isAnchored = true
        self.dynamicAnimator.addBehavior(staticItemBehavior)

        self.snowflakes = (0..<30).map { _ in
            SnowflakeView(frame: self.snowflakeFrame())
        }
        self.snowflakes.forEach(self.sceneView.addSubview(_:))

        let dynamicItemBehavior = UIDynamicItemBehavior(items: [
            self.jon,
            self.giftView,
        ] + self.toyViews + self.snowflakes)

        self.dynamicAnimator.addBehavior(dynamicItemBehavior)

        let gravityBehavior = UIGravityBehavior(items: [
            self.jon,
            self.giftView,
        ] + self.toyViews + self.snowflakes)

        self.dynamicAnimator.addBehavior(gravityBehavior)

        let collisionBehavior = UICollisionBehavior(items: [
            self.giftView
        ])

        collisionBehavior.translatesReferenceBoundsIntoBoundary = false

        collisionBehavior.addBoundary(
            withIdentifier: "Reference" as NSString,
            for: .init(ovalIn: self.sceneView.bounds)
        )

        collisionBehavior.addBoundary(
            withIdentifier: "Bottom" as NSString,
            for: .init(rect: self.sceneView.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)))
        )

        self.dynamicAnimator.addBehavior(collisionBehavior)

        let jonAttachmentBehavior = UIAttachmentBehavior.pinAttachment(
            with: self.jon,
            attachedTo: self.sceneView,
            attachmentAnchor: CGPoint(x: self.jon.frame.midX, y: self.jon.frame.maxY)
        )
        jonAttachmentBehavior.attachmentRange = UIFloatRange(minimum: -0.1, maximum: 0.1)
        
        self.dynamicAnimator.addBehavior(jonAttachmentBehavior)

        for toy in self.toyViews {
            let behavior = UIAttachmentBehavior.pinAttachment(
                with: toy,
                attachedTo: self.jon,
                attachmentAnchor: toy.frame.topMid
            )
            self.dynamicAnimator.addBehavior(behavior)
        }

        let noiseBehavior = UIFieldBehavior.noiseField(smoothness: 0.1, animationSpeed: 1)
        noiseBehavior.strength = 0.1
        noiseBehavior.smoothness = 0.3
        noiseBehavior.direction = CGVector(dx: 0, dy: -1)
        self.snowflakes.forEach(noiseBehavior.addItem(_:))
        self.dynamicAnimator.addBehavior(noiseBehavior)

        let dampenBehavior = UIFieldBehavior.dragField()
        dampenBehavior.falloff = 0
        dampenBehavior.strength = 0.1
        self.snowflakes.forEach(dampenBehavior.addItem(_:))
        self.dynamicAnimator.addBehavior(dampenBehavior)

        var lastMotionCaptureDate = Date.now
        self.motionCaptor = try! MotionСaptor { data in
            let dt = Double(lastMotionCaptureDate.rewindToNow())
            let gravityVector = CGVector(dx: data.gravity.x, dy: -data.gravity.y)
            let acceleration = CGVector(
                dx: data.userAcceleration.x,
                dy: -data.userAcceleration.y
            )

            gravityBehavior.gravityDirection = gravityVector

            let linearVelocity = acceleration * 5000 * dt
            let angularVelocity = data.rotationRate.z * dt

            for item in dynamicItemBehavior.items {
                dynamicItemBehavior.addLinearVelocity(linearVelocity.cgPoint, for: item)
                dynamicItemBehavior.addAngularVelocity(CGFloat(angularVelocity), for: item)
            }
        }
    }

    private func snowflakeFrame() -> CGRect {
        let random = CGFloat.random(in: -0.4...0.4)
        let upwardsAngle = CGFloat.pi * 1.5
        let angle: CGFloat = upwardsAngle + CGFloat.pi * random
        let bounds = self.sceneView.bounds
        let width = bounds.size.width / 2
        let height = bounds.size.height / 2
        let origin = CGPoint(
            x: cos(angle) * width * 0.9 + width,
            y: sin(angle) * height * 0.9 + height
        )
        let size = CGSize(width: 10, height: 10)
        let frame = CGRect(origin: origin, size: size)
        return frame
    }

}

fileprivate extension SnowGlobeViewController {
    private class SnowflakeView: UIView {
        override static var layerClass: AnyClass {
            CAShapeLayer.self
        }

        override public init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        public override func awakeFromNib() {
            super.awakeFromNib()
            self.setup()
        }

        private func setup() {
            let layer = self.layer as! CAShapeLayer
            layer.path = CGPath(ellipseIn: self.bounds, transform: nil)
            layer.fillColor = UIColor.white.cgColor
        }

        override public var collisionBoundsType: UIDynamicItemCollisionBoundsType {
            .ellipse
        }
    }
}
