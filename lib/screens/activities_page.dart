import 'package:flutter/cupertino.dart';

import '../core/pet_data.dart';
import '../models/pet_state.dart';
import '../ui/glass.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/pet_data_view.dart';

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key, this.data});

  final PetData? data;

  @override
  Widget build(BuildContext context) => PetDataView(
    data: data,
    builder: (context, state) => _build(context, state),
  );

  Widget _build(BuildContext context, PetState state) => AppShell(
    showBottomNav: true,
    selectedIndex: 4,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(2, 42, 2, 100),
      children: [
        PetStatus(data: data),
        BackTitle(title: 'Activities', trailing: '${state.stats.coins} coins'),
        const SizedBox(height: LGGap.edge),
        GreyPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('No pet activities yet', style: LGText.headline(context)),
              const SizedBox(height: LGGap.md),
              Text(
                'Pet activities are coming later. You can care for your pet in the garden.',
                style: LGText.footnote(context),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
