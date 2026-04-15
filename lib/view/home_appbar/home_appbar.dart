import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view-model/home_appbar_provider.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/home_appbar/home_appbar_dynamic_panel.dart';
import 'package:wanderhuman_app/view/home_appbar/menu_options.dart';
import 'package:wanderhuman_app/view/components/profile_picture_bottom_modal_sheet.dart';

class HomeAppBar extends StatefulWidget {
  /// This will contain the data of the logged in user for efficient usage in every other components.
  final PersonalInfo loggedInUserData;
  const HomeAppBar({super.key, required this.loggedInUserData});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  int animationDuration = 250;
  double animatedOpacity = 0.0;
  double borderRadius = 30;
  // Newly implemented (not yet fully tested) glass effect
  bool isGlassEffectEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeAppBarProvider>();
    borderRadius = (provider.isAppBarExpanded) ? 25.5 : 25;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        enabled: isGlassEffectEnabled,
        child: AnimatedContainer(
          duration: Duration(milliseconds: animationDuration),
          width: MyDimensionAdapter.getWidth(context) * 0.80,
          height: (provider.isAppBarExpanded)
              ? MyDynamicAppbarHeight.expandingOuterPanelHeight(
                  widget.loggedInUserData.userType,
                )
              : 50,
          decoration: BoxDecoration(
            color: (isGlassEffectEnabled)
                ? (provider.isAppBarExpanded)
                      ? const Color.fromARGB(180, 255, 255, 255)
                      : Colors.white54
                : (provider.isAppBarExpanded) // if glass effect is disabled
                ? const Color.fromARGB(200, 255, 255, 255)
                : Colors.white70,
            gradient: (isGlassEffectEnabled)
                ? LinearGradient(
                    begin: provider.isAppBarExpanded
                        ? Alignment.topCenter
                        : Alignment.centerLeft,
                    end: provider.isAppBarExpanded
                        ? Alignment.bottomCenter
                        : Alignment.centerRight,
                    colors: [
                      provider.isAppBarExpanded
                          ? Colors.white.withAlpha(170)
                          : Colors.white54,
                      provider.isAppBarExpanded
                          ? Colors.white.withAlpha(80)
                          : Colors.white60,
                    ],
                  )
                : null,
            boxShadow: [
              BoxShadow(
                blurStyle: BlurStyle.outer,
                offset: Offset(2, 2),
                color: Colors.white70,
                blurRadius: 8,
                spreadRadius: 2,
              ),
              BoxShadow(
                blurStyle: BlurStyle.outer,
                offset: Offset(-2, -2),
                color: Colors.white70,
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.only(left: 8, right: 10, top: 5, bottom: 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // the user avatar/pic/icon container
                    GestureDetector(
                      onTap: () {
                        showProfilePictureBottomModalSheet(
                          context,
                          currentLoggedInUserData: widget.loggedInUserData,
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: MyImageDisplayer(
                          base64ImageString: provider.cachedImageString,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),

                    SizedBox(
                      width: MyDimensionAdapter.getWidth(context) * 0.50,
                      child: (widget.loggedInUserData.name == "...")
                          ? CircularProgressIndicator()
                          : Text(
                              provider.userName,
                              style: TextStyle(
                                // color: Colors.,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),

                    Spacer(),

                    // Icon button
                    InkWell(
                      onTap: () {
                        provider.toggleAppBarExpansion(
                          !(provider.isAppBarExpanded),
                        );
                      },
                      child: Icon(
                        (provider.isAppBarExpanded)
                            ? Icons.close_rounded
                            : Icons.menu_rounded,
                        size: 32,
                        color: (provider.isAppBarExpanded)
                            ? Colors.blue.shade400
                            : Colors.blue.shade400,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.blueGrey.withAlpha(50),
                            offset: Offset(1, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // this contains the menu options
                AnimatedOpacity(
                  opacity: (provider.isAppBarExpanded) ? 1.0 : 0.0,
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: animationDuration),
                  child: MyMenuOptions(
                    isVisible: provider.isAppBarExpanded,
                    loggedInUserData: widget.loggedInUserData,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
