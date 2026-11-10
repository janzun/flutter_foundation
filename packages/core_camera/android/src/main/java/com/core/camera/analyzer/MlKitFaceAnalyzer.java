package com.core.camera.analyzer;

import android.graphics.Rect;
import android.media.Image;
import android.os.SystemClock;
import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.camera.core.ExperimentalGetImage;
import androidx.camera.core.ImageProxy;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.face.Face;
import com.google.mlkit.vision.face.FaceContour;
import com.google.mlkit.vision.face.FaceDetection;
import com.google.mlkit.vision.face.FaceDetector;
import com.google.mlkit.vision.face.FaceDetectorOptions;
import com.google.mlkit.vision.face.FaceLandmark;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * 基于 Google ML Kit 的硬件零拷贝人脸与环境光分析器。
 *
 * <p>核心性能优势：
 * 1. 非采样帧在 0.01ms 内直接调用 imageProxy.close() 归还硬件缓冲，0 像素访问。
 * 2. 采样帧直接通过 InputImage.fromMediaImage() 读取硬件 YUV_420_888 指针，0 byte[] 分配、0 NV21 转换。
 * 3. 在原生后台线程完成推理，仅将几十字节的结构化数据回传给 Flutter。
 */
public class MlKitFaceAnalyzer implements NativeFrameAnalyzer {
  private static final long THROTTLE_INTERVAL_MS = 140L; // 约 7 FPS 丝滑实时检测

  private static FaceDetector staticDetector;

  private final FaceDetector faceDetector;
  private final AtomicBoolean isProcessing = new AtomicBoolean(false);
  private volatile boolean isPaused = false;
  private volatile boolean isClosed = false;
  private long lastAnalyzeTimeMs = 0L;

  private static synchronized FaceDetector getStaticFaceDetector() {
    if (staticDetector == null) {
      FaceDetectorOptions options =
          new FaceDetectorOptions.Builder()
              .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE)
              .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_ALL)
              .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_ALL)
              .setContourMode(FaceDetectorOptions.CONTOUR_MODE_ALL)
              .setMinFaceSize(0.10f)
              .build();
      staticDetector = FaceDetection.getClient(options);
    }
    return staticDetector;
  }

  public static void detectFacesFromImage(
      @NonNull InputImage image,
      final int imageWidth,
      final int imageHeight,
      @NonNull final StaticAnalysisCallback callback) {
    FaceDetector detector = getStaticFaceDetector();
    detector
        .process(image)
        .addOnSuccessListener(
            faces -> {
              List<Map<String, Object>> serializedFaces = new ArrayList<>(faces.size());
              for (Face face : faces) {
                Rect box = face.getBoundingBox();
                Map<String, Object> faceMap = new HashMap<>(14);
                faceMap.put("left", (double) box.left);
                faceMap.put("top", (double) box.top);
                faceMap.put("right", (double) box.right);
                faceMap.put("bottom", (double) box.bottom);
                faceMap.put("headEulerAngleX", (double) face.getHeadEulerAngleX());
                faceMap.put("headEulerAngleY", (double) face.getHeadEulerAngleY());
                faceMap.put("headEulerAngleZ", (double) face.getHeadEulerAngleZ());
                if (face.getLeftEyeOpenProbability() != null) {
                  faceMap.put("leftEyeOpenProbability", (double) face.getLeftEyeOpenProbability());
                }
                if (face.getRightEyeOpenProbability() != null) {
                  faceMap.put("rightEyeOpenProbability", (double) face.getRightEyeOpenProbability());
                }
                if (face.getSmilingProbability() != null) {
                  faceMap.put("smilingProbability", (double) face.getSmilingProbability());
                }
                if (face.getTrackingId() != null) {
                  faceMap.put("trackingId", face.getTrackingId());
                }

                // 提取双眼精准物理关键点
                FaceLandmark leftEye = face.getLandmark(FaceLandmark.LEFT_EYE);
                FaceLandmark rightEye = face.getLandmark(FaceLandmark.RIGHT_EYE);
                if (leftEye != null && rightEye != null) {
                  double eyeY = (leftEye.getPosition().y + rightEye.getPosition().y) / 2.0;
                  faceMap.put("eyeY", eyeY);
                  faceMap.put("leftEyeX", (double) leftEye.getPosition().x);
                  faceMap.put("leftEyeY", (double) leftEye.getPosition().y);
                  faceMap.put("rightEyeX", (double) rightEye.getPosition().x);
                  faceMap.put("rightEyeY", (double) rightEye.getPosition().y);
                }

                // 提取精准下巴轮廓尖端 (Chin Tip)，绝不用粗糙的外接框 box.bottom
                FaceContour faceContour = face.getContour(FaceContour.FACE);
                if (faceContour != null && !faceContour.getPoints().isEmpty()) {
                  double maxChinY = 0.0;
                  for (android.graphics.PointF pt : faceContour.getPoints()) {
                    if (pt.y > maxChinY) {
                      maxChinY = pt.y;
                    }
                  }
                  if (maxChinY > 0) {
                    faceMap.put("chinY", maxChinY);
                  }
                }

                serializedFaces.add(faceMap);
              }
              callback.onSuccess(serializedFaces);
            })
        .addOnFailureListener(callback::onError);
  }

  public interface StaticAnalysisCallback {
    void onSuccess(@NonNull List<Map<String, Object>> faces);
    void onError(@NonNull Throwable error);
  }

  public MlKitFaceAnalyzer() {
    FaceDetectorOptions options =
        new FaceDetectorOptions.Builder()
            .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_FAST)
            .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_ALL)
            .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_NONE)
            .setContourMode(FaceDetectorOptions.CONTOUR_MODE_NONE)
            .setMinFaceSize(0.15f)
            .build();
    this.faceDetector = FaceDetection.getClient(options);
  }

  @Override
  @OptIn(markerClass = ExperimentalGetImage.class)
  public void analyze(@NonNull ImageProxy imageProxy, @NonNull ResultCallback callback) {
    if (isClosed || isPaused) {
      imageProxy.close();
      return;
    }

    final long now = SystemClock.elapsedRealtime();
    if (now - lastAnalyzeTimeMs < THROTTLE_INTERVAL_MS || !isProcessing.compareAndSet(false, true)) {
      imageProxy.close();
      return;
    }

    final Image mediaImage = imageProxy.getImage();
    if (mediaImage == null) {
      isProcessing.set(false);
      imageProxy.close();
      return;
    }

    lastAnalyzeTimeMs = now;
    final int rotation = imageProxy.getImageInfo().getRotationDegrees();
    final int rawWidth = imageProxy.getWidth();
    final int rawHeight = imageProxy.getHeight();
    final boolean isRotated = (rotation == 90 || rotation == 270);
    final int uprightWidth = isRotated ? rawHeight : rawWidth;
    final int uprightHeight = isRotated ? rawWidth : rawHeight;

    // 1. 顺便从 Y 平面极速采样 64 个点计算环境平均亮度 (< 0.02ms)
    final double avgLuminance = sampleAmbientLuminance(imageProxy);
    final boolean isAmbientDark = avgLuminance < 72.0;

    // 2. 硬件零拷贝构建 InputImage
    final InputImage inputImage;
    try {
      inputImage = InputImage.fromMediaImage(mediaImage, rotation);
    } catch (Exception e) {
      isProcessing.set(false);
      imageProxy.close();
      return;
    }

    faceDetector
        .process(inputImage)
        .addOnSuccessListener(
            faces -> {
              if (isClosed) return;

              List<Map<String, Object>> serializedFaces = new ArrayList<>(faces.size());
              Face largestFace = null;
              int maxArea = 0;

              for (Face face : faces) {
                Rect box = face.getBoundingBox();
                int area = box.width() * box.height();
                if (area > maxArea) {
                  maxArea = area;
                  largestFace = face;
                }

                Map<String, Object> faceMap = new HashMap<>(10);
                faceMap.put("left", (double) box.left);
                faceMap.put("top", (double) box.top);
                faceMap.put("right", (double) box.right);
                faceMap.put("bottom", (double) box.bottom);
                faceMap.put("headEulerAngleX", (double) face.getHeadEulerAngleX());
                faceMap.put("headEulerAngleY", (double) face.getHeadEulerAngleY());
                faceMap.put("headEulerAngleZ", (double) face.getHeadEulerAngleZ());
                if (face.getLeftEyeOpenProbability() != null) {
                  faceMap.put("leftEyeOpenProbability", (double) face.getLeftEyeOpenProbability());
                }
                if (face.getRightEyeOpenProbability() != null) {
                  faceMap.put(
                      "rightEyeOpenProbability", (double) face.getRightEyeOpenProbability());
                }
                if (face.getSmilingProbability() != null) {
                  faceMap.put("smilingProbability", (double) face.getSmilingProbability());
                }
                if (face.getTrackingId() != null) {
                  faceMap.put("trackingId", face.getTrackingId());
                }
                serializedFaces.add(faceMap);
              }

              // 触发智能人脸中心自动追焦与测光
              if (largestFace != null && uprightWidth > 0 && uprightHeight > 0) {
                Rect box = largestFace.getBoundingBox();
                float normX = Math.max(0.1f, Math.min(0.9f, box.exactCenterX() / uprightWidth));
                float normY = Math.max(0.1f, Math.min(0.9f, box.exactCenterY() / uprightHeight));
                callback.onFaceCenterForAutoFocus(normX, normY);
              }

              Map<String, Object> payload = new HashMap<>(6);
              payload.put("frameWidth", (double) uprightWidth);
              payload.put("frameHeight", (double) uprightHeight);
              payload.put("isAmbientDark", isAmbientDark);
              payload.put("ambientLuminance", avgLuminance);
              payload.put("faces", serializedFaces);

              callback.onAnalysisResult(payload);
            })
        .addOnCompleteListener(
            task -> {
              isProcessing.set(false);
              imageProxy.close();
            });
  }

  private double sampleAmbientLuminance(@NonNull ImageProxy imageProxy) {
    try {
      ImageProxy.PlaneProxy[] planes = imageProxy.getPlanes();
      if (planes.length == 0) return 128.0;
      ByteBuffer yBuffer = planes[0].getBuffer();
      int limit = yBuffer.limit();
      if (limit <= 0) return 128.0;

      int step = Math.max(1, limit / 64);
      long sum = 0;
      int count = 0;
      for (int i = 0; i < limit; i += step) {
        sum += (yBuffer.get(i) & 0xFF);
        count++;
      }
      return count > 0 ? (double) sum / count : 128.0;
    } catch (Exception e) {
      return 128.0;
    }
  }

  @Override
  public void setPaused(boolean paused) {
    this.isPaused = paused;
  }

  @Override
  public void close() {
    isClosed = true;
    try {
      faceDetector.close();
    } catch (Exception ignored) {
    }
  }
}
