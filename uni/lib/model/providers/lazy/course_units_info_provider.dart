import 'dart:collection';

import 'package:tuple/tuple.dart';
import 'package:uni/controller/fetchers/course_units_fetcher/course_units_info_fetcher.dart';
import 'package:uni/model/entities/course_units/course_unit.dart';
import 'package:uni/model/entities/course_units/course_unit_class.dart';
import 'package:uni/model/entities/course_units/course_unit_directory.dart';
import 'package:uni/model/entities/course_units/course_unit_sheet.dart';
import 'package:uni/model/entities/session.dart';
import 'package:uni/model/providers/state_provider_notifier.dart';
import 'package:uni/model/providers/state_providers.dart';

typedef SheetsMap = Map<CourseUnit, CourseUnitSheet>;
typedef ClassesMap = Map<CourseUnit, List<CourseUnitClass>>;
typedef FilesMap = Map<CourseUnit, List<CourseUnitFileDirectory>>;

class CourseUnitsInfoProvider
    extends StateProviderNotifier<Tuple3<SheetsMap, ClassesMap, FilesMap>> {
  CourseUnitsInfoProvider()
      : super(
          cacheDuration: null,
          // Const constructor is not allowed here because of the
          // need for mutable maps
          // ignore: prefer_const_constructors
          initialState: Tuple3({}, {}, {}),
        );

  UnmodifiableMapView<CourseUnit, CourseUnitSheet> get courseUnitsSheets =>
      UnmodifiableMapView(state!.item1);

  UnmodifiableMapView<CourseUnit, List<CourseUnitClass>>
      get courseUnitsClasses => UnmodifiableMapView(state!.item2);

  UnmodifiableMapView<CourseUnit, List<CourseUnitFileDirectory>>
      get courseUnitsFiles => UnmodifiableMapView(state!.item3);

  Future<void> fetchCourseUnitSheet(
    CourseUnit courseUnit,
    Session session,
  ) async {
    state!.item1[courseUnit] = await CourseUnitsInfoFetcher()
        .fetchCourseUnitSheet(session, courseUnit.occurrId);
    notifyListeners();
  }

  Future<void> fetchCourseUnitClasses(
    CourseUnit courseUnit,
    Session session,
  ) async {
    state!.item2[courseUnit] = await CourseUnitsInfoFetcher()
        .fetchCourseUnitClasses(session, courseUnit.occurrId);
  }

  Future<void> fetchCourseUnitFiles(
    CourseUnit courseUnit,
    Session session,
  ) async {
    state!.item3[courseUnit] = await CourseUnitsInfoFetcher()
        .fetchCourseUnitFiles(session, courseUnit.occurrId);
  }

  @override
  Future<Tuple3<SheetsMap, ClassesMap, FilesMap>> loadFromRemote(
    StateProviders stateProviders,
  ) async {
    return const Tuple3({}, {}, {});
  }

  @override
  Future<Tuple3<SheetsMap, ClassesMap, FilesMap>> loadFromStorage(
    StateProviders stateProviders,
  ) async {
    return const Tuple3({}, {}, {});
  }
}
