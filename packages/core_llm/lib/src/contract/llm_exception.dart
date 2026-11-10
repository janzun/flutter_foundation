/// Base exception for core_llm operations.
class LlmException implements Exception {
  final String message;
  final String? providerId;
  final int? statusCode;
  final dynamic originalError;

  const LlmException(
    this.message, {
    this.providerId,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() =>
      'LlmException(provider: $providerId, status: $statusCode): $message';
}

/// Thrown when API key or authorization fails.
class LlmAuthException extends LlmException {
  const LlmAuthException(
    super.message, {
    super.providerId,
    super.statusCode,
    super.originalError,
  });
}

/// Thrown when rate limit / quota exceeded.
class LlmRateLimitException extends LlmException {
  const LlmRateLimitException(
    super.message, {
    super.providerId,
    super.statusCode,
    super.originalError,
  });
}
