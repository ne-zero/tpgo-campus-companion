import 'dart:typed_data';

// immutable state for the nets qr payment flow
// matches Mini-Project 10's nets_state.dart spec exactly
class NetsState {
  const NetsState({
    this.qrCode,
    this.status = 'idle',
    this.timeLeft = 300,
    this.message,
    this.txnRef,
  });

  final Uint8List? qrCode;

  // "idle" | "loading" | "success" | "fail" | "complete"
  final String status;

  final int timeLeft;
  final String? message;
  final String? txnRef;

  NetsState copyWith({
    Uint8List? qrCode,
    String? status,
    int? timeLeft,
    String? message,
    String? txnRef,
  }) {
    return NetsState(
      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,
      timeLeft: timeLeft ?? this.timeLeft,
      message: message ?? this.message,
      txnRef: txnRef ?? this.txnRef,
    );
  }
}
