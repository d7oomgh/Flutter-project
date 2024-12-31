enum MessageType {
  text,
  image,
  video,
  audio, file
}

class ChatMessage {
  final String senderId;
  final String receiverId;
  final String senderName;
  final String? text;
  final String? mediaUrl;
  final MessageType type;
  final DateTime timestamp;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    this.text,
    this.mediaUrl,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'text': text,
      'mediaUrl': mediaUrl,
      'type': type.toString(),
      'timestamp': timestamp,
    };
  }
}