import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/join_room/join_room_screen.dart';
import '../../screens/identity_reveal/identity_reveal_screen.dart';
import '../../screens/chat/chat_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/join',
      name: 'join',
      builder: (context, state) => const JoinRoomScreen(),
    ),
    GoRoute(
      path: '/identity/:roomCode',
      name: 'identity',
      builder: (context, state) {
        final roomCode = state.pathParameters['roomCode']!;
        return IdentityRevealScreen(roomCode: roomCode);
      },
    ),
    GoRoute(
      path: '/chat/:roomCode',
      name: 'chat',
      builder: (context, state) {
        final roomCode = state.pathParameters['roomCode']!;
        return ChatScreen(roomCode: roomCode);
      },
    ),
  ],
);
