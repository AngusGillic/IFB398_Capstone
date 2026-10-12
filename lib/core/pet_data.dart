import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';

import '../data/user_data.dart';
import '../models/pet.dart';
import '../models/pet_state.dart';
import '../services/pet_api.dart';

class PetData extends ValueNotifier<PetState?> {
  PetData({
    required PetApi api,
    void Function(PetState)? onChanged,
    VoidCallback? onCleared,
  }) : _api = api,
       _onChanged = onChanged ?? _updateApp,
       _onCleared = onCleared ?? _clearApp,
       super(null);

  static final PetData instance = PetData(api: PetApi());

  final PetApi _api;
  final void Function(PetState) _onChanged;
  final VoidCallback _onCleared;
  String? _owner;
  int _session = 0;
  bool busy = false;
  String? error;
  ({String operation, Map<String, dynamic> body})? _pending;

  String? get owner => _owner;
  bool get signedIn => _owner != null;
  bool get needsRetry => _pending != null;

  void bindUser(String? owner) {
    if (_owner == owner) return;
    _session++;
    _owner = owner;
    busy = false;
    error = null;
    _pending = null;
    _onCleared();
    value = null;
    notifyListeners();
  }

  Future<void> load() async {
    final owner = _owner;
    if (owner == null || busy) return;
    final session = _session;
    busy = true;
    error = null;
    notifyListeners();
    try {
      final state = await _api.fetch(owner);
      if (session == _session) _publish(state);
    } catch (e) {
      if (session == _session) {
        if (e is PetApiException && e.status == 401) bindUser(null);
        error = _message(e);
        notifyListeners();
      }
    } finally {
      if (session == _session) {
        busy = false;
        notifyListeners();
      }
    }
  }

  Future<bool> select(String id) async {
    if (busy || value == null || needsRetry) return false;
    if (id == value!.selectedPetId) return true;
    return _save('selection', {'pet_id': id});
  }

  Future<bool> retry() async {
    final pending = _pending;
    if (pending == null) {
      await load();
      return error == null && value != null;
    }
    return _send(pending.operation, pending.body);
  }

  Future<bool> _save(String operation, Map<String, dynamic> fields) {
    if (busy || value == null || needsRetry) return Future.value(false);
    return _send(operation, {
      ...fields,
      'version': value!.version,
      'request_id': UUID.getUUID(),
    });
  }

  Future<bool> _send(String operation, Map<String, dynamic> body) async {
    final owner = _owner;
    if (owner == null || busy) return false;
    final session = _session;
    busy = true;
    error = null;
    _pending = (operation: operation, body: body);
    notifyListeners();
    try {
      final state = await _api.save(owner, operation, body);
      if (session != _session) return false;
      _pending = null;
      _publish(state);
      return true;
    } catch (e) {
      if (session != _session) return false;
      // An uncertain write keeps its request ID so a retry cannot charge twice.
      if (e is PetApiException && e.status != null && e.status! < 500) {
        _pending = null;
        if (e.status == 409) {
          try {
            final state = await _api.fetch(owner);
            if (session == _session) _publish(state);
          } catch (_) {}
        }
      } else if (e is PetApiException && e.code == 'not_configured') {
        _pending = null;
      }
      if (session == _session) {
        if (e is PetApiException && e.status == 401) bindUser(null);
        error = _message(e);
        notifyListeners();
      }
      return false;
    } finally {
      if (session == _session) {
        busy = false;
        notifyListeners();
      }
    }
  }

  void _publish(PetState state) {
    _onChanged(state);
    value = state;
  }

  static void _clearApp() {
    AppData.instance.reset();
    PetController.instance.select(PetCatalogue.all.first.id);
  }

  static void _updateApp(PetState state) {
    AppData.instance.setPet(state.stats, state.co2SavedKg);
    PetController.instance.select(state.selectedPetId);
  }

  static String _message(Object error) => error is PetApiException
      ? error.message
      : 'Pets could not be loaded. Please try again.';
}
