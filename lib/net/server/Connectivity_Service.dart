import 'dart:async';

import 'package:connectivity/connectivity.dart';

/// WiFi 无线网络
/// Cellular  蜂窝网络
/// Offline  无网络连接
enum ConnectivityStatus {
  WiFi,
  Cellular,
  Offline
}

/// 用法
/// 使用Provider在局部获取网络状态
/// main.dart 中返回包含 ConnectivityStatus 的流
/// 创建 ConnectivityService 实例 并提供 connectionStatusController

class ConnectivityService {
  /// 订阅网络更改回调
  StreamController<ConnectivityStatus> connectionStatusController = StreamController<ConnectivityStatus>();

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      connectionStatusController.add(_getStatusFromResult(result));
    });
  }

  /// 从第三方枚举转换为自定义枚举
  ConnectivityStatus _getStatusFromResult(ConnectivityResult result){
    switch(result){
      case ConnectivityResult.mobile:
        return ConnectivityStatus.Cellular;
      case ConnectivityResult.wifi:
        return ConnectivityStatus.WiFi;
      case ConnectivityResult.none:
        return ConnectivityStatus.Offline;
      default:
        return ConnectivityStatus.Offline;
    }
  }
}

