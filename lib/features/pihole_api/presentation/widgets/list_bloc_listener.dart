import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/blocs/list_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/list_response.dart';
import 'package:flutterhole/widgets/layout/notifications/snackbars.dart';

class ListBlocListener extends StatelessWidget {
  const ListBlocListener({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListBloc, ListBlocState>(
      listener: (context, state) {
        state.failureOption.fold(
          () {},
          (Failure f) {
            showErrorSnackBar(context, '${f.message ?? f}');
          },
        );

        state.responseOption.fold(
          () {},
          (ListResponse r) {
            final String message =
                r.message ?? (r.success ? 'Success!' : 'Something went wrong.');
            showInfoSnackBar(context, '$message');
          },
        );
      },
      child: child,
    );
  }
}
