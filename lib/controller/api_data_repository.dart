import 'package:get/get.dart';

import '../cache_helper.dart';

class ApiDataRepository extends GetxController {
  List floorList = [];
  Map<String, dynamic> room = {};
  Map roomList = {};
  var test;
  late String hosueKeeperName;
  late String password;
  var items;
  List noteList = [];

  late String baseUrl;
  //================== floor =======================
  late String houseKeepers;
  late String floors;
  late String sendMaintenaceNote;
  late String getRooms;
  late String getMaterial;
  late String newBaseUrl;
  late String sendNote;

  changeEndPoint(String newUrl) {
    newBaseUrl = newUrl;
    sendNote = newUrl;
    baseUrl =
        "http://${CacheHelper().getData(key: "qr") != null ? CacheHelper().getData(key: "qr") : newBaseUrl}:3000/api/";
    houseKeepers = "$baseUrl/houseKeepers";
    floors = "$baseUrl/hotel-floors";
    sendMaintenaceNote = "$baseUrl/maintenanceRequest";
    getRooms = "$baseUrl/hotelRooms";
    getMaterial = "$baseUrl/Mats";
  }

  @override
  void onInit() {
    CacheHelper().init();
    changeEndPoint("94.127.214.117");
    super.onInit();
  }
}
