import Flutter
import UIKit
import AVFoundation
import Vision

public class CoreCameraPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterTexture, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    private var textureRegistry: FlutterTextureRegistry?
    private var textureId: Int64 = -1
    private var eventSink: FlutterEventSink?

    private let sessionQueue = DispatchQueue(label: "com.core.camera.session")
    private let analysisQueue = DispatchQueue(label: "com.core.camera.analysis")

    private var captureSession: AVCaptureSession?
    private var currentDevice: AVCaptureDevice?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var latestPixelBuffer: CVPixelBuffer?
    private let pixelBufferLock = NSLock()

    private var pendingPhotoResult: FlutterResult?
    private var isFrontFacing: Bool = false
    private var isAnalysisPaused: Bool = false
    private var enableFaceAutoFocus: Bool = true
    private var lastAnalyzeTime: TimeInterval = 0
    private var lastManualFocusTime: TimeInterval = 0
    private var lastAutoFocusTime: TimeInterval = 0

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = CoreCameraPlugin()
        instance.textureRegistry = registrar.textures()

        let methodChannel = FlutterMethodChannel(name: "com.core.camera/methods", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        let eventChannel = FlutterEventChannel(name: "com.core.camera/analysis_events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    public func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        pixelBufferLock.lock()
        defer { pixelBufferLock.unlock() }
        guard let buffer = latestPixelBuffer else { return nil }
        return Unmanaged.passRetained(buffer)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "detectFacesFromFile":
            handleDetectFacesFromFile(call: call, result: result)
        case "detectFacesFromBytes":
            handleDetectFacesFromBytes(call: call, result: result)
        case "availableCameras":
            let discovery = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera],
                mediaType: .video,
                position: .unspecified
            )
            let list: [[String: Any]] = discovery.devices.map { device in
                let dir: String
                switch device.position {
                case .front: dir = "front"
                case .back: dir = "back"
                default: dir = "external"
                }
                return [
                    "name": device.uniqueID,
                    "lensDirection": dir,
                    "sensorOrientation": 90
                ]
            }
            result(list)

        case "initialize":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "InvalidArgs", message: "Arguments missing", details: nil))
                return
            }
            let cameraName = args["cameraName"] as? String ?? ""
            let lensDirection = args["lensDirection"] as? String ?? "back"
            let enableAutoFocus = args["enableFaceAutoFocus"] as? Bool ?? true
            self.isFrontFacing = (lensDirection == "front")
            self.enableFaceAutoFocus = enableAutoFocus
            initializeCamera(cameraName: cameraName, result: result)

        case "takePicture":
            takePicture(result: result)

        case "setFocusAndExposurePoint":
            if let args = call.arguments as? [String: Any],
               let x = args["x"] as? Double,
               let y = args["y"] as? Double {
                lastManualFocusTime = CACurrentMediaTime()
                setFocusAndExposure(x: CGFloat(x), y: CGFloat(y))
            }
            result(nil)

        case "setFlashMode":
            result(nil)

        case "setZoomLevel":
            if let args = call.arguments as? [String: Any],
               let zoom = args["zoom"] as? Double {
                sessionQueue.async { [weak self] in
                    guard let device = self?.currentDevice else { return }
                    do {
                        try device.lockForConfiguration()
                        let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 8.0)
                        device.videoZoomFactor = max(1.0, min(CGFloat(zoom), maxZoom))
                        device.unlockForConfiguration()
                    } catch {}
                }
            }
            result(nil)

        case "setAnalysisPaused":
            if let args = call.arguments as? [String: Any],
               let paused = args["paused"] as? Bool {
                isAnalysisPaused = paused
            }
            result(nil)

        case "dispose":
            disposeSession()
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initializeCamera(cameraName: String, result: @escaping FlutterResult) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.disposeSessionSync()

            let session = AVCaptureSession()
            // .photo 预设为 iOS 原生 4:3 最高清画幅
            if session.canSetSessionPreset(.photo) {
                session.sessionPreset = .photo
            } else {
                session.sessionPreset = .high
            }

            let device = AVCaptureDevice(uniqueID: cameraName) ?? AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: self.isFrontFacing ? .front : .back
            )

            guard let captureDevice = device,
                  let input = try? AVCaptureDeviceInput(device: captureDevice),
                  session.canAddInput(input) else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "CameraInitError", message: "Unable to open camera input", details: nil))
                }
                return
            }

            session.beginConfiguration()
            session.addInput(input)
            self.currentDevice = captureDevice

            let videoOut = AVCaptureVideoDataOutput()
            videoOut.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            videoOut.alwaysDiscardsLateVideoFrames = true
            videoOut.setSampleBufferDelegate(self, queue: self.analysisQueue)
            if session.canAddOutput(videoOut) {
                session.addOutput(videoOut)
                if let connection = videoOut.connection(with: .video) {
                    if connection.isVideoOrientationSupported {
                        connection.videoOrientation = .portrait
                    }
                    if self.isFrontFacing && connection.isVideoMirroringSupported {
                        connection.isVideoMirrored = true
                    }
                }
            }
            self.videoOutput = videoOut

            let photoOut = AVCapturePhotoOutput()
            photoOut.isHighResolutionCaptureEnabled = true
            if session.canAddOutput(photoOut) {
                session.addOutput(photoOut)
            }
            self.photoOutput = photoOut

            session.commitConfiguration()
            session.startRunning()
            self.captureSession = session

            DispatchQueue.main.async {
                if let registry = self.textureRegistry {
                    self.textureId = registry.register(self)
                }
                result([
                    "textureId": self.textureId,
                    "previewWidth": 1440.0,
                    "previewHeight": 1080.0,
                    "sensorOrientation": 0,
                    "handlesCropAndRotation": true
                ])
            }
        }
    }

    private func takePicture(result: @escaping FlutterResult) {
        sessionQueue.async { [weak self] in
            guard let self = self, let photoOut = self.photoOutput else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "NotInitialized", message: "PhotoOutput not ready", details: nil))
                }
                return
            }
            self.pendingPhotoResult = result
            let settings = AVCapturePhotoSettings()
            settings.isHighResolutionPhotoEnabled = true
            if let connection = photoOut.connection(with: .video), connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            photoOut.capturePhoto(with: settings, delegate: self)
        }
    }

    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let callback = pendingPhotoResult else { return }
        pendingPhotoResult = nil

        if let error = error {
            DispatchQueue.main.async {
                callback(FlutterError(code: "CaptureError", message: error.localizedDescription, details: nil))
            }
            return
        }

        guard let data = photo.fileDataRepresentation() else {
            DispatchQueue.main.async {
                callback(FlutterError(code: "CaptureError", message: "Empty photo data", details: nil))
            }
            return
        }

        let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent("CAP_\(UUID().uuidString).jpg")
        do {
            try data.write(to: tempUrl)
            DispatchQueue.main.async {
                callback(tempUrl.path)
            }
        } catch {
            DispatchQueue.main.async {
                callback(FlutterError(code: "FileError", message: error.localizedDescription, details: nil))
            }
        }
    }

    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        pixelBufferLock.lock()
        latestPixelBuffer = pixelBuffer
        pixelBufferLock.unlock()

        if textureId >= 0 {
            textureRegistry?.textureFrameAvailable(textureId)
        }

        if isAnalysisPaused { return }
        let now = CACurrentMediaTime()
        if now - lastAnalyzeTime < 0.15 { return }
        lastAnalyzeTime = now

        let width = Double(CVPixelBufferGetWidth(pixelBuffer))
        let height = Double(CVPixelBufferGetHeight(pixelBuffer))

        let request = VNDetectFaceLandmarksRequest { [weak self] req, _ in
            guard let self = self else { return }
            let observations = (req.results as? [VNFaceObservation]) ?? []
            var serializedFaces: [[String: Any]] = []

            for obs in observations {
                let box = obs.boundingBox
                let left = box.minX * width
                let top = (1.0 - box.maxY) * height
                let right = box.maxX * width
                let bottom = (1.0 - box.minY) * height

                let yawDeg = (obs.yaw?.doubleValue ?? 0.0) * 180.0 / Double.pi
                let rollDeg = (obs.roll?.doubleValue ?? 0.0) * 180.0 / Double.pi
                var pitchDeg = 0.0
                if #available(iOS 15.0, *) {
                    pitchDeg = (obs.pitch?.doubleValue ?? 0.0) * 180.0 / Double.pi
                }

                serializedFaces.append([
                    "left": left,
                    "top": top,
                    "right": right,
                    "bottom": bottom,
                    "headEulerAngleX": pitchDeg,
                    "headEulerAngleY": yawDeg,
                    "headEulerAngleZ": rollDeg,
                    "leftEyeOpenProbability": 0.85,
                    "rightEyeOpenProbability": 0.85
                ])
            }

            DispatchQueue.main.async {
                self.eventSink?([
                    "frameWidth": width,
                    "frameHeight": height,
                    "isAmbientDark": false,
                    "ambientLuminance": 128.0,
                    "faces": serializedFaces
                ])
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        try? handler.perform([request])
    }

    private func setFocusAndExposure(x: CGFloat, y: CGFloat) {
        sessionQueue.async { [weak self] in
            guard let device = self?.currentDevice else { return }
            do {
                try device.lockForConfiguration()
                let point = CGPoint(x: y, y: 1.0 - x)
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
                    device.focusPointOfInterest = point
                    device.focusMode = .autoFocus
                }
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(.autoExpose) {
                    device.exposurePointOfInterest = point
                    device.exposureMode = .autoExpose
                }
                device.unlockForConfiguration()
            } catch {}
        }
    }

    private func disposeSession() {
        sessionQueue.async { [weak self] in
            self?.disposeSessionSync()
        }
    }

    private func disposeSessionSync() {
        captureSession?.stopRunning()
        captureSession = nil
        currentDevice = nil
        photoOutput = nil
        videoOutput = nil
        pixelBufferLock.lock()
        latestPixelBuffer = nil
        pixelBufferLock.unlock()
        if textureId >= 0 {
            let id = textureId
            textureId = -1
            DispatchQueue.main.async { [weak self] in
                self?.textureRegistry?.unregisterTexture(id)
            }
        }
    }

    private func handleDetectFacesFromFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let filePath = args["filePath"] as? String else {
            result(FlutterError(code: "InvalidArgs", message: "filePath is required", details: nil))
            return
        }
        let url = URL(fileURLWithPath: filePath)
        guard let image = UIImage(contentsOfFile: filePath), let cgImage = image.cgImage else {
            result(FlutterError(code: "FileNotFound", message: "Failed to read image at: \(filePath)", details: nil))
            return
        }
        performFaceDetection(cgImage: cgImage, orientation: cgImageOrientation(from: image.imageOrientation), result: result)
    }

    private func handleDetectFacesFromBytes(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let typedData = args["bytes"] as? FlutterStandardTypedData else {
            result(FlutterError(code: "InvalidArgs", message: "bytes data is required", details: nil))
            return
        }
        guard let image = UIImage(data: typedData.data), let cgImage = image.cgImage else {
            result(FlutterError(code: "DecodeFailed", message: "Failed to decode UIImage from bytes", details: nil))
            return
        }
        performFaceDetection(cgImage: cgImage, orientation: cgImageOrientation(from: image.imageOrientation), result: result)
    }

    private func performFaceDetection(cgImage: CGImage, orientation: CGImagePropertyOrientation, result: @escaping FlutterResult) {
        analysisQueue.async {
            let width = CGFloat(cgImage.width)
            let height = CGFloat(cgImage.height)

            let request = VNDetectFaceLandmarksRequest { req, err in
                if let err = err {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "AnalysisFailed", message: err.localizedDescription, details: nil))
                    }
                    return
                }

                guard let observations = req.results as? [VNFaceObservation] else {
                    DispatchQueue.main.async { result([]) }
                    return
                }

                var serializedFaces: [[String: Any]] = []
                for obs in observations {
                    let box = obs.boundingBox
                    let left = box.origin.x * width
                    let bottom = (1.0 - box.origin.y) * height
                    let right = (box.origin.x + box.size.width) * width
                    let top = (1.0 - (box.origin.y + box.size.height)) * height

                    let yawDeg = -(obs.yaw?.doubleValue ?? 0.0) * (180.0 / .pi)
                    let pitchDeg = (obs.pitch?.doubleValue ?? 0.0) * (180.0 / .pi)
                    let rollDeg = -(obs.roll?.doubleValue ?? 0.0) * (180.0 / .pi)

                    var faceMap: [String: Any] = [
                        "left": left,
                        "top": top,
                        "right": right,
                        "bottom": bottom,
                        "headEulerAngleX": pitchDeg,
                        "headEulerAngleY": yawDeg,
                        "headEulerAngleZ": rollDeg,
                        "leftEyeOpenProbability": 0.85,
                        "rightEyeOpenProbability": 0.85
                    ]

                    // 提取 iOS Apple Vision 精准双眼物理关键点
                    if let landmarks = obs.landmarks,
                       let leftEye = landmarks.leftEye,
                       let rightEye = landmarks.rightEye,
                       !leftEye.normalizedPoints.isEmpty,
                       !rightEye.normalizedPoints.isEmpty {
                        let leftPoints = leftEye.normalizedPoints
                        let rightPoints = rightEye.normalizedPoints
                        let leftAvgY = leftPoints.map { $0.y }.reduce(0, +) / CGFloat(leftPoints.count)
                        let leftAvgX = leftPoints.map { $0.x }.reduce(0, +) / CGFloat(leftPoints.count)
                        let rightAvgY = rightPoints.map { $0.y }.reduce(0, +) / CGFloat(rightPoints.count)
                        let rightAvgX = rightPoints.map { $0.x }.reduce(0, +) / CGFloat(rightPoints.count)

                        // VNFaceLandmarkRegion2D 的坐标系是相对于 obs.boundingBox 的归一化坐标 [0, 1]
                        let leftPixelX = (box.origin.x + leftAvgX * box.size.width) * width
                        let leftPixelY = (1.0 - (box.origin.y + leftAvgY * box.size.height)) * height
                        let rightPixelX = (box.origin.x + rightAvgX * box.size.width) * width
                        let rightPixelY = (1.0 - (box.origin.y + rightAvgY * box.size.height)) * height

                        faceMap["eyeY"] = (leftPixelY + rightPixelY) / 2.0
                        faceMap["leftEyeX"] = leftPixelX
                        faceMap["leftEyeY"] = leftPixelY
                        faceMap["rightEyeX"] = rightPixelX
                        faceMap["rightEyeY"] = rightPixelY
                    }

                    // 提取 iOS Apple Vision 精准下巴轮廓尖端 (Chin Tip)，绝不使用外接框粗算
                    if let landmarks = obs.landmarks,
                       let contour = landmarks.faceContour,
                       !contour.normalizedPoints.isEmpty {
                        // 在 Vision 中，Y 轴 0 在底部，1 在顶部。所以找下巴尖对应最小的 y 值
                        var minNormY: CGFloat = 1.0
                        for pt in contour.normalizedPoints {
                            if pt.y < minNormY {
                                minNormY = pt.y
                            }
                        }
                        // 转换到屏幕/图像像素坐标 (Y轴0在顶部，向下递增)
                        let chinPixelY = (1.0 - (box.origin.y + minNormY * box.size.height)) * height
                        faceMap["chinY"] = chinPixelY
                    }

                    serializedFaces.append(faceMap)
                }

                DispatchQueue.main.async {
                    result(serializedFaces)
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "HandlerError", message: error.localizedDescription, details: nil))
                }
            }
        }
    }

    private func cgImageOrientation(from imageOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
