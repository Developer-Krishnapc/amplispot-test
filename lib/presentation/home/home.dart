import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';

import '../../core/extension/widget.dart';
import '../../core/utils/app_utils.dart';
import '../../domain/model/load_error_state.dart';
import '../shared/components/app_text_theme.dart';
import '../shared/components/custom_filled_button.dart';
import '../shared/providers/app_content.dart';
import '../theme/config/app_color.dart';
import 'provider/custom_editor_notifier.dart';

@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  ProviderSubscription? _customWidgetSubscription;
  final imageKey = GlobalKey();
  late double imageHeight;
  late double imageWidth;
  @override
  void initState() {
    _customWidgetSubscription = ref.listenManual<LoadErrorState<List<Widget>>>(
        customWidgetListNotifierProvider, (previous, next) {
      if (next.error != '' && ModalRoute.of(context)?.isCurrent == true) {
        AppUtils.flushBar(context, next.error, isSuccessPopup: false);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _customWidgetSubscription?.close();
    super.dispose();
  }

//
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customWidgetListNotifierProvider);
    final notifier = ref.read(customWidgetListNotifierProvider.notifier);
    final appContent = ref.watch(appContentProvider);

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Test App',
            style: AppTextTheme.semiBold14,
          ),
        ),
        backgroundColor: AppColor.lightBackground,
        bottomNavigationBar: CustomFilledButton(
          isLoading: state.loading,
          title: state.data.isEmpty ? 'Customize' : 'Save',
          onTap: () async {
            if (state.data.isEmpty) {
              final data = notifier.fetchData(context: context);
              if (data) {
                AppUtils.flushBar(
                  context,
                  'Details fetched and applied on image',
                );
              }
            } else {
              final data = await notifier.saveImage();
              if (data) {
                AppUtils.flushBar(
                  context,
                  'Image save to gallery successfully',
                );
              }
            }
          },
        ).padSymm(hor: 10, ver: 8),
        body: Center(
          child: Screenshot(
            controller: notifier.screenshotCtrl,
            child: Stack(
              children: [
                CachedNetworkImage(
                  key: notifier.imageKey,
                  imageUrl: appContent.data.media,
                  errorWidget: (context, value, trace) {
                    return const SizedBox();
                  },
                ),
                ...state.data
              ],
            ),
          ),
        ));
  }

  Widget placeWidget({
    required Widget widget,
    required double leftPosition,
    required double topPosition,
    required double width,
    required double height,
  }) {
    imageHeight = imageKey.currentContext?.size?.height ?? 0;
    imageWidth = imageKey.currentContext?.size?.width ?? 0;

    final heightRatio = 1200 / imageHeight;
    final widthRatio = 1200 / imageWidth;

    return Positioned(
      left: leftPosition / widthRatio,
      top: topPosition / heightRatio,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: height / heightRatio, maxWidth: width / widthRatio),
        child: widget,
      ),
    );
  }
}
