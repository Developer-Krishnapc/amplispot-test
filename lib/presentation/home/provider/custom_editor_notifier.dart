import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/constants/entity_type.dart';
import '../../../domain/model/load_error_state.dart';
import '../../shared/components/app_text_theme.dart';
import '../../shared/providers/app_content.dart';
import '../../theme/config/app_color.dart';

final customWidgetListNotifierProvider = StateNotifierProvider<
    CustomWidgetListNotifier, LoadErrorState<List<Widget>>>((ref) {
  return CustomWidgetListNotifier(ref);
});

class CustomWidgetListNotifier
    extends StateNotifier<LoadErrorState<List<Widget>>> {
  CustomWidgetListNotifier(this._ref)
      : super(LoadErrorState(data: const [], loading: false));

  final Ref _ref;
  final imageKey = GlobalKey();

  final ScreenshotController screenshotCtrl = ScreenshotController();

  bool fetchData({required BuildContext context}) {
    state = state.copyWith(loading: true, error: '');
    final appContentData = _ref.read(
      appContentProvider.select(
        (value) => value.data.configList,
      ),
    );
    final imageHeight = imageKey.currentContext?.size?.height ?? 0;
    final imageWidth = imageKey.currentContext?.size?.width ?? 0;

    final heightRatio = 1200 / imageHeight;
    final widthRatio = 1200 / imageWidth;

    final List<Widget> widgetList = [];
    appContentData.forEach((element) {
      widgetList.add(
        Positioned(
          left: element.cofigSettings.left / widthRatio,
          top: element.cofigSettings.top / heightRatio,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: element.cofigSettings.dimensions.height / heightRatio,
              maxWidth: element.cofigSettings.dimensions.width / widthRatio,
            ),
            child: SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: (element.title == EntityType.mobile ||
                      element.title == EntityType.name)
                  ? getTextWidget(
                      title: element.value,
                    )
                  : getImage(url: element.value, context: context),
            ),
          ),
        ),
      );
    });

    state = state.copyWith(data: widgetList, loading: false);

    return state.error.isEmpty;
  }

  Widget getTextWidget({required String title}) {
    return Text(
      title,
      style: AppTextTheme.semiBold18.copyWith(
        color: AppColor.white,
      ),
      overflow: TextOverflow.clip,
    );
  }

  Widget getImage({required String url, required BuildContext context}) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.fitWidth,
      errorWidget: (context, error, stackTrace) {
        return SizedBox();
      },
    );
  }

  Future<bool> saveImage() async {
    state = state.copyWith(loading: true, error: '');
    await screenshotCtrl.capture().then((image) async {
      if (image != null) {
        await ImageGallerySaver.saveImage(
          image,
        );
        state = state.copyWith(loading: false, error: '');
      }
    }).catchError((error) {
      state = state.copyWith(loading: false, error: error);
    });

    return state.error.isEmpty;
  }
}
