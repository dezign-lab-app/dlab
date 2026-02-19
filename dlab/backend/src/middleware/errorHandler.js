// Simple error handler (optional). You can wire this later.
export function errorHandler(err, req, res, next) {
  console.error(err);
  res.status(500).json({ message: 'Internal Server Error' });
}
