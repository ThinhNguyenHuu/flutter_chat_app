// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:convert';
import '../dto/user.dart';
import '../dto/message.dart';

class ChatModel extends Model {
  List<User> users = [
    User('IronMan', '111'),
    User('Captain America', '222'),
    User('Antman', '333'),
    User('Hulk', '444'),
    User('Thor', '555'),
  ];
  late User currentUser;
  List<User> friendList = [];
  List<Message> messages = [];
  late SocketIO socketIO;
  void init() {
    currentUser = users[0];
    friendList = users.where((user) => user.chatID != currentUser.chatID).toList();
    socketIO = SocketIOManager().createSocketIO('http://localhost:8000', '/', query: 'chatID=${currentUser.chatID}');
    socketIO.init();
    socketIO.subscribe('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      messages.add(Message(data['content'], data['senderChatID'], data['receiverChatID']));
      notifyListeners();
    });
    socketIO.connect();
  }

  void sendMessage(String text, String receiverChatID) {
    messages.add(Message(text, currentUser.chatID, receiverChatID));
    socketIO.sendMessage(
      'send_message',
      json.encode({
        'receiverChatID': receiverChatID,
        'senderChatID': currentUser.chatID,
        'content': text,
      }),
    );
    notifyListeners();
  }

  List<Message> getMessagesForChatID(String chatID) {
    return messages.where((msg) => msg.senderID == chatID || msg.receiverID == chatID).toList();
  }
}
