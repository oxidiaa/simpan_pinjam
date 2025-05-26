import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/anggota_screen.dart';
import '../screens/simpanan_screen.dart';
import '../screens/pinjaman_screen.dart';
import '../screens/transaksi_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/anggota',
      builder: (context, state) => const AnggotaScreen(),
    ),
    GoRoute(
      path: '/simpanan',
      builder: (context, state) => const SimpananScreen(),
    ),
    GoRoute(
      path: '/pinjaman',
      builder: (context, state) => const PinjamanScreen(),
    ),
    GoRoute(
      path: '/transaksi',
      builder: (context, state) => const TransaksiScreen(),
    ),
  ],
);
