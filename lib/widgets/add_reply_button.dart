import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tweety_mobile/blocs/children_reply/children_reply_bloc.dart';
import 'package:tweety_mobile/models/tweet.dart';
import 'package:tweety_mobile/repositories/reply_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tweety_mobile/blocs/reply/reply_bloc.dart';
import 'package:tweety_mobile/screens/tweet_wrapper.dart';
import 'package:tweety_mobile/services/reply_api_client.dart';
import 'package:tweety_mobile/screens/add_reply_screen.dart';

class AddReplyButton extends StatelessWidget {
  final Tweet tweet;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AddReplyButton({Key key, @required this.tweet, this.scaffoldKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReplyRepository replyRepository = ReplyRepository(
      replyApiClient: ReplyApiClient(httpClient: http.Client()),
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<ReplyBloc>(
          create: (context) => ReplyBloc(replyRepository: replyRepository),
        ),
        BlocProvider<ChildrenReplyBloc>(
          create: (context) =>
              ChildrenReplyBloc(replyRepository: replyRepository),
        ),
      ],
      child: AddReplyButtonWidget(
        tweet: tweet,
        replyRepository: replyRepository,
        scaffoldKey: scaffoldKey,
      ),
    );
  }
}

class AddReplyButtonWidget extends StatefulWidget {
  final Tweet tweet;
  final ReplyRepository replyRepository;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const AddReplyButtonWidget(
      {Key key, @required this.tweet, this.replyRepository, this.scaffoldKey})
      : super(key: key);

  @override
  _AddReplyButtonWidgetState createState() => _AddReplyButtonWidgetState();
}

class _AddReplyButtonWidgetState extends State<AddReplyButtonWidget> {
  int get repliesCount => widget.tweet.repliesCount;
  set repliesCount(int repliesCount) =>
      widget.tweet.repliesCount = repliesCount;
  ReplyBloc _replyBloc;
  @override
  void initState() {
    super.initState();
    _replyBloc = BlocProvider.of<ReplyBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ReplyBloc, ReplyState>(
          listener: (context, state) {
            if (state is ReplyAdded) {
              setState(() {
                repliesCount++;
              });

              var currentState = widget.scaffoldKey == null
                  ? Scaffold.of(context)
                  : widget.scaffoldKey.currentState;

              currentState
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    backgroundColor: Theme.of(context).primaryColor,
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Your reply was added!"),
                      ],
                    ),
                    action: SnackBarAction(
                        label: 'View',
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  TweetWrapper(tweet: widget.tweet),
                            ),
                          );
                        }),
                  ),
                );
            }
            if (state is AddReplyError) {
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    elevation: 6.0,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    backgroundColor: Colors.red,
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Couldn't add reply."),
                      ],
                    ),
                  ),
                );
            }
          },
        ),
        BlocListener<ChildrenReplyBloc, ChildrenReplyState>(
          listener: (context, state) {
            if (state is ChildrenReplyAdded) {
              repliesCount++;
            }
          },
        ),
      ],
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: _replyBloc,
                child: AddReplyScreen(
                  tweet: widget.tweet,
                ),
              ),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            repliesCount > 0
                ? Padding(
                    padding: EdgeInsets.only(right: 3.0),
                    child: Text(
                      repliesCount.toString(),
                      style: TextStyle(
                        color: Color(0xFFA0AEC0),
                      ),
                    ),
                  )
                : Container(),
            Icon(
              Icons.comment,
              size: 18.0,
              color: Color(0xFFA0AEC0),
            ),
          ],
        ),
      ),
    );
  }
}