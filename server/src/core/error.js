// Simple error handler middleware
function errorHandler(err, req, res, next) {
  console.error(err);
  if (res.headersSent) return next(err);
  const status = err.status || 500;
  res.status(status).json({
    ok: false,
    message: err.message || 'Internal Server Error'
  });
}

module.exports = { errorHandler };
