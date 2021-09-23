library exception_catcher;

import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:package_info/package_info.dart';

class ExceptionCatcher {
  ExceptionCatcher({
    @required this.rootWidget,
    @required this.username,
    @required this.subject,
    @required this.password,
    @required this.recipient,
    @required this.ccRecipients,
    this.sendInDebug = false,
    this.ignoreErrors,
  }) {
    exceptionCatcher();
  }

  final Widget rootWidget;
  final String subject;
  final String username;
  final String password;
  final String recipient;
  final List<String> ccRecipients;
  final bool sendInDebug;
  final List<String> ignoreErrors;

  void exceptionCatcher() async {
    runZonedGuarded(() {
      runApp(rootWidget);
    }, (Object error, StackTrace stack) async {
      if (!ignoreErrors.contains(error.toString().trim())) {
        if (kReleaseMode || sendInDebug) {
          final body = stack.toString().replaceAll('#', '<br>#');
          // ignore: deprecated_member_use
          final smtpServer = gmail(username, password);
          final appInfo = await getAppInfo();
          final deviceInfo = await getDeviceInfo();
          final message = Message()
            ..from = Address(username, subject)
            ..recipients.add(recipient)
            ..ccRecipients.addAll(ccRecipients)
            ..subject = '${error.toString()} ${DateTime.now()}'
            ..html = '''              
              <p>
                ---------------------
                <br>ERROR<br>
                ---------------------
                <br>
                $error
                <br>
              </p>
              <p>
                ---------------------
                <br>STACK<br>
                ---------------------
                $body
                <br>
              </p>
              <p>
                ---------------------
                <br>APP INFO<br>
                ---------------------
                <br>
                $appInfo
              </p>
              <p>
                ---------------------
                <br>DEVICE INFO<br>
                ---------------------
                <br>
                $deviceInfo
              </p>
              ''';
          try {
            final sendReport = await send(message, smtpServer);
            print('Message sent: ${sendReport.toString()}');
          } on MailerException catch (e) {
            print('Message not sent.');
            print(e.message);
          }
        }
      }

      print('========Error=========');
      print(error);
      print('========Stack=========');
      print(stack);
    });
  }

  Future<String> getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '''
    appState: ${kReleaseMode ? 'release' : 'debug'}<br>
    appName: ${packageInfo.appName}<br>
    packageName: ${packageInfo.packageName}<br>
    version: ${packageInfo.version}<br>
    buildNumber: ${packageInfo.buildNumber}<br>
    ''';
  }

  Future<String> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final system = Platform.isIOS ? 'Ios' : 'Android';

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return '''
      name: ${iosInfo.name}<br>
      systemName: ${iosInfo.systemName}<br>
      systemVersion: ${iosInfo.systemVersion}<br>
      model: ${iosInfo.model}<br>
      localizedModel: ${iosInfo.localizedModel}<br>
      identifierForVendor: ${iosInfo.identifierForVendor}<br>
      isPhysicalDevice: ${iosInfo.isPhysicalDevice}<br>
      utsname.sysname: ${iosInfo.utsname.sysname}<br>
      utsname.nodename: ${iosInfo.utsname.nodename}<br>
      utsname.release: ${iosInfo.utsname.release}<br>
      utsname.version: ${iosInfo.utsname.version}<br>
      utsname.machine: ${iosInfo.utsname.machine}<br>
      ''';
    } else {
      final androidInfo = await deviceInfo.androidInfo;
      return '''
      system: $system<br>
      androidId: ${androidInfo.androidId}<br>
      board: ${androidInfo.board}<br>
      bootloader: ${androidInfo.bootloader}<br>
      brand: ${androidInfo.brand}<br>
      device: ${androidInfo.device}<br>
      display: ${androidInfo.display}<br>
      fingerprint: ${androidInfo.fingerprint}<br>
      hardware: ${androidInfo.hardware}<br>
      host: ${androidInfo.host}<br>
      id: ${androidInfo.id}<br>
      manufacturer: ${androidInfo.manufacturer}<br>
      model: ${androidInfo.model}<br>
      product: ${androidInfo.product}<br>
      supported32BitAbis: ${androidInfo.supported32BitAbis}<br>
      supported64BitAbis: ${androidInfo.supported64BitAbis}<br>
      supportedAbis: ${androidInfo.supportedAbis}<br>
      tags: ${androidInfo.tags}<br>
      type: ${androidInfo.type}<br>
      isPhysicalDevice: ${androidInfo.isPhysicalDevice}<br>
      versionSdkInt: ${androidInfo.version.sdkInt}<br>
      versionRelease: ${androidInfo.version.release}<br>
      versionPreviewSdkInt: ${androidInfo.version.previewSdkInt}<br>
      versionIncremental: ${androidInfo.version.incremental}<br>
      versionCodename: ${androidInfo.version.codename}<br>
      versionBaseOS: ${androidInfo.version.baseOS}<br>
      ''';
    }
  }
}
