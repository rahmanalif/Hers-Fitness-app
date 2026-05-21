import 'package:fitness/core/network/api_client.dart';
import 'package:fitness/models/member_booking_model.dart';
import 'package:fitness/services/member_booking_service.dart';
import 'package:fitness/services/user_service.dart';
import 'package:fitness/utils/app_snackbar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyClassesController extends GetxController {
  MyClassesController({
    MemberBookingService? bookingService,
    UserService? userService,
  })  : _bookingService = bookingService ?? MemberBookingService(),
        _userService = userService ?? UserService();

  final MemberBookingService _bookingService;
  final UserService _userService;

  final selectedFilter = 'All'.obs;
  final selectedRescheduleDate = 'mm/dd/yyyy'.obs;
  final selectedRescheduleTime = '07:00 AM'.obs;
  final bookings = <MemberBookingModel>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final memberUserId = RxnString();

  final List<String> filters = [
    'All',
    'Meditation',
    'Yoga',
    'Cardio',
    'Strength',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
    fetchBookings();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<Map<String, dynamic>> get filteredSchedules {
    final schedules = bookings
        .map((booking) => booking.toUiMap(memberUserId: memberUserId.value))
        .toList();

    if (selectedFilter.value == 'All') return schedules;
    return schedules
        .where((schedule) => schedule['category'] == selectedFilter.value)
        .toList();
  }

  Future<void> fetchCurrentUser() async {
    try {
      final user = await _userService.getCurrentUser();
      memberUserId.value = user.id;
    } catch (_) {
      memberUserId.value = null;
    }
  }

  Future<void> fetchBookings({bool showError = false}) async {
    try {
      isLoading.value = true;
      final response = await _bookingService.getBookedClasses();
      bookings.assignAll(response);
    } on ApiException catch (error) {
      if (showError) {
        showAppSnackbar(
          'Bookings failed',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      if (showError) {
        showAppSnackbar(
          'Bookings failed',
          'Could not load your bookings.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestReschedule(String bookingId) async {
    if (bookingId.trim().isEmpty) {
      showAppSnackbar(
        'Booking missing',
        'Could not find this booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final newDate = _apiDate(selectedRescheduleDate.value);
    final newStartTime = _apiTime(selectedRescheduleTime.value);

    if (newDate == null || newStartTime == null) {
      showAppSnackbar(
        'Invalid time',
        'Please select a valid date and time.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      await _bookingService.requestReschedule(
        bookingId: bookingId,
        newDate: newDate,
        newStartTime: newStartTime,
      );
      await fetchBookings();
      showAppSnackbar(
        'Reschedule requested',
        'Your new time has been sent to the trainer.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (error) {
      showAppSnackbar(
        'Reschedule failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      showAppSnackbar(
        'Reschedule failed',
        'Could not request a new time.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> acceptReschedule(String bookingId) async {
    if (bookingId.trim().isEmpty) {
      showAppSnackbar(
        'Booking missing',
        'Could not find this booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      await _bookingService.acceptReschedule(bookingId);
      await fetchBookings();
    } on ApiException catch (error) {
      showAppSnackbar(
        'Accept failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      showAppSnackbar(
        'Accept failed',
        'Could not accept the new time.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> completeBooking(String bookingId) async {
    if (bookingId.trim().isEmpty) {
      showAppSnackbar(
        'Booking missing',
        'Could not find this booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      await _bookingService.completeBooking(bookingId);
      await fetchBookings();
      showAppSnackbar(
        'Class completed',
        'Your booking has been marked as complete.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (error) {
      showAppSnackbar(
        'Complete failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      showAppSnackbar(
        'Complete failed',
        'Could not mark this class as complete.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void updateRescheduleDate(String date) {
    selectedRescheduleDate.value = date;
  }

  void updateRescheduleTime(String time) {
    selectedRescheduleTime.value = time;
  }

  String? _apiDate(String value) {
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return value;

    try {
      final parsed = DateFormat('MM/dd/yyyy').parseStrict(value);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      return null;
    }
  }

  String? _apiTime(String value) {
    if (RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(value)) return value;

    try {
      final parsed = DateFormat('hh:mm a').parseStrict(value);
      return DateFormat('HH:mm').format(parsed);
    } catch (_) {
      return null;
    }
  }
}
