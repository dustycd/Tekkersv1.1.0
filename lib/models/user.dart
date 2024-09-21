import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class UserWidget extends StatelessWidget {
  final UserProfile? user;

  const UserWidget({required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert Uri to String if the picture URL is available
    final pictureUrl = user?.pictureUrl?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pictureUrl != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: CircleAvatar(
              radius: 56,
              backgroundImage: NetworkImage(pictureUrl), // String is expected here
            ),
          ),
        Card(
          child: Column(
            children: [
              UserEntryWidget(propertyName: 'Id', propertyValue: user?.sub),
              UserEntryWidget(propertyName: 'Name', propertyValue: user?.name),
              UserEntryWidget(propertyName: 'Email', propertyValue: user?.email),
              UserEntryWidget(
                  propertyName: 'Email Verified?',
                  propertyValue: user?.isEmailVerified.toString()),
              UserEntryWidget(
                  propertyName: 'Updated at',
                  propertyValue: user?.updatedAt?.toIso8601String()),
            ],
          ),
        )
      ],
    );
  }
}

class UserEntryWidget extends StatelessWidget {
  final String propertyName;
  final String? propertyValue;

  const UserEntryWidget(
      {required this.propertyName, required this.propertyValue, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(propertyName),
          Text(propertyValue ?? ''),
        ],
      ),
    );
  }
}