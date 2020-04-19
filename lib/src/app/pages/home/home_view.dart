import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:train_beers/src/app/utils/constants.dart';
import 'package:train_beers/src/app/widgets/countdown_timer.dart';
import 'package:train_beers/src/data/repositories/firebase_authenticaion_repository.dart';
import 'package:train_beers/src/data/repositories/firebase_event_participants_repository.dart';
import 'package:train_beers/src/data/repositories/firebase_events_repository.dart';
import 'package:train_beers/src/data/repositories/firebase_files_repository.dart';
import 'package:train_beers/src/domain/entities/user_entity.dart';
import './home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:train_beers/src/data/repositories/firebase_users_repository.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';

class HomePage extends View {
  final String title;
  final UserEntity user;
  
  HomePage({
    Key key,
    this.title,
    @required this.user,
  }) : super(key: key);
  

  @override
  // inject dependencies inwards
  _HomePageState createState() => _HomePageState(user);
}

class _HomePageState extends ViewState<HomePage, HomeController> {
  _HomePageState(user) : super(HomeController(
    FirebaseFilesRepository(),
    FirebaseUsersRepository(),
    FirebaseAuthenticationRepository(),
    FirebaseEventsRepository(),
    FirebaseEventParticipantsRepository(),
    user));

  /// Overrides
  @override
  Widget buildPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: controller.onMenuOptionChange,
            itemBuilder: getMenuItems,
          ),
        ],
      ),
      body: Scaffold(
        key: globalKey, // built in global key for the ViewState for easy access in the controller
        body: Container(
          child: Column(
            children: <Widget>[
              countdownWidget,
              drinkingStatusContainer,
              nextTrainBeerBuyer,
              Text(controller.event != null ? controller.event.status : ""),
              activeDrinkers,
            ],
          ),
        ),
      ),
    );
  } 

  /// Methods
  Widget drinkingStatusText(bool isActive) {
    return Text(
      controller.user != null ? controller.user.getActiveStatusMessage() : "",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isActive ? Colors.black : Colors.white,
        fontSize: 20.0,
      ),
    );
  }
  
  List<PopupMenuItem<String>> getMenuItems(BuildContext context) {
    return Constants.homeMenuOptions.map((String option) {
      return PopupMenuItem<String>(
        value: option,
        child: Text(option),
      );
    }).toList();    
  }

  /// Properties (Widgets)
  Widget get countdownWidget => Conditional.single(
    context: context,
    conditionBuilder: (BuildContext context) => controller.shouldDisplayCountdown(),
    widgetBuilder: (BuildContext context) {
      return CountDownTimer();
    },
    fallbackBuilder: (BuildContext context) {
      return ColorizeAnimatedTextKit(
        text: [
          "WE'RE DRINKING!",
          "BEER IS LIFE!",
          "CHECK PLEASE!",
        ],
        isRepeatingAnimation: true,
        textStyle: TextStyle(
            fontSize: 40.0, 
            fontFamily: "Horizon"
        ),
        colors: [
          Colors.red,
          Colors.orange,
          Colors.purple,
          Colors.green,
          Colors.yellow,
          Colors.blue,
        ],
        textAlign: TextAlign.start,
        alignment: AlignmentDirectional.topStart
      );
    }
  );

  Widget get nextTrainBeerBuyer {
    return Container(
      padding: new EdgeInsets.only(top: 20.0),
      child: Column(
        children: <Widget>[
          Text(
            "This Week's Buyer",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(75.0),
                child: Conditional.single(
                  context: context,
                  conditionBuilder: (BuildContext context) => controller.avatarPath != null,
                  widgetBuilder: (BuildContext context) {
                    return CachedNetworkImage(
                      imageUrl: controller.avatarPath,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      width: 100.0,
                      height: 100.0,
                    );
                  },
                  fallbackBuilder: (BuildContext context) => CircularProgressIndicator(),
                ),
              )
            ),
          ),
          Text(
            controller.event != null && controller.event.hostUser != null ? "${controller.event.hostUser.name}" : "",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget get activeDrinkers {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 40.0),
            child: Text(
              controller.participants != null ? "There are ${controller.participants.length} people drinking this week." : "",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
              ),
            ),
          ),
          activeDrinkerListButton,
        ],
      ),
    );
  }

  Widget get activeDrinkerListButton => FlatButton (
    onPressed: controller.goToActiveDrinkers,
    child: Text(
      "View Drinkers",
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0
      ),
    ),
    color: Colors.blueAccent,
  );

  Widget get drinkingStatusContainer {  
    bool isActive = controller.user != null && controller.user.isActive;
    return Container(
      color: isActive ? Colors.greenAccent : Colors.redAccent,
      height: 40.0,
      alignment: Alignment.topLeft,
      child: Center(
        child: drinkingStatusText(isActive),
      ),
    );
  }
}
