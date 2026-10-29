import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/nets_state.dart';
import '../services/nets_service.dart';

// provides the nets api service
final netsServiceProvider = Provider<NetsService>((ref) {
  return NetsService();
});

// manages the nets payment state
final netsProvider = StateNotifierProvider<NetsNotifier, NetsState>((ref) {
  return NetsNotifier(ref.watch(netsServiceProvider));
});

// checks if a message looks like a raw technical error (e.g. NETS'
// own backend leaking a JS crash message) rather than something safe
// to show a user directly
bool _looksLikeRawTechnicalError(String message) {
  final lower = message.toLowerCase();
  return lower.contains('cannot read propert') ||
      lower.contains('undefined') ||
      lower.contains('typeerror') ||
      lower.contains('referenceerror') ||
      lower.contains('at object.') ||
      lower.contains('stack trace') ||
      lower.contains('exception:');
}

String _sanitizeMessage(String? rawMessage) {
  if (rawMessage == null || rawMessage.trim().isEmpty) {
    return 'NETS could not complete the payment request.';
  }

  if (_looksLikeRawTechnicalError(rawMessage)) {
    // this is very likely NETS' own sandbox server hitting an internal
    // error and returning a raw JS crash message instead of a proper
    // response - not something caused by this app's code, but also not
    // safe/useful to show a user verbatim
    return 'NETS sandbox returned an unexpected error. Please try again.';
  }

  return rawMessage;
}

// manages nets payment logic, timer and sse stream handling
// follows the mini-project nets provider structure
class NetsNotifier extends StateNotifier<NetsState> {
  NetsNotifier(this._service) : super(const NetsState(status: 'loading'));

  final NetsService _service;

  Timer? _timer;
  StreamSubscription<String>? _webhookSub;

  // guards against late-arriving async events (a timer tick, a webhook
  // line, or a checkPayment response that was already "in flight")
  // mutating state after cleanup() was called. without this, an event
  // that fires the instant a screen is popping can crash the app with
  // a "_dependents.isEmpty" assertion, since it notifies a widget that
  // is mid-removal from the tree.
  bool _isActive = true;

  // requests a new nets qr code
  Future<void> generateQR(double amount) async {
    if (!_isActive) return;

    state = state.copyWith(status: 'loading');

    try {
      final result = await _service.requestQR(amount);

      if (!_isActive) return;

      final qrCode = result['qr_code'];
      final transactionReference = result['txn_retrieval_ref'];

      if (qrCode == null || transactionReference == null) {
        throw Exception('Invalid NETS response.');
      }

      final qrBytes = base64Decode(qrCode.toString());
      final txnRef = transactionReference.toString();

      state = NetsState(
        qrCode: qrBytes,
        status: 'idle',
        timeLeft: 300,
        txnRef: txnRef,
      );

      startTimer(txnRef);
      startWebhookListener(txnRef);
    } catch (error) {
      if (!_isActive) return;

      state = state.copyWith(
        status: 'fail',
        message: _sanitizeMessage(
          error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  // starts the qr expiry countdown
  void startTimer(String txnRef) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isActive) {
        timer.cancel();
        return;
      }

      if (state.timeLeft <= 1) {
        timer.cancel();
        checkPayment(txnRef);
      } else {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      }
    });
  }

  // listens to nets webhook / sse updates
  void startWebhookListener(String txnRef) {
    _webhookSub?.cancel();

    _webhookSub = _service.webhookStream(txnRef).listen(
      (line) {
        if (!_isActive) return;

        try {
          final decoded = jsonDecode(line);

          if (decoded is! Map<String, dynamic>) {
            return;
          }

          final message = decoded['message'];
          final responseCode = decoded['response_code'];

          if (responseCode == '00') {
            _onPaymentSuccess();
          } else if (responseCode != null) {
            // store the (sanitized) message BEFORE failing, so the
            // fail screen has something meaningful to show
            if (message != null) {
              state = state.copyWith(
                message: _sanitizeMessage(message.toString()),
              );
            }
            _onPaymentFail();
          } else if (message != null) {
            state = state.copyWith(message: _sanitizeMessage(message.toString()));
          }
        } catch (_) {
          // keep-alive or non-json sse lines are ignored
        }
      },
      onError: (error) {
        // timer checkPayment fallback still runs
      },
    );
  }

  // checks the payment result directly from nets
  Future<void> checkPayment(String txnRef) async {
    if (!_isActive) return;

    try {
      final result = await _service.checkPayment(txnRef);

      if (!_isActive) return;

      if (result['response_code'] == '00') {
        _onPaymentSuccess();
      } else {
        final message = result['message'];
        if (message != null) {
          state = state.copyWith(message: _sanitizeMessage(message.toString()));
        }
        _onPaymentFail();
      }
    } catch (_) {
      if (!_isActive) return;
      _onPaymentFail();
    }
  }

  void _onPaymentSuccess() {
    if (!_isActive) return;

    _timer?.cancel();
    _webhookSub?.cancel();

    state = state.copyWith(status: 'success');

    Future<void>.delayed(const Duration(seconds: 10), () {
      if (mounted && _isActive) {
        state = state.copyWith(status: 'complete');
      }
    });
  }

  void _onPaymentFail() {
    if (!_isActive) return;

    _timer?.cancel();
    _webhookSub?.cancel();

    state = state.copyWith(
      status: 'fail',
      message: state.message ?? _sanitizeMessage(null),
    );
  }

  // stops this notifier from reacting to any further async events -
  // called right before the payment screen is popped
  void cleanup() {
    _isActive = false;
    _timer?.cancel();
    _webhookSub?.cancel();
  }

  @override
  void dispose() {
    cleanup();
    super.dispose();
  }
}