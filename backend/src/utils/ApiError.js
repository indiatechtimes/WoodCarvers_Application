class ApiError extends Error {
  constructor(statusCode, message = 'Something went wrong', details = null) {
    super(message);
    this.statusCode = statusCode;
    this.details = details;
    this.success = false;
  }
}

export default ApiError;
