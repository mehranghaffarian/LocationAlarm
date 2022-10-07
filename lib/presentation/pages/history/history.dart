import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:location_alarm/core/background_service_utils.dart';
import 'package:location_alarm/core/constant_data.dart';
import 'package:location_alarm/core/notification_utils.dart';
import 'package:location_alarm/domain/entities/travel/travel_entity.dart';
import 'package:location_alarm/presentation/widgets/custom_app_bar.dart';
import 'package:location_alarm/presentation/widgets/custom_drawer.dart';

class History extends StatefulWidget {
  static const routeName = 'history';
  Box<TravelEntity>? db;
  List<TravelEntity>? travels;

  History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    widget.travels = widget.db?.values.toList().cast<TravelEntity>();
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(
        title: 'History',
        actions: [
          InkWell(
            child: Container(
                margin: const EdgeInsets.all(5),
                child: Icon(Icons.refresh_sharp,
                    color: theme.colorScheme.secondary, size: 30)),
            onTap: _refreshRecords,
          ),
          if (widget.travels != null && widget.travels!.isNotEmpty)
            InkWell(
              child: Container(
                margin: const EdgeInsets.all(15),
                child: Icon(
                  Icons.delete_sharp,
                  color: theme.errorColor,
                ),
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          content: Text(
                            "Are you sure you want to delete the whole history?",
                            style: theme.textTheme.titleMedium,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                "No",
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await Hive.box<TravelEntity>(
                                        ConstantData.travelsDatabaseName)
                                    .clear();
                                setState(() {});
                              },
                              child: Text(
                                "YES",
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(color: theme.errorColor),
                              ),
                            ),
                          ],
                        ));
              },
            ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: widget.travels == null
            ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
            : widget.travels!.isEmpty
                ? Center(
                    child: Text(
                      'There is no travel record',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: theme.errorColor,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshRecords,
                    child: ListView.builder(
                      itemBuilder: (_, index) {
                        final record = widget.travels![index];

                        final String destinationLat =
                            record.destinationLat.toString();
                        final String destinationLong =
                            record.destinationLong.toString();

                        return InkWell(
                          onTap: () async {
                            final service =
                                BackgroundServiceUtils.instance.backService;
                            if (!(await BackgroundServiceUtils.instance.isTracingTravel)) {
                              if (!(await service.isRunning())) {
                                await service.startService();
                              }
                              final travel = widget.travels![index];
                              service.invoke(
                                  ConstantData.chasingLocationTaskName, {
                                'destinationLat': travel.destinationLat,
                                'destinationLon': travel.destinationLong,
                                'consideredDistance': travel.consideredDistance,
                                'count': 1,
                                'showNotif': false,
                              });

                              Navigator.of(context).pop();
                            } else {
                              NotificationUtils.showNotification(
                                  body:
                                      'you have a registered trip first cancel it');
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 1,
                                color: theme.backgroundColor,
                              ),
                            ),
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 0),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "destination name: ${record.destinationName}",
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "destination latitude: $destinationLat",
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "destination Longitude: $destinationLong",
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "date: ${record.date.toString()}",
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Considered distance: ${record.consideredDistance.toStringAsFixed(2)}",
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: widget.travels?.length ?? 0,
                    ),
                  ),
      ),
    );
  }

  @override
  void dispose() {
    widget.db?.close();
    super.dispose();
  }

  @override
  void initState() {
    Hive.openBox<TravelEntity>(ConstantData.travelsDatabaseName).then((value) {
      setState(() {
        widget.db = value;
      });
    });
    super.initState();
  }

  Future<void> _refreshRecords() async {
    widget.db =
        await Hive.openBox<TravelEntity>(ConstantData.travelsDatabaseName);
    widget.travels = widget.db?.values.toList().cast<TravelEntity>();
    setState(() {});
  }
}
