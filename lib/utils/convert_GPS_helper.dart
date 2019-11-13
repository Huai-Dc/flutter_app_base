import 'dart:math';
import 'package:latlong/latlong.dart';

/// @user QingHuai
/// @date 2019-11-12 10:29
/// E-mail 837084459@qq.com

/// 用于不同坐标系之间的经纬度转换
class ConvertGPSHelper {
  static double pi = 3.1415926535897932384626;
  static double a = 6378245.0;
  static double ee = 0.00669342162296594323;
  static double bd_pi = 3.14159265358979324 * 3000.0 / 180.0;

  static bool outOfChina(double lat, double lon){
    if (lon < 72.004 || lon > 137.8347)
      return true;
    if (lat < 0.8293 || lat > 55.8271)
      return true;
    return false;
  }

  static double transformLat(double x, double y){
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y
        + 0.2 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
  }

  static double transformLon(double x, double y) {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1
        * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0
        * pi)) * 2.0 / 3.0;
    return ret;
  }


  /// 84 to 火星坐标系 (GCJ-02) World Geodetic System ==> Mars Geodetic System
  ///
  /// @param lat
  /// @param lon
  /// @return LatLng
  ///
  static LatLng gps84_To_Gcj02(LatLng point){
    if (outOfChina(point.latitude, point.longitude)){
      return new LatLng(0, 0);
    }
    double dLat = transformLat(point.longitude - 105.0, point.latitude - 35.0);
    double dLon = transformLon(point.longitude - 105.0, point.latitude - 35.0);
    double radLat = point.latitude / 180.0 * pi;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
    double mgLat = point.latitude + dLat;
    double mgLon = point.longitude + dLon;
    return new LatLng(mgLat, mgLon);
  }

  static LatLng transform(LatLng point){
    if (outOfChina(point.latitude, point.longitude)){
      return new LatLng(point.latitude, point.longitude);
    }
    double dLat = transformLat(point.longitude - 105.0, point.latitude - 35.0);
    double dLon = transformLon(point.longitude - 105.0, point.latitude - 35.0);
    double radLat = point.latitude / 180.0 * pi;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
    double mgLat = point.latitude + dLat;
    double mgLon = point.longitude + dLon;
    return new LatLng(mgLat, mgLon);
  }

  ///
  /// 火星坐标系 (GCJ-02) to 84 * * @param lon * @param lat * @return
  ///
  static LatLng gcj02_To_Gps84(LatLng point){
    LatLng gps = transform(point);
    double lontitude = point.longitude * 2 - gps.longitude;
    double latitude = point.latitude * 2 - gps.latitude;
    return new LatLng(latitude, lontitude);
  }

  ///
  /// 火星坐标系 (GCJ-02) 与百度坐标系 (BD-09) 的转换算法 将 GCJ-02 坐标转换成 BD-09 坐标
  ///
  /// @param gg_lat
  /// @param gg_lon
  ///
  static LatLng gcj02_To_Bd09(LatLng point) {
    double x = point.longitude, y = point.latitude;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * bd_pi);
    double theta = atan2(y, x) + 0.000003 * cos(x * bd_pi);
    double bd_lon = z * cos(theta) + 0.0065;
    double bd_lat = z * sin(theta) + 0.006;
    return new LatLng(bd_lat, bd_lon);
  }

  ///
  /// 火星坐标系 (GCJ-02) 与百度坐标系 (BD-09) 的转换算法 * * 将 BD-09 坐标转换成GCJ-02 坐标 * * @param
  /// bd_lat * @param bd_lon * @return
  ///
  static LatLng bd09_To_Gcj02(LatLng bdPoint){
    double x = bdPoint.longitude - 0.0065, y = bdPoint.latitude - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * bd_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * bd_pi);
    double gg_lon = z * cos(theta);
    double gg_lat = z * sin(theta);
    return new LatLng(gg_lat, gg_lon);
  }

  ///
  /// (BD-09)-->84
  /// @param bd_lat
  /// @param bd_lon
  /// @return
  ///
  static LatLng bd09_To_Gps84(LatLng bdPoint) {

    LatLng gcj02 = bd09_To_Gcj02(bdPoint);
    LatLng map84 = gcj02_To_Gps84(gcj02);
    return map84;

  }
  ///
  /// 84-->(BD-09)
  /// @param bd_lat
  /// @param bd_lon
  /// @return
  ///
  static LatLng Gps84_To_bd09(LatLng gpsPoint) {

    LatLng gcj02 = gps84_To_Gcj02(gpsPoint);
    LatLng bd09 = gcj02_To_Bd09(gcj02);
    return bd09;

  }
}