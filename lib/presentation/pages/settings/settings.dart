import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_alarm/core/constant_data.dart';
import 'package:location_alarm/presentation/pages/home_page/home_page.dart';
import 'package:location_alarm/presentation/pages/settings/counter_cubit.dart';
import 'package:location_alarm/presentation/widgets/custom_app_bar.dart';
import 'package:location_alarm/presentation/widgets/custom_drawer.dart';
import 'package:location_alarm/core/extensions/build_context_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatelessWidget {
  static const routeName = 'settings';

  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _cubit = CounterCubit(ConstantData.arrivedNotifCount);

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(
        actions: [
          InkWell(
            child: Container(
              margin: const EdgeInsets.all(15),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () async{
              ConstantData.arrivedNotifCount = _cubit.state;
              (await SharedPreferences.getInstance()).setInt(ConstantData.arrivedNotifCountKey, _cubit.state);

              Navigator.of(context).pushNamed(HomePage.routeName);
            },
          ),
        ],
        title: 'Settings',
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Arrival Notifications Count: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    )),
                _Counter(
                  notifCounterCubit: _cubit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final CounterCubit notifCounterCubit;

  const _Counter({Key? key, required this.notifCounterCubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          child: Icon(
            Icons.do_disturb_on_sharp,
            color: theme.primaryColor,
            size: 30,
          ),
          onTap: () {
            if (notifCounterCubit.state < 20) {
              notifCounterCubit.decrement();
            } else {
              context.showSnack(
                'Maximum number is 20',
                theme.errorColor,
              );
            }
          },
        ),
        const SizedBox(width: 10),
        BlocBuilder<CounterCubit, int>(
          bloc: notifCounterCubit,
          builder: (context, state) {
            return Text(
              notifCounterCubit.state.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        InkWell(
          child: Icon(
            Icons.add_circle_sharp,
            color: theme.primaryColor,
            size: 30,
          ),
          onTap: () {
            if (notifCounterCubit.state > 1) {
              notifCounterCubit.increment();
            } else {
              context.showSnack(
                'Minimum number is 1',
                Colors.red,
              );
            }
          },
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    );
  }
}
