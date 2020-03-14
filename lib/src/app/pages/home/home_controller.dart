import './home_presenter.dart';
import '../../../domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

class HomeController extends Controller {
  User _currentUser;
  User get currentUser => _currentUser;
  final HomePresenter homePresenter;
  // Presenter should always be initialized this way
  HomeController(usersRepo)
      : homePresenter = HomePresenter(usersRepo),
        super();

  @override
  // this is called automatically by the parent class
  void initListeners() {
    homePresenter.getNextUserOnNext = (User user) {
      print(user.toString());
      _currentUser = user;
      refreshUI(); // Refreshes the UI manually
    };
    homePresenter.getNextUserOnComplete = () {
      print('User retrieved');
    };

    // On error, show a snackbar, remove the user, and refresh the UI
    homePresenter.getNextUserOnError = (e) {
      print('Could not retrieve next user.');
      ScaffoldState state = getState();
      state.showSnackBar(SnackBar(content: Text(e.message)));
      _currentUser = null;
      refreshUI(); // Refreshes the UI manually
    };
  }

  void getNextUser() =>
    homePresenter.getNextUser(_currentUser == null ? -1 : _currentUser.sequence);

  void buttonPressed() {
    getNextUser();
    refreshUI();
  }

  @override
  void onResumed() {
    print("On resumed");
    super.onResumed();
  }

  @override
  void dispose() {
    homePresenter.dispose(); // don't forget to dispose of the presenter
    super.dispose();
  }
}