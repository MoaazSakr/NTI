import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class Task {
  String? createdAt;
  String? discription;
  int? id;
  String? imagePath;
  String? title;

  Task({this.createdAt, this.discription, this.id, this.imagePath, this.title});

  Task.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    discription = json['description'];
    id = json['id'];
    imagePath = json['image_path'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'description': discription,
      'id': id,
      'image_path': imagePath,
      'title': title,
    };
  }
}

var dio = Dio(
  BaseOptions(baseUrl: 'https://ntitodo-production-779a.up.railway.app/api/'),
);
void displayAuthMenu(Map<String, dynamic> userData) {
  if (userData['access_token'] == null) {
    print('1. login');
    print('2. register');
    print('3. exit');
  } else {
    print('1.login');
    print('2. register');
    print('3. get user data');
    print('4. delete user');
    print('5. change password');
    print('6. go to tasks menu');
    print('7. exit');
  }
}

void displayTasksMenu(userData) {
  print('1. get tasks');
  print('2. add task');
  print('3. update task');
  print('4. delete task');
  print('5. exit');
}

T userInput<T>(T? Function(String input) validator) {
  while (true) {
    String input = stdin.readLineSync() ?? "";
    T? result = validator(input);
    if (result != null) {
      return result;
    }
  }
}

String? validateNonEmpty(String input) {
  if (input.isNotEmpty) {
    return input;
  }
  return null;
}

Future<Either<String, Map<String, dynamic>>> login() async {
  print("Enter username");
  String username = userInput(validateNonEmpty);
  print("Enter password");
  String password = userInput(validateNonEmpty);

  try {
    var loginResponse = await dio.post(
      'login',
      data: FormData.fromMap({'username': username, 'password': password}),
    );
    var successResponse = loginResponse.data as Map<String, dynamic>;
    return Right(successResponse);
  } catch (e) {
    if (e is DioException) {
      var errorResponse = e.response?.data as Map<String, dynamic>;
      return Left(errorResponse['message'] ?? 'Unknown error');
    } else {
      return Left('An Error occurred.\nTry again later');
    }
  }
}

Future<Either<String, String>> register() async {
  print("Enter username");
  String username = userInput(validateNonEmpty);
  print("Enter password");
  String password = userInput(validateNonEmpty);

  try {
    var registerResponse = await dio.post(
      'register',
      data: FormData.fromMap({'username': username, 'password': password}),
    );
    var successResponse = registerResponse.data as Map<String, dynamic>;
    return Right(successResponse['message'] ?? 'Registration successful');
  } catch (e) {
    if (e is DioException) {
      var errorResponse = e.response?.data as Map<String, dynamic>;
      return Left(errorResponse['message'] ?? 'Unknown error');
    } else {
      return Left('An Error occurred.\nTry again later');
    }
  }
}
Future<Either<String, Map<String, dynamic>>> getUserData(
  String accessToken,
) async {
  try {
    var registerResponse = await dio.get(
      'get_user_data',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    var userData = registerResponse.data as Map<String, dynamic>;
    return Right(userData);
  } catch (e) {
    if (e is DioException) {
      var errorResponse = e.response?.data as Map<String, dynamic>;
      return Left(errorResponse['message'] ?? 'Unknown error');
    } else {
      return Left('An Error occurred.\nTry again later');
    }
  }
}
Future<Either<String, String>> deleteUser(
  String accessToken,
) async {
  try {
    var registerResponse = await dio.delete(
      'delete_user',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    var successResponse = registerResponse.data as Map<String, dynamic>;
    return Right(successResponse['message'] ?? 'User deleted successfully');
  } catch (e) {
    if (e is DioException) {
      var errorResponse = e.response?.data as Map<String, dynamic>;
      return Left(errorResponse['message'] ?? 'Unknown error');
    } else {
      return Left('An Error occurred.\nTry again later');
    }
  }
}
Future<Either<String, String>> changePassword(
  String accessToken,
) async {
  try {
    var registerResponse = await dio.post(
      'change_password',
      data: FormData.fromMap({'current_password': userInput(validateNonEmpty)
      ,'new_password': userInput(validateNonEmpty)
      ,'new_password_confirm': userInput(validateNonEmpty)
      }),
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    var successResponse = registerResponse.data as Map<String, dynamic>;
    return Right(successResponse['message'] ?? 'Password changed successfully');
  } catch (e) {
    if (e is DioException) {
      var errorResponse = e.response?.data as Map<String, dynamic>;
      return Left(errorResponse['message'] ?? 'Unknown error');
    } else {
      return Left('An Error occurred.\nTry again later');
    }
  }
}

void main() async {
  Map<String, dynamic> userData = await auth();
  print(userData.toString());

  while (true) {
    displayTasksMenu(userData);
    int mainChoice = userInput((String input) {
      int? choice = int.tryParse(input);
      if (choice != null) {
        if (choice >= 1 && choice <= 5) {
          return choice;
        }
      }
      return null;
    });

    if (mainChoice == 1) {
      var tasksResponse = await getTasks(userData['access_token']);
      tasksResponse.fold(
        (String errorMsg) {
          print("Failed to fetch tasks: $errorMsg");
        },
        (List<Task> tasks) {
          for (var task in tasks) {
            print(task.id);
            print(task.title);
            print(task.discription);
            print(task.imagePath);
            print(task.createdAt);
            print('----------------');
          }
        },
      );
    } else if (mainChoice == 2) {
      var addTaskResponse = await addTask(userData['access_token']);
      addTaskResponse.fold(
        (String errorMsg) {
          print("Failed to add task: $errorMsg");
        },
        (String successMsg) {
          print(successMsg);
        },
      );
    } else if (mainChoice == 3) {
      var updateTaskResponse = await updateTask(userData['access_token']);
      updateTaskResponse.fold(
        (String errorMsg) {
          print("Failed to update task: $errorMsg");
        },
        (Map<String, dynamic> updatedTask) {
          print(updatedTask.toString());
        },
      );
    } else if (mainChoice == 4) {
      var deleteTaskResponse = await deleteTask(userData['access_token']);
      deleteTaskResponse.fold(
        (String errorMsg) {
          print("Failed to delete task: $errorMsg");
        },
        (Map<String, dynamic> deletedTask) {
          print(deletedTask.toString());
        },
      );
    } else if (mainChoice == 5) {
      print("See you later!");
      exit(0);
    }
  }
}

Future<Either<String, Map<String, dynamic>>> deleteTask(
  String accessToken,
) async {
  int taskId = userInput((String input) {
    int? choice = int.tryParse(input);
    if (choice != null) {
      if (choice > 0) {
        return choice;
      }
    }
    return null;
  });
  try {
    var deleteResponse = await dio.delete(
      'tasks/$taskId',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return Right(deleteResponse.data as Map<String, dynamic>);
  } catch (e) {
    if (e is DioException) {
      var errorResponse = e.response?.data as Map<String, dynamic>;
      return Left(errorResponse['message'] ?? 'Unknown error');
    } else {
      print(e.toString());
      return Left('An Error occurred.\nTry again later');
    }
  }
}

Future<Either<String, Map<String, dynamic>>> updateTask(
  String accessToken,
) async {
  int taskId = userInput((String input) {
    int? choice = int.tryParse(input);
    if (choice != null) {
      if (choice > 0) {
        return choice;
      }
    }
    return null;
  });
  String newTitle = userInput(validateNonEmpty);
  String newDescription = userInput(validateNonEmpty);

  try {
    var updateResponse = await dio.put(
      'tasks/$taskId',
      data: FormData.fromMap({
        'title': newTitle,
        'description': newDescription,
      }),
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return Right(updateResponse.data as Map<String, dynamic>);
  } catch (e) {
    if (e is DioException) {
      var errorResponse = e.response?.data as Map<String, dynamic>;
      return Left(errorResponse['message'] ?? 'Unknown error');
    } else {
      print(e.toString());
      return Left('An Error occurred.\nTry again later');
    }
  }
}

Future<Either<String, String>> addTask(String accessToken) async {
  String newTitle = userInput(validateNonEmpty);
  String newDescription = userInput(validateNonEmpty);
  Task newTask = Task(title: newTitle, discription: newDescription);

  try {
    var addResponse = await dio.post(
      'new_task',
      data: FormData.fromMap(newTask.toJson()),
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    var response = addResponse.data as Map<String, dynamic>;

    return Right(response['message'] ?? 'Task added successfully');
  } catch (e) {
    if (e is DioException) {
      var errorResponse = e.response?.data as Map<String, dynamic>;
      return Left(errorResponse['message'] ?? 'Unknown error');
    } else {
      print(e.toString());
      return Left('An Error occurred.\nTry again later');
    }
  }
}

Future<Either<String, List<Task>>> getTasks(String accessToken) async {
  try {
    var registerResponse = await dio.get(
      'my_tasks',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    var tasksResponse = registerResponse.data as Map<String, dynamic>;
    List<Task> tasks = [];
    for (var taskJson in tasksResponse['tasks']) {
      tasks.add(Task.fromJson(taskJson));
    }
    return Right(tasks);
  } catch (e) {
    if (e is DioException) {
      var errorResponse = e.response?.data as Map<String, dynamic>;
      return Left(errorResponse['message'] ?? 'Unknown error');
    } else {
      print(e.toString());
      return Left('An Error occurred.\nTry again later');
    }
  }
}

Future<Map<String, dynamic>> auth() async {
  Map<String, dynamic> userData = {};
  while (true) {
    displayAuthMenu(userData);
    int authChoice = userInput((String input) {
      int? choice = int.tryParse(input);
      if (userData['access_token'] == null) {
        if (choice != null) {
          if (choice >= 1 && choice <= 3) {
            return choice;
          }
        }
      } else if (userData['access_token'] != null) {
        if (choice != null) {
          if (choice >= 1 && choice <= 7) {
            return choice;
          }
        }
      }
      return null;
    });
    if (userData['access_token'] == null) {
      if (authChoice == 1) {
        var result = await login();
        result.fold(
          (String errorMsg) {
            print("Login Failed: $errorMsg");
          },
          (Map<String, dynamic> userResponse) {
            userData = userResponse;
            print('Login successful');
          }
        );
      } else if (authChoice == 2) {
        var result = await register();
        result.fold(
          (String errorMsg) {
            print("Registration Failed: $errorMsg");
          },
          (String successMsg) {
            print(successMsg);
          }
        );
      } else {
        print("See you later!");
        exit(0);
      }
    } else {
      if (authChoice == 1) {
        var result = await login();
        result.fold(
          (String errorMsg) {
            print("Login Failed: $errorMsg");
          },
          (Map<String, dynamic> userResponse) {
            userData = userResponse;
          },
        );
        
      } else if (authChoice == 2) {
        var result = await register();
        result.fold(
          (String errorMsg) {
            print("Registration Failed: $errorMsg");
          },
          (String successMsg) {
            print(successMsg);
          },
        );
      } else if (authChoice == 3) {
        var result = await getUserData(userData['access_token']);
        result.fold(
          (String errorMsg) {
            print("Failed to fetch user data: $errorMsg");
          },
          (Map<String, dynamic> userData) {
            print(userData.toString());
          },
        );
      } else if (authChoice == 4) {
        var result = await deleteUser(userData['access_token']);
        result.fold(
          (String errorMsg) {
            print("Failed to delete user: $errorMsg");
          },
          (String successMsg) {
            print(successMsg);
          },
        );
      } else if (authChoice == 5) {
        var result = await changePassword(userData['access_token']);
        result.fold(
          (String errorMsg) {
            print("Failed to change password: $errorMsg");
          },
          (String successMsg) {
            print(successMsg);
          },
        );
      } else if (authChoice == 6) {
        displayTasksMenu(userData['access_token']);
        break;
      } else if (authChoice == 7) {
        print("See you later!");
        exit(0);
      }
    }
  }
  return userData;
}



  /*
  1. login 
  2. register


  1. get tasks
  2. add task
  3. update task
  4. delete task
  */


  // try{
  //   var newTaskResponse = await dio.post(
  //     'new_task', 
  //     data: FormData.fromMap({
  //     'title': 'task 001',
  //     'description': 'description of task 001',
  //     }),
  //     options: Options(
  //       headers: {
  //         'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTc3MjI2NDAzMSwianRpIjoiNGE3Y2IwNWMtMzA2OS00MGU3LTk0NTctY2NiMGIwOWVmMjNlIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6MywibmJmIjoxNzcyMjY0MDMxLCJjc3JmIjoiOGY4ODE3YTAtY2EwNy00NWMzLWIxYzMtZWE0MDdjYTJlNDIzIiwiZXhwIjoxNzcyMjY0OTMxfQ.E509X_myu3gXkEdIok1xsbU-ptmx-mv2CGlKGWgiD_Q'
  //       }
  //     )
  //   );

  //   print(newTaskResponse.data.toString());
  // }
  // catch(e){
  //   if(e is DioException){
  //     print(e.response?.data.toString());
  //   }
  //   else{
  //     print(e.toString());
  //   }
  // }












  // try{
  //   var loginReposne =  await dio.post('login', data: FormData.fromMap({
  //     'username': 'ahmed',
  //     'password': '12345678'
  //   }));
  //   print(loginReposne.data.toString());
  // }
  // catch(e){
  //   if(e is DioException ){
  //     print(e.response.toString());
  //   }
  //   else {
  //     print(e.toString());
  //   }
  // }

  // try{
  //   var tasksReposne =  await dio.get('my_tasks', options: Options(
  //     headers: {
  //       'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTc3MjIwMDA2NSwianRpIjoiOGQ2NDRmMTMtNWQ5NC00YmM5LWI4MGQtMzM4N2QyM2E4NDljIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6MywibmJmIjoxNzcyMjAwMDY1LCJjc3JmIjoiOWNiNjUzYjUtYzZjOC00M2Q1LTgzYjctNjExNDE1N2E5ZGRlIiwiZXhwIjoxNzcyMjAwOTY1fQ.NzDtJr5r-2CuRR54NWAvTsKTAU-xdnFYgTIypqayyrk'
  //     }
  //   ));
  //   print(tasksReposne.data.toString());
  // }
  // catch(e){
  //   if(e is DioException ){
  //     print(e.response.toString());
  //   }
  //   else {
  //     print(e.toString());
  //   }
  // }

  // try{
  //   var loginReposne =  await dio.post('register', data: FormData.fromMap({
  //     'username': 'ahmed',
  //     'password': '12345678',
  //   }));
  //   print(loginReposne.data.toString());
  // }
  // catch(e){
  //   if(e is DioException ){
  //     print(e.response.toString());
  //   }
  //   else {
  //     print(e.toString());
  //   }
  // }