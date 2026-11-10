package com.core.camera.analyzer;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageProxy;
import java.util.Map;

/**
 * 可插拔原生零拷贝帧分析器统一接口（支持未来扩展 OCR、扫码、文档检测、姿态识别等）。
 */
public interface NativeFrameAnalyzer {

  interface ResultCallback {
    void onAnalysisResult(@NonNull Map<String, Object> resultData);

    void onFaceCenterForAutoFocus(float normX, float normY);
  }

  /**
   * 处理 CameraX ImageAnalysis 帧（实现方需负责调用 imageProxy.close()）。
   */
  void analyze(@NonNull ImageProxy imageProxy, @NonNull ResultCallback callback);

  /**
   * 暂停或恢复分析。
   */
  void setPaused(boolean paused);

  /**
   * 释放底层检测器资源。
   */
  void close();
}
