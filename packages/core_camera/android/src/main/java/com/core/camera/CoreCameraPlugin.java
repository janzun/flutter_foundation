package com.core.camera;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.core.camera.analyzer.MlKitFaceAnalyzer;
import com.core.camera.analyzer.NativeFrameAnalyzer;
import com.google.mlkit.vision.common.InputImage;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.io.File;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * CoreCamera Flutter 插件主入口。
 */
public class CoreCameraPlugin
    implements FlutterPlugin,
        ActivityAware,
        MethodChannel.MethodCallHandler,
        EventChannel.StreamHandler {

  private static final String METHOD_CHANNEL_NAME = "com.core.camera/methods";
  private static final String ANALYSIS_EVENT_CHANNEL_NAME = "com.core.camera/analysis_events";

  @Nullable private Context applicationContext;
  @Nullable private MethodChannel methodChannel;
  @Nullable private EventChannel analysisEventChannel;
  @Nullable private EventChannel.EventSink analysisEventSink;
  @Nullable private CameraXEngine engine;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    this.applicationContext = binding.getApplicationContext();
    engine = new CameraXEngine(applicationContext, binding.getTextureRegistry());
    engine.setAnalysisResultListener(
        new NativeFrameAnalyzer.ResultCallback() {
          @Override
          public void onAnalysisResult(@NonNull Map<String, Object> resultData) {
            if (analysisEventSink != null) {
              analysisEventSink.success(resultData);
            }
          }

          @Override
          public void onFaceCenterForAutoFocus(float normX, float normY) {
            // Handled inside CameraXEngine
          }
        });

    methodChannel = new MethodChannel(binding.getBinaryMessenger(), METHOD_CHANNEL_NAME);
    methodChannel.setMethodCallHandler(this);

    analysisEventChannel =
        new EventChannel(binding.getBinaryMessenger(), ANALYSIS_EVENT_CHANNEL_NAME);
    analysisEventChannel.setStreamHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (methodChannel != null) {
      methodChannel.setMethodCallHandler(null);
      methodChannel = null;
    }
    if (analysisEventChannel != null) {
      analysisEventChannel.setStreamHandler(null);
      analysisEventChannel = null;
    }
    if (engine != null) {
      engine.shutdownExecutors();
      engine = null;
    }
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    if (engine != null) {
      engine.setActivity(binding.getActivity());
    }
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    if (engine != null) {
      engine.setActivity(null);
    }
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    if (engine != null) {
      engine.setActivity(binding.getActivity());
    }
  }

  @Override
  public void onDetachedFromActivity() {
    if (engine != null) {
      engine.setActivity(null);
    }
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    this.analysisEventSink = events;
  }

  @Override
  public void onCancel(Object arguments) {
    this.analysisEventSink = null;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    if ("detectFacesFromFile".equals(call.method)) {
      handleDetectFacesFromFile(call, result);
      return;
    }
    if ("detectFacesFromBytes".equals(call.method)) {
      handleDetectFacesFromBytes(call, result);
      return;
    }

    if (engine == null) {
      result.error("EngineNull", "CameraXEngine is not attached", null);
      return;
    }

    switch (call.method) {
      case "availableCameras":
        engine.getAvailableCameras(result);
        break;

      case "initialize":
        {
          String cameraName = call.argument("cameraName");
          String lensDirection = call.argument("lensDirection");
          String aspectRatio = call.argument("aspectRatio");
          String analyzerMode = call.argument("analyzerMode");
          Boolean enableFaceAutoFocus = call.argument("enableFaceAutoFocus");
          engine.initialize(
              cameraName != null ? cameraName : "0",
              lensDirection != null ? lensDirection : "back",
              aspectRatio != null ? aspectRatio : "4:3",
              analyzerMode != null ? analyzerMode : "faceDetection",
              enableFaceAutoFocus == null || enableFaceAutoFocus,
              result);
          break;
        }

      case "takePicture":
        engine.takePicture(result);
        break;

      case "setFocusAndExposurePoint":
        {
          Double x = call.argument("x");
          Double y = call.argument("y");
          if (x != null && y != null) {
            engine.setFocusAndExposurePoint(x.floatValue(), y.floatValue());
          }
          result.success(null);
          break;
        }

      case "setFlashMode":
        {
          String flashMode = call.argument("flashMode");
          if (flashMode != null) {
            engine.setFlashMode(flashMode);
          }
          result.success(null);
          break;
        }

      case "setZoomLevel":
        {
          Double zoom = call.argument("zoom");
          if (zoom != null) {
            engine.setZoomLevel(zoom.floatValue());
          }
          result.success(null);
          break;
        }

      case "setAnalysisPaused":
        {
          Boolean paused = call.argument("paused");
          engine.setAnalysisPaused(paused != null && paused);
          result.success(null);
          break;
        }

      case "setAnalyzerMode":
        {
          String mode = call.argument("analyzerMode");
          engine.setAnalysisPaused("none".equalsIgnoreCase(mode));
          result.success(null);
          break;
        }

      case "dispose":
        engine.dispose();
        result.success(null);
        break;

      default:
        result.notImplemented();
        break;
    }
  }

  private void handleDetectFacesFromFile(
      @NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    String filePath = call.argument("filePath");
    if (filePath == null || filePath.isEmpty()) {
      result.error("InvalidPath", "filePath is required", null);
      return;
    }
    File file = new File(filePath);
    if (!file.exists()) {
      result.error("FileNotFound", "File does not exist: " + filePath, null);
      return;
    }

    try {
      InputImage image =
          applicationContext != null
              ? InputImage.fromFilePath(applicationContext, Uri.fromFile(file))
              : InputImage.fromBitmap(BitmapFactory.decodeFile(filePath), 0);

      MlKitFaceAnalyzer.detectFacesFromImage(
          image,
          image.getWidth(),
          image.getHeight(),
          new MlKitFaceAnalyzer.StaticAnalysisCallback() {
            @Override
            public void onSuccess(@NonNull List<Map<String, Object>> faces) {
              result.success(faces);
            }

            @Override
            public void onError(@NonNull Throwable error) {
              result.error("AnalysisFailed", error.getMessage(), null);
            }
          });
    } catch (Exception e) {
      result.error("ImageLoadFailed", "Failed to load image: " + e.getMessage(), null);
    }
  }

  private void handleDetectFacesFromBytes(
      @NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    byte[] bytes = call.argument("bytes");
    if (bytes == null || bytes.length == 0) {
      result.error("InvalidBytes", "bytes parameter is required", null);
      return;
    }

    try {
      Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
      if (bitmap == null) {
        result.error("DecodeFailed", "Could not decode byte array into Bitmap", null);
        return;
      }

      InputImage image = InputImage.fromBitmap(bitmap, 0);
      MlKitFaceAnalyzer.detectFacesFromImage(
          image,
          image.getWidth(),
          image.getHeight(),
          new MlKitFaceAnalyzer.StaticAnalysisCallback() {
            @Override
            public void onSuccess(@NonNull List<Map<String, Object>> faces) {
              result.success(faces);
            }

            @Override
            public void onError(@NonNull Throwable error) {
              result.error("AnalysisFailed", error.getMessage(), null);
            }
          });
    } catch (Exception e) {
      result.error("AnalysisError", e.getMessage(), null);
    }
  }
}
