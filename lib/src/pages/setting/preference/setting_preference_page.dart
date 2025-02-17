import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhentai/src/extension/widget_extension.dart';
import 'package:jhentai/src/model/tab_bar_icon.dart';
import 'package:jhentai/src/service/tag_search_order_service.dart';

import '../../../consts/locale_consts.dart';
import '../../../l18n/locale_text.dart';
import '../../../model/jh_layout.dart';
import '../../../routes/routes.dart';
import '../../../service/tag_translation_service.dart';
import '../../../setting/preference_setting.dart';
import '../../../setting/style_setting.dart';
import '../../../utils/locale_util.dart';
import '../../../utils/route_util.dart';
import '../../../widget/loading_state_indicator.dart';

class SettingPreferencePage extends StatelessWidget {
  final TagTranslationService tagTranslationService = Get.find();
  final TagSearchOrderOptimizationService tagSearchOrderOptimizationService = Get.find();

  SettingPreferencePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('preferenceSetting'.tr)),
      body: Obx(
        () => SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(top: 16),
            children: [
              _buildLanguage(),
              _buildTagTranslate(),
              _buildTagOrderOptimization(),
              _buildDefaultTab(),
              if (StyleSetting.isInV2Layout) _buildSimpleDashboardMode(),
              if (StyleSetting.isInV2Layout) _buildShowBottomNavigation(),
              if (StyleSetting.isInV2Layout || StyleSetting.actualLayout == LayoutMode.desktop) _buildHideScroll2TopButton(),
              _buildEnableSwipeBackGesture(),
              if (StyleSetting.isInV2Layout) _buildEnableLeftMenuDrawerGesture(),
              if (StyleSetting.isInV2Layout) _buildQuickSearch(),
              if (StyleSetting.isInV2Layout) _buildDrawerGestureEdgeWidth(context),
              _buildShowAllGalleryTitles(),
              _buildShowComments(),
              if (PreferenceSetting.showComments.isTrue) _buildShowAllComments().fadeIn(const Key('showAllComments')),
              _buildEnableDefaultFavorite(),
              if (GetPlatform.isDesktop && StyleSetting.isInDesktopLayout) _buildLaunchInFullScreen(),
              _buildTagSearchConfig(),
              if (PreferenceSetting.enableTagZHTranslation.isTrue) _buildShowR18GImageDirectly().fadeIn(const Key('showR18GImageDirectly')),
              _buildLocalTags(),
            ],
          ).withListTileTheme(context),
        ),
      ),
    );
  }

  Widget _buildLanguage() {
    return ListTile(
      title: Text('language'.tr),
      trailing: DropdownButton<Locale>(
        value: PreferenceSetting.locale.value,
        elevation: 4,
        alignment: AlignmentDirectional.centerEnd,
        onChanged: (Locale? newValue) => PreferenceSetting.saveLanguage(newValue!),
        items: LocaleText()
            .keys
            .keys
            .map((localeCode) => DropdownMenuItem(
                  child: Text(LocaleConsts.localeCode2Description[localeCode]!),
                  value: localeCode2Locale(localeCode),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTagTranslate() {
    return ListTile(
      title: Text('enableTagZHTranslation'.tr),
      subtitle: tagTranslationService.loadingState.value == LoadingState.success
          ? Text('${'version'.tr}: ${tagTranslationService.timeStamp.value!}', style: const TextStyle(fontSize: 12))
          : tagTranslationService.loadingState.value == LoadingState.loading
              ? Text(
                  '${'downloadTagTranslationHint'.tr}${tagTranslationService.downloadProgress.value}',
                  style: const TextStyle(fontSize: 12),
                )
              : tagTranslationService.loadingState.value == LoadingState.error
                  ? Text('downloadFailed'.tr, style: const TextStyle(fontSize: 12))
                  : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingStateIndicator(
            useCupertinoIndicator: true,
            loadingState: tagTranslationService.loadingState.value,
            indicatorRadius: 10,
            width: 40,
            idleWidget: IconButton(onPressed: tagTranslationService.refresh, icon: const Icon(Icons.refresh)),
            errorWidgetSameWithIdle: true,
            successWidgetSameWithIdle: true,
          ),
          Switch(
            value: PreferenceSetting.enableTagZHTranslation.value,
            onChanged: (value) {
              PreferenceSetting.saveEnableTagZHTranslation(value);
              if (value == true && tagTranslationService.loadingState.value != LoadingState.success) {
                tagTranslationService.refresh();
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildTagOrderOptimization() {
    return ListTile(
      title: Text('zhTagSearchOrderOptimization'.tr),
      subtitle: tagSearchOrderOptimizationService.loadingState.value == LoadingState.success
          ? Text('${'version'.tr}: ${tagSearchOrderOptimizationService.version.value!}', style: const TextStyle(fontSize: 12))
          : tagSearchOrderOptimizationService.loadingState.value == LoadingState.loading
              ? Text(
                  '${'downloadTagTranslationHint'.tr}${tagSearchOrderOptimizationService.downloadProgress.value}',
                  style: const TextStyle(fontSize: 12),
                )
              : tagSearchOrderOptimizationService.loadingState.value == LoadingState.error
                  ? Text('downloadFailed'.tr, style: const TextStyle(fontSize: 12))
                  : Text('zhTagSearchOrderOptimizationHint'.tr),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingStateIndicator(
            useCupertinoIndicator: true,
            loadingState: tagSearchOrderOptimizationService.loadingState.value,
            indicatorRadius: 10,
            width: 40,
            idleWidget: IconButton(onPressed: tagSearchOrderOptimizationService.refresh, icon: const Icon(Icons.refresh)),
            errorWidgetSameWithIdle: true,
            successWidgetSameWithIdle: true,
          ),
          Switch(
            value: PreferenceSetting.enableTagZHSearchOrderOptimization.value,
            onChanged: (value) {
              PreferenceSetting.saveEnableTagZHSearchOrderOptimization(value);
              if (value == true && tagSearchOrderOptimizationService.loadingState.value != LoadingState.success) {
                tagSearchOrderOptimizationService.refresh();
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildDefaultTab() {
    return ListTile(
      title: Text('defaultTab'.tr),
      trailing: DropdownButton<TabBarIconNameEnum>(
        value: PreferenceSetting.defaultTab.value,
        elevation: 4,
        alignment: AlignmentDirectional.centerEnd,
        onChanged: (TabBarIconNameEnum? newValue) => PreferenceSetting.saveDefaultTab(newValue!),
        items: [
          DropdownMenuItem(
            child: Text(TabBarIconNameEnum.home.name.tr),
            value: TabBarIconNameEnum.home,
          ),
          DropdownMenuItem(
            child: Text(TabBarIconNameEnum.popular.name.tr),
            value: TabBarIconNameEnum.popular,
          ),
          DropdownMenuItem(
            child: Text(TabBarIconNameEnum.ranklist.name.tr),
            value: TabBarIconNameEnum.ranklist,
          ),
          DropdownMenuItem(
            child: Text(TabBarIconNameEnum.favorite.name.tr),
            value: TabBarIconNameEnum.favorite,
          ),
          DropdownMenuItem(
            child: Text(TabBarIconNameEnum.watched.name.tr),
            value: TabBarIconNameEnum.watched,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDashboardMode() {
    return ListTile(
      title: Text('simpleDashboardMode'.tr),
      subtitle: Text('simpleDashboardModeHint'.tr),
      trailing: Switch(
        value: PreferenceSetting.simpleDashboardMode.value,
        onChanged: PreferenceSetting.saveSimpleDashboardMode,
      ),
    );
  }

  Widget _buildShowBottomNavigation() {
    return SwitchListTile(
      title: Text('hideBottomBar'.tr),
      value: PreferenceSetting.hideBottomBar.value,
      onChanged: PreferenceSetting.saveHideBottomBar,
    );
  }

  Widget _buildHideScroll2TopButton() {
    return ListTile(
      title: Text('hideScroll2TopButton'.tr),
      trailing: DropdownButton<Scroll2TopButtonModeEnum>(
        value: PreferenceSetting.hideScroll2TopButton.value,
        elevation: 4,
        alignment: AlignmentDirectional.centerEnd,
        onChanged: (Scroll2TopButtonModeEnum? newValue) => PreferenceSetting.saveHideScroll2TopButton(newValue!),
        items: [
          DropdownMenuItem(
            child: Text('whenScrollUp'.tr),
            value: Scroll2TopButtonModeEnum.scrollUp,
          ),
          DropdownMenuItem(
            child: Text('whenScrollDown'.tr),
            value: Scroll2TopButtonModeEnum.scrollDown,
          ),
          DropdownMenuItem(
            child: Text('never'.tr),
            value: Scroll2TopButtonModeEnum.never,
          ),
        ],
      ),
    );
  }

  Widget _buildEnableSwipeBackGesture() {
    return SwitchListTile(
      title: Text('enableSwipeBackGesture'.tr),
      subtitle: Text('needRestart'.tr),
      value: PreferenceSetting.enableSwipeBackGesture.value,
      onChanged: PreferenceSetting.saveEnableSwipeBackGesture,
    );
  }

  Widget _buildEnableLeftMenuDrawerGesture() {
    return SwitchListTile(
      title: Text('enableLeftMenuDrawerGesture'.tr),
      value: PreferenceSetting.enableLeftMenuDrawerGesture.value,
      onChanged: PreferenceSetting.saveEnableLeftMenuDrawerGesture,
    );
  }

  Widget _buildQuickSearch() {
    return ListTile(
      title: Text('enableQuickSearchDrawerGesture'.tr),
      trailing: Switch(
        value: PreferenceSetting.enableQuickSearchDrawerGesture.value,
        onChanged: PreferenceSetting.saveEnableQuickSearchDrawerGesture,
      ),
    );
  }

  Widget _buildDrawerGestureEdgeWidth(BuildContext context) {
    return ListTile(
      title: Text('drawerGestureEdgeWidth'.tr),
      trailing: Obx(() {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(showValueIndicator: ShowValueIndicator.always),
              child: Slider(
                min: 20,
                max: 300,
                label: PreferenceSetting.drawerGestureEdgeWidth.value.toString(),
                value: PreferenceSetting.drawerGestureEdgeWidth.value.toDouble(),
                onChanged: (value) {
                  PreferenceSetting.drawerGestureEdgeWidth.value = value.toInt();
                },
                onChangeEnd: (value) {
                  PreferenceSetting.saveDrawerGestureEdgeWidth(value.toInt());
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildShowAllGalleryTitles() {
    return SwitchListTile(
      title: Text('showAllGalleryTitles'.tr),
      subtitle: Text('showAllGalleryTitlesHint'.tr),
      value: PreferenceSetting.showAllGalleryTitles.value,
      onChanged: PreferenceSetting.saveShowAllGalleryTitles,
    );
  }

  Widget _buildShowComments() {
    return SwitchListTile(
      title: Text('showComments'.tr),
      value: PreferenceSetting.showComments.value,
      onChanged: PreferenceSetting.saveShowComments,
    );
  }

  Widget _buildShowAllComments() {
    return SwitchListTile(
      title: Text('showAllComments'.tr),
      subtitle: Text('showAllCommentsHint'.tr),
      value: PreferenceSetting.showAllComments.value,
      onChanged: PreferenceSetting.saveShowAllComments,
    );
  }

  Widget _buildShowR18GImageDirectly() {
    return ListTile(
      title: Text('showR18GImageDirectly'.tr),
      trailing: Switch(
        value: PreferenceSetting.showR18GImageDirectly.value,
        onChanged: PreferenceSetting.saveShowR18GImageDirectly,
      ),
    );
  }

  Widget _buildEnableDefaultFavorite() {
    return ListTile(
      title: Text('enableDefaultFavorite'.tr),
      subtitle: Text(PreferenceSetting.enableDefaultFavorite.isTrue ? 'enableDefaultFavoriteHint'.tr : 'disableDefaultFavoriteHint'.tr),
      trailing: Switch(
        value: PreferenceSetting.enableDefaultFavorite.value,
        onChanged: PreferenceSetting.saveEnableDefaultFavorite,
      ),
    );
  }

  Widget _buildLaunchInFullScreen() {
    return ListTile(
      title: Text('launchInFullScreen'.tr),
      subtitle: Text('launchInFullScreenHint'.tr),
      trailing: Switch(
        value: PreferenceSetting.launchInFullScreen.value,
        onChanged: PreferenceSetting.saveLaunchInFullScreen,
      ),
    );
  }

  Widget _buildTagSearchConfig() {
    return ListTile(
      title: Text('tagSearchBehaviour'.tr),
      subtitle: Text(
        PreferenceSetting.tagSearchBehaviour.value == TagSearchBehaviour.inheritAll
            ? 'inheritAllHint'.tr
            : PreferenceSetting.tagSearchBehaviour.value == TagSearchBehaviour.inheritPartially
                ? 'inheritPartiallyHint'.tr
                : 'noneHint'.tr,
      ),
      trailing: DropdownButton<TagSearchBehaviour>(
        value: PreferenceSetting.tagSearchBehaviour.value,
        elevation: 4,
        alignment: AlignmentDirectional.centerEnd,
        onChanged: (TagSearchBehaviour? newValue) => PreferenceSetting.saveTagSearchConfig(newValue!),
        items: [
          DropdownMenuItem(
            child: Text('inheritAll'.tr),
            value: TagSearchBehaviour.inheritAll,
          ),
          DropdownMenuItem(
            child: Text('inheritPartially'.tr),
            value: TagSearchBehaviour.inheritPartially,
          ),
          DropdownMenuItem(
            child: Text('none'.tr),
            value: TagSearchBehaviour.none,
          ),
        ],
      ),
    );
  }

  Widget _buildLocalTags() {
    return ListTile(
      title: Text('localTags'.tr),
      subtitle: Text('localTagsHint'.tr),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => toRoute(Routes.localTagSets),
    );
  }
}
