import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_service.dart';

class SocketService {
  static final SocketService instance = SocketService();

  io.Socket? socket;
  bool get isConnected => socket?.connected ?? false;

  void connect({void Function()? onConnect, void Function(dynamic)? onError}) {
    if (socket != null) {
      if (!socket!.connected) socket!.connect();
      return;
    }
    socket = io.io(
      ApiService.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': ApiService.accessToken})
          .build(),
    );
    socket!.onConnect((_) => onConnect?.call());
    socket!.onConnectError((e) => onError?.call(e));
    socket!.connect();
  }

  void requestMatch(void Function(dynamic data) onMatch) {
    socket?.off('match_complete');
    socket?.on('match_complete', onMatch);
    socket?.emit('request_match');
  }

  void join(String roomId, void Function(dynamic data) onJoined) {
    socket?.off('joined');
    socket?.on('joined', onJoined);
    socket?.emit('join', {'roomid': roomId});
  }

  void chaksoo(String roomId, int x, int y, String color) {
    socket?.emit('chaksoo', {
      'roomid': roomId,
      'x': x,
      'y': y,
      'color': color,
    });
  }

  void onChaksooed(void Function(dynamic data) cb) {
    socket?.off('chaksooed');
    socket?.on('chaksooed', cb);
  }

  void onGameOver(void Function(dynamic data) cb) {
    socket?.off('game_over');
    socket?.on('game_over', cb);
  }

  void resign(String roomId, String color) {
    socket?.emit('resign', {'roomid': roomId, 'color': color});
  }

  void onResigned(void Function(dynamic data) cb) {
    socket?.off('resigned');
    socket?.on('resigned', cb);
  }

  void dispose() {
    socket?.dispose();
    socket = null;
  }
}
