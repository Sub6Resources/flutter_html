import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'rich_text_parser.dart';
import 'package:fluffychat/utils/platform_infos.dart';

class Pill extends StatelessWidget {
  final String identifier;
  final Future<Map<String, dynamic>> future;
  final OnPillTap onTap;
  final GetMxcUrl getMxcUrl;

  const Pill({
    Key key,
    this.identifier,
    this.future,
    this.onTap,
    this.getMxcUrl,
  }) : super(key: key);

  @override
  build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: this.future ?? Future.value(null),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        String displayname = this.identifier;
        String avatarUrl;
        if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data['displayname'] is String &&
              snapshot.data['displayname'].isNotEmpty) {
            displayname = snapshot.data['displayname'];
          }
          if (snapshot.data['avatar_url'] is String &&
              snapshot.data['avatar_url'].isNotEmpty &&
              this.getMxcUrl != null) {
            avatarUrl = snapshot.data['avatar_url'];
            displayname = " ${displayname}";
          }
        }
        final avatarSize = DefaultTextStyle.of(context).style.fontSize;
        String url = avatarUrl != null
            ? this.getMxcUrl(avatarUrl, avatarSize, avatarSize)
            : null;
        final padding = avatarSize / 20;
        return InkWell(
          child: Container(
            padding: EdgeInsets.only(
              top: padding,
              bottom: padding,
              left: avatarUrl != null ? padding * 3 : avatarSize / 2,
              right: avatarSize / 2,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius:
                  BorderRadius.all(Radius.circular(avatarSize + padding)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (avatarUrl != null)
                  CircleAvatar(
                    radius: avatarSize / 2,
                    backgroundImage: PlatformInfos.isBetaDesktop
                        ? NetworkImage(url)
                        : CachedNetworkImageProvider(url),
                  ),
                Text(displayname, style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          onTap: () {
            if (this.onTap != null) {
              this.onTap(this.identifier);
            }
          },
        );
      },
    );
  }
}
