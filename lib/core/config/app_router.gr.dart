// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    FreezerDetailRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<FreezerDetailRouteArgs>(
          orElse: () => FreezerDetailRouteArgs(
              freezerId: pathParams.getInt('freezerId')));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FreezerDetailPage(
          freezerId: args.freezerId,
          key: args.key,
        ),
      );
    },
    FreezerListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FreezerListPage(),
      );
    },
    PrivacyPolicyRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PrivacyPolicyPage(),
      );
    },
    ProductDetailRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProductDetailPage(),
      );
    },
    SettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SettingsPage(),
      );
    },
  };
}

/// generated route for
/// [FreezerDetailPage]
class FreezerDetailRoute extends PageRouteInfo<FreezerDetailRouteArgs> {
  FreezerDetailRoute({
    required int freezerId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          FreezerDetailRoute.name,
          args: FreezerDetailRouteArgs(
            freezerId: freezerId,
            key: key,
          ),
          rawPathParams: {'freezerId': freezerId},
          initialChildren: children,
        );

  static const String name = 'FreezerDetailRoute';

  static const PageInfo<FreezerDetailRouteArgs> page =
      PageInfo<FreezerDetailRouteArgs>(name);
}

class FreezerDetailRouteArgs {
  const FreezerDetailRouteArgs({
    required this.freezerId,
    this.key,
  });

  final int freezerId;

  final Key? key;

  @override
  String toString() {
    return 'FreezerDetailRouteArgs{freezerId: $freezerId, key: $key}';
  }
}

/// generated route for
/// [FreezerListPage]
class FreezerListRoute extends PageRouteInfo<void> {
  const FreezerListRoute({List<PageRouteInfo>? children})
      : super(
          FreezerListRoute.name,
          initialChildren: children,
        );

  static const String name = 'FreezerListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PrivacyPolicyPage]
class PrivacyPolicyRoute extends PageRouteInfo<void> {
  const PrivacyPolicyRoute({List<PageRouteInfo>? children})
      : super(
          PrivacyPolicyRoute.name,
          initialChildren: children,
        );

  static const String name = 'PrivacyPolicyRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProductDetailPage]
class ProductDetailRoute extends PageRouteInfo<void> {
  const ProductDetailRoute({List<PageRouteInfo>? children})
      : super(
          ProductDetailRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProductDetailRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
