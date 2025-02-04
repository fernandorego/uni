import 'package:http/http.dart';
import 'package:tuple/tuple.dart';
import 'package:uni/controller/fetchers/schedule_fetcher/schedule_fetcher.dart';
import 'package:uni/controller/networking/network_router.dart';
import 'package:uni/controller/parsers/parser_schedule_html.dart';
import 'package:uni/model/entities/lecture.dart';
import 'package:uni/model/entities/profile.dart';
import 'package:uni/model/entities/session.dart';

/// Class for fetching the user's lectures from the schedule's HTML page.
class ScheduleFetcherHtml extends ScheduleFetcher {
  @override
  List<String> getEndpoints(Session session) {
    final urls = NetworkRouter.getBaseUrlsFromSession(session)
        .map((url) => '${url}hor_geral.estudantes_view')
        .toList();
    return urls;
  }

  /// Fetches the user's lectures from the schedule's HTML page.
  @override
  Future<List<Lecture>> getLectures(Session session, Profile profile) async {
    final dates = getDates();
    final baseUrls = NetworkRouter.getBaseUrlsFromSession(session);

    final lectureResponses = <Tuple2<Response, String>>[];
    for (final baseUrl in baseUrls) {
      final url = '${baseUrl}hor_geral.estudantes_view';

      for (final course in profile.courses) {
        final response = await NetworkRouter.getWithCookies(
          url,
          {
            'pv_fest_id': course.festId.toString(),
            'pv_ano_lectivo': dates.lectiveYear.toString(),
            'p_semana_inicio': dates.beginWeek,
            'p_semana_fim': dates.endWeek,
          },
          session,
        );
        lectureResponses.add(Tuple2(response, baseUrl));
      }
    }

    final lectures = await Future.wait(
      lectureResponses.map(
        (e) => getScheduleFromHtml(e.item1, session, e.item2),
      ),
    ).then((schedules) => schedules.expand((schedule) => schedule).toList());

    lectures.sort((l1, l2) => l1.compare(l2));
    return lectures;
  }
}
