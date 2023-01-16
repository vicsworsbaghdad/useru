import 'dart:convert';
import 'dart:io';

import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

class NotificationService {
  Future<void> sendPushNotifications(String title, String content, {String? image, String? email, String? uid, String? receiverPlayerId}) async {
    Map<String, dynamic> data = {};

    if (email.validate().isNotEmpty) {
      data.putIfAbsent("email", () => email);
    }

    Map req = {
      'headings': {
        'en': '$title @Chat Notification',
      },
      'contents': {
        'en': content,
      },
      'big_picture': image.validate().isNotEmpty ? image.validate() : '',
      'large_icon': image.validate().isNotEmpty ? image.validate() : '',
      'small_icon': appLogo,
      'data': data,
      'android_visibility': 1,
      'app_id': ONESIGNAL_APP_ID,
      'android_channel_id': ONESIGNAL_CHANNEL_ID,
      'include_player_ids': [receiverPlayerId.validate().trim()],
      'android_group': '$APP_NAME',
    };

    log(req);
    var header = {
      HttpHeaders.authorizationHeader: 'Basic $ONESIGNAL_REST_KEY',
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    };

    Response res = await post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      body: jsonEncode(req),
      headers: header,
    );

    log(res.statusCode);
    log(res.body);

    if (res.statusCode.isSuccessful()) {
    } else {
      throw errorSomethingWentWrong;
    }
  }
}
