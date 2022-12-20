import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni/controller/load_info.dart';
import 'package:uni/model/entities/course_units/course_unit_class.dart';
import 'package:uni/model/entities/session.dart';
import 'package:uni/model/providers/session_provider.dart';
import 'package:uni/view/course_unit_info/widgets/course_unit_info_card.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseUnitsClassesView extends StatelessWidget {
  final List<CourseUnitClass> classes;
  const CourseUnitsClassesView(this.classes, {super.key});

  @override
  Widget build(BuildContext context) {
    final Session session = context.read<SessionProvider>().session;
    final List<CourseUnitInfoCard> cards = [];
    for (var courseUnitClass in classes) {
      final bool isMyClass = courseUnitClass.students
          .where((student) =>
              student.number ==
              (int.tryParse(
                      session.studentNumber.replaceAll(RegExp(r"\D"), "")) ??
                  0))
          .isNotEmpty;
      cards.add(_buildCard(
          isMyClass
              ? '${courseUnitClass.className} *'
              : courseUnitClass.className,
          Column(
            children: courseUnitClass.students
                .map((student) => _buildStudentWidget(student, session))
                .toList(),
          )));
    }

    return Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ListView(children: cards));
  }

  CourseUnitInfoCard _buildCard(String sectionTitle, Widget sectionContent) {
    return CourseUnitInfoCard(
      sectionTitle,
      sectionContent,
    );
  }

  Widget _buildStudentWidget(CourseUnitStudent student, Session session) {
    final Future<File?> userImage =
        loadUserProfilePicture("up${student.number}", session);
    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
        return Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: snapshot.hasData &&
                                    snapshot.data!.lengthSync() > 0
                                ? FileImage(snapshot.data!) as ImageProvider
                                : const AssetImage(
                                    'assets/images/profile_placeholder.png')))),
                Expanded(
                    child: InkWell(
                        onTap: () => launchUrl(student.profile),
                        child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1),
                                  Opacity(
                                      opacity: 0.8,
                                      child: Text(
                                        "up${student.number}",
                                      ))
                                ]))))
              ],
            ));
      },
      future: userImage,
    );
  }
}
