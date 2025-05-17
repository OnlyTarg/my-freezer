import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../features/freezer/pages/freezer_list_page.dart';
import '../../features/freezer/pages/freezer_detail_page.dart';
import '../../features/product/pages/product_detail_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../transitions/fade_page_route.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/',
          page: FreezerListRoute.page,
          initial: true,
        ),
        CustomRoute(
          path: '/freezer/:freezerId',
          page: FreezerDetailRoute.page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadePageRoute(
              child: child,
              duration: const Duration(milliseconds: 300),
            ).buildTransitions(context, animation, secondaryAnimation, child);
          },
        ),
        CustomRoute(
          path: '/product/:productId',
          page: ProductDetailRoute.page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadePageRoute(
              child: child,
              duration: const Duration(milliseconds: 300),
            ).buildTransitions(context, animation, secondaryAnimation, child);
          },
        ),
        CustomRoute(
          path: '/settings',
          page: SettingsRoute.page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadePageRoute(
              child: child,
              duration: const Duration(milliseconds: 300),
            ).buildTransitions(context, animation, secondaryAnimation, child);
          },
        ),
      ];
}
