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
    int? choice = userInput(1);
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

dynamic userInput(int? type) {
  String? input=stdin.readLineSync()??'';
  if(type.toString().isNotEmpty){
   while (type == 1) {
    int? input1 = int.tryParse(input);
    if (input1 != null && input1 >= 0 && input1 <= 5) {
      return input1;
    }
    else {
      print("Invalid input");
      return userInput(type);
    }
  }
  while (type == 2) {
    if (input.toString().isEmpty) {
      print("Invalid input");
      return userInput(type);
    }
    else return input;
  }
  while (type == 3) {
    if (input.toString().isEmpty) {
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
  int? row = userInput(1);
  print('Enter seat Column: ');
  int? column = userInput(1);
  if(seats[row??0][column??0] == false){
  print('Enter name: ');
  String? name = userInput(2);
  print('Enter phone: ');
  String? phone = userInput(2);
  bookings[[row??0, column??0]] = {'name': name??' ', 'phone': phone??' '};
  print('Booking successful');
  seats[row??0][column??0] = true;
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
