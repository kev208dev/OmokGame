import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_service.dart';

/// Socket.IO 실시간 통신 래퍼.
/// 명세서 이벤트: request_match/match_complete, join/joined,
/// chaksoo/chaksooed, game_over, resign/resigned
class SocketService {
  static final SocketService instance = SocketService._();
  SocketService._();

  io.Socket? _socket;
  io.Socket? get socket => _socket;
  bool get isConnected => _socket?.connected ?? false;

  /// accessToken 으로 인증해 연결. 이미 연결돼 있으면 재사용.
  void connect({void Function()? onConnect, void Function(dynamic)? onError}) {
    if (_socket != null) {
      if (!_socket!.connected) _socket!.connect();
      return;
    }
    _socket = io.io(
      ApiService.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': ApiService.accessToken})
          .build(),
    );
    _socket!.onConnect((_) => onConnect?.call());
    _socket!.onConnectError((e) => onError?.call(e));
    _socket!.connect();
  }

  /// 매칭 요청. 성공 시 onMatch 로 match_complete payload 전달.
  void requestMatch(void Function(dynamic data) onMatch) {
    _socket?.off('match_complete');
    _socket?.on('match_complete', onMatch);
    _socket?.emit('request_match');
  }

  /// 방 입장. joined 이벤트로 내 돌 색(color) 전달.
  void join(String roomId, void Function(dynamic data) onJoined) {
    _socket?.off('joined');
    _socket?.on('joined', onJoined);
    _socket?.emit('join', {'roomid': roomId});
  }

  /// 착수. chaksooed 이벤트로 상대/내 착수 좌표 수신.
  void chaksoo(String roomId, int x, int y, String color) {
    _socket?.emit('chaksoo', {
      'roomid': roomId,
      'x': x,
      'y': y,
      'color': color,
    });
  }

  void onChaksooed(void Function(dynamic data) cb) {
    _socket?.off('chaksooed');
    _socket?.on('chaksooed', cb);
  }

  void onGameOver(void Function(dynamic data) cb) {
    _socket?.off('game_over');
    _socket?.on('game_over', cb);
  }

  /// 기권. resigned 이벤트로 결과(result) 수신.
  void resign(String roomId, String color) {
    _socket?.emit('resign', {'roomid': roomId, 'color': color});
  }

  void onResigned(void Function(dynamic data) cb) {
    _socket?.off('resigned');
    _socket?.on('resigned', cb);
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
