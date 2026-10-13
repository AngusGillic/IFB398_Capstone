import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';

import '../data/user_data.dart';
import '../models/garden_catalogue.dart';
import '../models/pet.dart';
import '../models/pet_state.dart';
import '../services/pet_api.dart';

class PetData extends ValueNotifier<PetState?> {
  PetData({
    required PetApi api,
    void Function(PetState)? onChanged,
    VoidCallback? onCleared,
    DateTime Function()? clock,
  }) : _api = api,
       _onChanged = onChanged ?? _updateApp,
       _onCleared = onCleared ?? _clearApp,
       _clock = clock ?? DateTime.now,
       super(null);

  static final PetData instance = PetData(api: PetApi());

  final PetApi _api;
  final void Function(PetState) _onChanged;
  final VoidCallback _onCleared;
  final DateTime Function() _clock;
  DateTime? _receivedAt;
  GardenCatalogue? shop;
  bool shopBusy = false;
  String? shopError;
  bool _shopRequested = false;
  bool _needsRefresh = false;
  String? _owner;
  int _session = 0;
  bool busy = false;
  String? error;
  ({String operation, Map<String, dynamic> body})? _pending;

  String? get owner => _owner;
  bool get signedIn => _owner != null;
  bool get needsRetry => _pending != null;
  bool get needsRefresh => _needsRefresh;

  void bindUser(String? owner) {
    if (_owner == owner) return;
    _session++;
    _owner = owner;
    shop = null;
    shopBusy = false;
    shopError = null;
    _receivedAt = null;
    _needsRefresh = false;
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
      if (session == _session) {
        _publish(state);
        if (_shopRequested) await loadShop();
      }
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

  Future<void> loadShop() async {
    _shopRequested = true;
    final owner = _owner;
    if (owner == null || value == null || shopBusy) return;
    final session = _session;
    shopBusy = true;
    shopError = null;
    notifyListeners();
    try {
      final catalogue = await _api.fetchCatalogue(owner);
      if (session == _session) shop = catalogue;
    } catch (e) {
      if (session == _session) {
        if (e is PetApiException && e.status == 401) bindUser(null);
        shopError = _message(e);
        notifyListeners();
      }
    } finally {
      if (session == _session) {
        shopBusy = false;
        notifyListeners();
      }
    }
  }

  Duration cooldownFor(String action) {
    final until = value?.cooldowns[action];
    if (until == null || _receivedAt == null) return Duration.zero;
    final serverNow = (value!.serverTime ?? _receivedAt!).add(
      _clock().difference(_receivedAt!),
    );
    final remaining = until.difference(serverNow);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<bool> buy(String id) {
    if (shop?.items.containsKey(id) != true) return Future.value(false);
    return _save('purchases', {'item_id': id});
  }

  Future<bool> care(String id) {
    if (shop?.actions.contains(id) != true || cooldownFor(id) > Duration.zero) {
      return Future.value(false);
    }
    return _save('actions', {'action_id': id});
  }

  Future<bool> select(String id) async {
    if (busy || value == null || needsRetry || needsRefresh) return false;
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
    if (busy || value == null || needsRetry || needsRefresh)
      return Future.value(false);
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
    final wasRetry = _pending != null;
    busy = true;
    error = null;
    _pending = (operation: operation, body: body);
    notifyListeners();
    try {
      final state = await _api.save(owner, operation, body);
      if (session != _session) return false;
      _pending = null;
      _publish(state);
      if (wasRetry) {
        _needsRefresh = true;
        try {
          final latest = await _api.fetch(owner);
          if (session != _session) return false;
          _publish(latest);
        } catch (e) {
          if (session != _session) return false;
          if (e is PetApiException && e.status == 401) bindUser(null);
          error = _message(e);
        }
      }
      return session == _session;
    } catch (e) {
      if (session != _session) return false;
      // An uncertain write keeps its request ID so a retry cannot charge twice.
      if (e is PetApiException && e.status != null && e.status! < 500) {
        _pending = null;
        if (e.status == 409) {
          _needsRefresh = true;
          try {
            final state = await _api.fetch(owner);
            if (session == _session) _publish(state);
          } catch (refreshError) {
            if (session == _session) {
              if (refreshError is PetApiException && refreshError.status == 401)
                bindUser(null);
              error = _message(refreshError);
              notifyListeners();
            }
            return false;
          }
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

  @override
  void dispose() {
    _session++;
    super.dispose();
  }

  void _publish(PetState state) {
    if (value != null && state.version < value!.version) return;
    _receivedAt = _clock();
    _needsRefresh = false;
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
