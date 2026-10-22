import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../core/pet_data.dart';
import '../core/user_data_session.dart';
import '../models/pet_state.dart';
import '../ui/glass.dart';
import '../ui/glass_widgets.dart';
import 'app_scaffold.dart';

class PetDataView extends StatefulWidget {
  const PetDataView({super.key, required this.builder, this.data});

  final Widget Function(BuildContext, PetState) builder;
  final PetData? data;

  @override
  State<PetDataView> createState() => _PetDataViewState();
}

class _PetDataViewState extends State<PetDataView> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    unawaited(
      Future.microtask(() async {
        if (!mounted) return;
        if (widget.data == null) {
          await UserDataSession.onAuthenticated();
        } else {
          await widget.data!.load();
        }
        if (mounted) setState(() => _checkingSession = false);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data ?? PetData.instance;
    return ValueListenableBuilder<PetState?>(
      valueListenable: data,
      builder: (context, state, _) {
        if (state != null) return widget.builder(context, state);
        final loading = data.busy || _checkingSession;
        return AppShell(
          showBottomNav: true,
          selectedIndex: 4,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading) const CupertinoActivityIndicator(),
                const SizedBox(height: LGGap.lg),
                Text(
                  loading
                      ? 'Loading your pet…'
                      : data.error ?? 'Sign in to see your pets.',
                  textAlign: TextAlign.center,
                ),
                if (!loading && data.signedIn) ...[
                  const SizedBox(height: LGGap.lg),
                  GlassButton(
                    label: 'Try again',
                    onPressed: () => data.retry(),
                    expand: false,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class PetStatus extends StatelessWidget {
  const PetStatus({super.key, this.data});

  final PetData? data;

  @override
  Widget build(BuildContext context) {
    final pets = data ?? PetData.instance;
    if (pets.error == null) {
      return pets.busy
          ? const Padding(
              padding: EdgeInsets.only(bottom: LGGap.lg),
              child: CupertinoActivityIndicator(),
            )
          : const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: LGGap.lg),
      child: Column(
        children: [
          Text(
            pets.error!,
            style: LGText.footnote(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LGGap.sm),
          GlassButton(
            label: pets.needsRetry ? 'Retry request' : 'Refresh pet',
            loading: pets.busy,
            onPressed: () => pets.retry(),
            style: GlassButtonStyle.tinted,
          ),
        ],
      ),
    );
  }
}
