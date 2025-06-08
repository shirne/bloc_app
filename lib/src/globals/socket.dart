import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:intl/intl.dart';
import 'package:pointycastle/export.dart' hide Mac;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/base.dart';
import '../utils/core.dart';
import '../utils/utils.dart';

const _secLength = 256;
const _macLegth = 16;

enum ChatConnectState {
  initial,
  connecting,
  connected,
  closed;
}

class ConnectionInfo {
  ConnectionInfo({
    required this.ip,
    required this.account,
    required this.password,
    this.sshPort = 22,
  });

  final String ip;
  final String account;
  final String password;
  final int sshPort;
}

/// 删除sftp文件
Future<void> deleteSftpFile(ConnectionInfo info, String file) async {
  SSHClient? client;
  try {
    client = SSHClient(
      await SSHSocket.connect(
        info.ip,
        info.sshPort,
      ),
      username: info.account,
      onPasswordRequest: () => info.password,
      printTrace: (log) {
        logger.info(log);
      },
    );
    final sftp = await client.sftp();
    logger.info('remove file: $file');
    await sftp.remove(file);
  } catch (e) {
    logger.warning(e);
  } finally {
    client?.close();
    await client?.done;
  }
}

/// 上传sftp文件
Future<String?> uploadSftpFile(
  ConnectionInfo info,
  String path,
  File file,
) async {
  final name = Uri.parse(file.path).pathSegments.last;
  final dateStr = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
  final filepath = '$path/$dateStr-$name';
  SSHClient? client;
  try {
    client = SSHClient(
      await SSHSocket.connect(
        info.ip,
        info.sshPort,
      ),
      username: info.account,
      onPasswordRequest: () => info.password,
      printTrace: (log) {
        logger.info(log);
      },
    );
    final sftp = await client.sftp();
    try {
      await sftp.mkdir(path);
    } on SftpStatusError catch (e) {
      logger.warning(e);
    }

    logger.info('上传文件: $filepath');
    final sftpFile = await sftp.open(
      filepath,
      mode: SftpFileOpenMode.create | SftpFileOpenMode.write,
    );

    final stream = file.openRead();

    await sftpFile.write(
      stream.map((ilist) => Uint8List.fromList(ilist)),
      onProgress: (total) {
        logger.info('progress: $total');
      },
    ).done;
    // await file.writeBytes(await file.readBytes());
    await sftpFile.close();
    sftp.close();
  } catch (e) {
    logger.warning(e);
    return null;
  } finally {
    client?.close();
    await client?.done;
  }
  return filepath;
}

/// 会员主机请求封装
class UserSocketManager extends SocketManager {
  UserSocketManager._(
      String server, RSAPublicKey publicKey, RSAPrivateKey privateKey)
      : super._('user', server, publicKey, privateKey);

  static UserSocketManager? _instance;
  static UserSocketManager get instance => _instance!;
  factory UserSocketManager(
    String server,
    RSAPublicKey pub,
    RSAPrivateKey pri,
  ) {
    return _instance ??= UserSocketManager._(server, pub, pri);
  }

  // model 操作
  // Future<AccountLoginResult> login(AccountLoginModel model) async {
  //   final result = await sendMessage(SocketMessage.login(model));
  //   result['data']['AC'] = model.account;
  //   return AccountLoginResult.fromJson(result['data']);
  // }

  // Future<SocketResult> open(AppOpenModel model) async {
  //   final result = await sendMessage(SocketMessage.open(model));
  //   return SocketResult.fromJson(result['data']);
  // }

  // Future<SocketResult> interval(AppIntervalModel model) async {
  //   final result = await sendMessage(SocketMessage.interval(model));
  //   return SocketResult.fromJson(result['data']);
  // }
}

class SocketManager {
  static late final UserSocketManager user;

  static void init(
    String server,
    String dbServer,
    RSAPublicKey publicKey,
    RSAPrivateKey privateKey,
  ) {
    user = UserSocketManager(server, publicKey, privateKey);
  }

  SocketManager._(this.flag, this.server, this.publicKey, this.privateKey);

  final String flag;
  final String server;
  final RSAPublicKey publicKey;
  final RSAPrivateKey privateKey;

  Duration timeout = const Duration(seconds: 3);

  WebSocketChannel? _channel;

  WebSocketChannel get channel => _channel!;

  ChatConnectState _state = ChatConnectState.initial;

  var _messageFuture = Completer<Map<String, dynamic>>();

  Completer<bool>? connecting;

  final heartMsg = 'hello';

  Future<bool> connect() async {
    if (_state == ChatConnectState.connected) {
      return true;
    }
    if (_state == ChatConnectState.connecting && _channel != null) {
      return connecting!.future;
    }

    // 设置为链接状态
    _changeState(ChatConnectState.connecting);
    connecting = Completer();
    try {
      isError = false;
      _channel = WebSocketChannel.connect(Uri.parse(server));
      channel.stream.listen(
        (message) {
          _changeState(ChatConnectState.connected);

          if (message is String) {
            logger.info('[$flag]receive message: $message');
            if (message == heartMsg && connecting?.isCompleted == false) {
              connecting?.complete(true);
            }
            return;
          }
          _handleMessage(message);
        },
        onDone: _onDone,
        onError: _onError,
      );

      logger.info('[$flag]send heart_beat: $heartMsg');
      channel.sink.add(heartMsg);

      return Future.any([
        channel.sink.done.then<bool>((_) => true),
        connecting!.future,
      ]).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (connecting?.isCompleted == false) connecting?.complete(false);
          return false;
        },
      );
    } catch (e) {
      logger.warning(e);
      isError = true;
      if (connecting?.isCompleted == false) connecting?.complete(false);
    }
    return true;
  }

  Future<void> close() async {
    await channel.sink.close();
  }

  Completer<bool>? returned;

  // 发送消息
  Future<Map<String, dynamic>> sendMessage(
    SocketMessage sendMsgModel, [
    Duration? timeout,
  ]) async {
    if (returned != null) {
      await returned!.future;
      // 重新回到任务竞争队列
      return sendMessage(sendMsgModel, timeout);
    }
    returned = Completer();

    _messageFuture = Completer();
    try {
      final message = sendMsgModel.toString();
      final binmsg = await encrypt(message);

      if (_state != ChatConnectState.connected &&
          _state != ChatConnectState.connecting) {
        logger.info('[$flag]waiting for connect');
        await connect();
      }

      logger.info('[$flag]send: $message');
      channel.sink.add(binmsg);
    } catch (e) {
      logger.warning(e);
      return {
        'success': false,
        'message': 'Request Error',
      };
    }
    Map<String, dynamic>? result;
    try {
      result = await Future.any<Map<String, dynamic>>([
        _messageFuture.future,
        Future.delayed(
          timeout ?? this.timeout,
          () {
            close();

            return {
              'success': false,
              'message': 'Request Timeout',
            };
          },
        ),
      ]);
    } catch (e) {
      logger.warning('$e');
      rethrow;
    } finally {
      if (returned != null) {
        if (!returned!.isCompleted) returned!.complete(true);
        returned = null;
      }
    }

    return result;
  }

  Future<void> _handleMessage(Uint8List message) async {
    _changeState(ChatConnectState.connected);
    //logger.info("receive message: $message");
    try {
      final data = await decrypt(message);
      final model = jsonDecode(data);
      logger.info('[$flag]receive: $model');
      if (model is Json) {
        if (model['rule'] == 'error') {
          if (!_messageFuture.isCompleted) {
            _messageFuture.completeError(
              Exception(model['data']?['error_msg'] ?? '$model'),
            );
          }
        } else {
          _messageFuture.complete(model);
        }
      } else {
        logger.warning(
          '[$flag]_messageFuture has been completed',
          null,
          StackTrace.current.cast(5),
        );
      }
    } catch (e) {
      logger.warning(
        '[$flag]unable to decrypt message($e): $message',
        null,
        StackTrace.current.cast(5),
      );
    }
  }

  void _changeState(ChatConnectState state) {
    _state = state;
  }

  void _onDone() {
    logger.info('[$flag] _onDone.');
    _changeState(ChatConnectState.closed);
  }

  bool isError = false;
  int retryTime = 0;

  // 断线重连入口
  void _onError(Exception err) {
    logger.info('[$flag] _onError.');
    _changeState(ChatConnectState.closed);
    isError = true;

    if (_messageFuture.isCompleted == false) {
      _messageFuture.completeError(Exception('Connect Error'));
    }
  }

  Uint8List getRandomAesKey2(int length) {
    final random = Random();
    final result = Uint8List(length);
    for (int i = 0; i < length; i++) {
      result[i] = random.nextInt(89) + 33;
    }
    return result;
  }

  Uint8List parseData(String hexString) {
    final data = Uint8List(hexString.length ~/ 2);
    for (int i = 0; i < data.length; i++) {
      data[i] = int.parse(hexString[i * 2] + hexString[i * 2 + 1], radix: 16);
    }
    return data;
  }

  /// TODO 实现自己的加密方式
  Future<Uint8List> encrypt(String data) async {
    final message = utf8.encode(data);
    final sessionKey = getRandomAesKey2(16);
    final nonce = getRandomAesKey2(16);
    final cipherAES = EAX(AESEngine())
      ..init(
        true,
        AEADParameters(KeyParameter(sessionKey), 128, nonce, Uint8List(0)),
      );

    final encryptor = OAEPEncoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    final encSessionKey = encryptor.process(sessionKey);
    final preLen = encSessionKey.length + nonce.length + cipherAES.macSize;
    final result = Uint8List(message.length + preLen);
    result.setRange(0, encSessionKey.length, encSessionKey);
    result.setRange(
        encSessionKey.length, encSessionKey.length + nonce.length, nonce);

    cipherAES.processBytes(message, 0, message.length, result, preLen);
    final mac = Uint8List(cipherAES.macSize);
    cipherAES.doFinal(mac, 0);

    result.setRange(preLen - cipherAES.macSize, preLen, mac);
    return result;
  }

  /// TODO 实现自己的解密方式
  Future<String> decrypt(Uint8List data) async {
    // Encrypt
    final encSecretKey = data.sublist(0, _secLength);

    final encryptor = OAEPEncoding(RSAEngine());
    encryptor.init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    final sessionKey = encryptor.process(encSecretKey);

    final nonce = data.sublist(_secLength, _secLength + _macLegth);
    final tag =
        data.sublist(_secLength + _macLegth, _secLength + _macLegth * 2);
    final aes = EAX(AESEngine())
      ..init(
        false,
        AEADParameters(KeyParameter(sessionKey), 128, nonce, Uint8List(0)),
      );
    final length = data.length - _secLength - _macLegth * 2;
    final newData = Uint8List(length + _macLegth);
    newData.setRange(0, length, data.sublist(_secLength + _macLegth * 2));
    newData.setRange(length, length + _macLegth, tag);
    final result = Uint8List(length + _macLegth);
    aes.processBytes(newData, 0, length + _macLegth, result, 0);

    aes.doFinal(tag, 0);

    return utf8.decode(result.sublist(0, length), allowMalformed: true);
  }
}
