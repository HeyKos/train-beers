import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:image_picker/image_picker.dart';
import 'package:train_beers/src/data/repositories/firebase_files_repository.dart';
import 'package:train_beers/src/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:train_beers/src/data/repositories/firebase_users_repository.dart';
import 'profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends View {
  final String title;
  final UserEntity user;
  
  ProfilePage({
    Key key,
    this.title,
    @required this.user,
  }) : super(key: key);
  

  @override
  // inject dependencies inwards
  _ProfilePageState createState() => _ProfilePageState(user);
}

class _ProfilePageState extends ViewState<ProfilePage, ProfileController> {
  _ProfilePageState(user): 
    super(ProfileController(FirebaseFilesRepository(), FirebaseUsersRepository(), user));

  @override
  Widget buildPage() {
    String name = controller.user != null ? controller.user.name : "";
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Scaffold(
        key: globalKey, // built in global key for the ViewState for easy access in the controller
        body: Container(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    color: Colors.blueAccent,
                    height: 115.0,
                  ),
                  nameText(name),
                  avatarImage,
                  updateAvatarButton,
                  saveAvatarButton,
                ],
              ),
            ],
          )
        ),
      ),
    );
  } 

  /// Properties (Widgets)
  Widget get avatarImage => Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 65.0),
    child: Conditional.single(
      context: context,
      conditionBuilder: (BuildContext context) => controller.avatarPath != null || controller.userAvatar != null,
      widgetBuilder: (BuildContext context) {
        return Conditional.single(
          context: context,
          conditionBuilder: (BuildContext context) => controller.userAvatar != null,
          widgetBuilder: (BuildContext context) {
            return ClipRRect( 
              borderRadius: BorderRadius.circular(75.0),
              child: Image(
                height: 100.0,
                width: 100.0,
                image: FileImage(controller.userAvatar),
              )
            );
          },
          fallbackBuilder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(55.0)),
                border: Border.all(
                  color: Colors.white,
                  width: 5.0,
                )
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: CachedNetworkImage(
                  imageUrl: controller.avatarPath,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  width: 100.0,
                  height: 100.0,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      },
      fallbackBuilder: (BuildContext context) => CircularProgressIndicator(),
    ),
  );
  
  Widget get avatarSavingButton => StreamBuilder<StorageTaskEvent>(
    stream: controller.uploadTask.events,
    builder: (_, snapshot) {
      var event = snapshot?.data?.snapshot;

      if (controller.uploadTask.isComplete) {
        controller.uploadStatusOnChange(event);
      }

      return Container(
        alignment: Alignment(.85, 1),
        padding: EdgeInsets.only(top: 120.0),
        child: FlatButton(
          color: Colors.white,
          padding: EdgeInsets.all(10.0),
          child: Text("Saving...", 
            style: TextStyle(
              color: Colors.blueAccent,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.blueAccent)
          ),
          onPressed: () => {},
        ),
      );
    }
  );
  
  Widget buildProfileImageDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FlatButton(
            child: Row(
              children: <Widget>[
                Icon(Icons.photo_camera),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text("Take a photo", 
                    style: TextStyle(
                      fontSize: 20.0
                    ),
                  ),
                )
              ],
            ),
            onPressed: () => controller.pickImage(ImageSource.camera),
          ),
          FlatButton(
            child: Row(
              children: <Widget>[
                Icon(Icons.photo_library),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text("Choose a photo",
                     style: TextStyle(
                      fontSize: 20.0
                    ),
                  ),
                )
              ],
            ),
            onPressed: () => controller.pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Widget nameText(name) => Center(
    child: Container(
      padding: EdgeInsets.only(top: 15.0),
      child: Text(name,
        style: TextStyle(
          color: Colors.white54,
          fontSize: 30.0
        ),
      ),
    ),
  );
  
  Widget get saveAvatarButton => Conditional.single(
    context: context,
    conditionBuilder: (BuildContext context) => controller.userAvatar != null,
    widgetBuilder: (BuildContext context) => Conditional.single(
      context: context,
      conditionBuilder: (BuildContext context) => !controller.isProcessing,
      widgetBuilder: (BuildContext context) => Container(
        alignment: Alignment(.85, 1),
        padding: EdgeInsets.only(top: 120.0),
        child: FlatButton(
          color: Colors.white,
          padding: EdgeInsets.all(10.0),
          child: Text("Save Changes", 
            style: TextStyle(
              color: Colors.blueAccent
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.blueAccent)
          ),
          onPressed: controller.saveAvatar,
        ),
      ),
      fallbackBuilder: (BuildContext context) => avatarSavingButton,
    ),
    fallbackBuilder: (BuildContext context) => Container(
      height: 0.0,
      width: 0.0,
    )
  );

  Widget get updateAvatarButton => Conditional.single(
    context: context,
    conditionBuilder: (BuildContext context) => controller.userAvatar == null,
    widgetBuilder: (BuildContext context) => Container(
      alignment: Alignment(.85, 1),
      padding: EdgeInsets.only(top: 120.0),
      child: FlatButton(
        color: Colors.white,
        padding: EdgeInsets.all(10.0),
        child: Text("Update Avatar", 
          style: TextStyle(
            color: Colors.blueAccent
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(18.0),
          side: BorderSide(color: Colors.blueAccent)
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => buildProfileImageDialog(context),
          );
        },
      ),
    ),
    fallbackBuilder: (BuildContext context) => Container(width: 0, height: 0),
  );
}
