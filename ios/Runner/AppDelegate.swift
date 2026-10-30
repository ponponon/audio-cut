import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "cn.quniv.audio_cut.DeviceSaver"
    ) {
      DeviceSaverPlugin.register(with: registrar)
    }
  }
}

/// Saves exported audio into Documents/AudioCut so it is visible in the Files app.
class DeviceSaverPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "cn.quniv.audio_cut/device_saver",
      binaryMessenger: registrar.messenger()
    )
    let instance = DeviceSaverPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "saveAudio" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard
      let args = call.arguments as? [String: Any],
      let sourcePath = args["sourcePath"] as? String,
      let fileName = args["fileName"] as? String
    else {
      result(
        FlutterError(
          code: "bad_args", message: "sourcePath and fileName are required", details: nil))
      return
    }
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: sourcePath) else {
      result(
        FlutterError(code: "missing_source", message: "Exported audio file was not found.", details: nil))
      return
    }
    let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let directory = documents.appendingPathComponent("AudioCut", isDirectory: true)
    do {
      try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
      let target = uniqueURL(for: directory.appendingPathComponent(fileName), in: directory)
      try fileManager.copyItem(atPath: sourcePath, toPath: target.path)
      result(["displayPath": "AudioCut/\(target.lastPathComponent)"])
    } catch {
      result(
        FlutterError(code: "save_failed", message: error.localizedDescription, details: nil))
    }
  }

  private func uniqueURL(for preferred: URL, in directory: URL) -> URL {
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: preferred.path) {
      return preferred
    }
    let base = preferred.deletingPathExtension().lastPathComponent
    let fileExtension = preferred.pathExtension
    var index = 1
    while true {
      let candidateName =
        fileExtension.isEmpty ? "\(base) (\(index))" : "\(base) (\(index)).\(fileExtension)"
      let candidate = directory.appendingPathComponent(candidateName)
      if !fileManager.fileExists(atPath: candidate.path) {
        return candidate
      }
      index += 1
    }
  }
}
