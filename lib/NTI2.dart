// booked => true
// empty => false
import 'dart:io';

void main() {
  List<List<bool>> seats = List.generate(
    5,
    (int index) => List.filled(5, false),
  );
  Map<List<int>, Map<String, String>> bookings = {};

  bool flag = true;
  while (flag) {
    displayOptions();
    late int choice = userInput(1);
    switch (choice) {
      case 1:
        displaySeats(seats);
      case 2:
        newBook(bookings, seats);
      case 3:
        displayBookings(bookings);
      case 4:
        flag = false;
      default:
        print("Invalid choice");
    }
  }
}

void displayOptions() {
  print("1. Display Seats");
  print("2. New Booking");
  print("3. Display Bookings");
  print("4. Exit");
  print("Enter your choice: ");
}

dynamic userInput(int type) {
  dynamic input;
  if(type.toString().isNotEmpty){
   while (type == 1) {
    input = int.parse(stdin.readLineSync()!);
    if (input < 0 || input > 5 || input.toString().isEmpty) {
      print("Invalid input");
      return userInput(type);
    }
    else return input;
  }
  while (type == 2) {
    input = stdin.readLineSync()!;
    if (input.toString().isEmpty) {
      print("Invalid input");
      return userInput(type);
    }
    else return input;
  }
  while (type == 3) {
    input = bool.parse(stdin.readLineSync()!);
    if (input != true || input != false || input.toString().isEmpty) {
      print("Invalid input");
      return userInput(type);
    }else return input;
  }
  return type;
  }
  else{
    print("Invalid input");
    return userInput(type);
  }
}

void displaySeats(List<List<bool>> seats) {
  print(seats);
}

void newBook(
  Map<List<int>, Map<String, String>> bookings,
  List<List<bool>> seats,
) {
  print('Enter seat Row: ');
  int row = userInput(1);
  print('Enter seat Column: ');
  int column = userInput(1);
  if(seats[row][column] == false){
  print('Enter name: ');
  String name = userInput(2);
  print('Enter phone: ');
  String phone = userInput(2);
  bookings[[row, column]] = {'name': name, 'phone': phone};
  print('Booking successful');
  seats[row][column] = true;
  displaySeats(seats);
  }
  else{
  print("Seat is already booked");
    return;
  }
}

void displayBookings(Map<List<int>, Map<String, String>> bookings) {
  print(bookings);
}
