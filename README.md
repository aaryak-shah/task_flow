# TaskFlow

TaskFlow is a Flutter application to track and boost your productivity! 

* You can create tasks, projects and goals using the app and track your time utilization throughout the day. 
* Create an account, or use the app as a guest to get started.
* After creating some tasks, goals and projects, you can use the Statistics section of the app to visualize your data and get insights about it. The data analysis is performed using a Flask API.

This app is still under development.

# How to set up the project
* Clone this repository to your computer
* Create a new [Firebase project](https://console.firebase.google.com)
* Add an Android app to the project, with the package name "com.aash.task_flow"
* Download the google-services.json file and add it to task_flow/android/app/
* Obtain a Debug SHA1 key using Android Studio, and add it to the Firebase console
* Then install the app's dependencies as follows:
```sh
cd task_flow/
flutter pub get
```
* Finally, start the app on a connected device using:
```sh
flutter run
```

# Screenshots
## Splash Screen & Main Drawer
<p>
  <img src="https://github.com/aaryak-shah/task_flow/blob/master/screenshots/splash_screen.jpg" width="300">
  <img src="https://github.com/aaryak-shah/task_flow/blob/master/screenshots/main_drawer.jpg" width="300">
</p>

## Creating a Task 
<p>
  <img src="https://github.com/aaryak-shah/task_flow/blob/master/screenshots/new_task.jpg" width="300">
  <img src="https://github.com/aaryak-shah/task_flow/blob/master/screenshots/current_task_screen.jpg" width="300">
  <img src="https://github.com/aaryak-shah/task_flow/blob/master/screenshots/tasks_screen.jpg" width="300">
</p>

## Creating a Goal
<p>
  <img src="https://github.com/aaryak-shah/task_flow/blob/master/screenshots/new_goal.jpg" width="300">
  <img src="https://github.com/aaryak-shah/task_flow/blob/master/screenshots/current_goal_screen.jpg" width="300">
</p>

## Creating a Project
<p>
  <img src="https://github.com/aaryak-shah/task_flow/blob/master/screenshots/new_project.jpg" width="300">
  <img src="https://github.com/aaryak-shah/task_flow/blob/master/screenshots/projects_screen.jpg" width="300">
</p>

## Settings
<p>
  <img src="https://github.com/aaryak-shah/task_flow/blob/master/screenshots/settings.jpg" width="300">
</p>
