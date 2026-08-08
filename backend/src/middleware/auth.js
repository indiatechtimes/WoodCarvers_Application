import { verifyAccessToken } from '../utils/tokens.js';
import ApiError from '../utils/ApiError.js';
import User from '../models/User.js';
import { ROLES } from '../constants.js';

export const requireAuth = async (req, res, next) => {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) return next(new ApiError(401, 'Authentication required'));
    const decoded = verifyAccessToken(token);
    const user = await User.findById(decoded.id);
    if (!user) return next(new ApiError(401, 'User no longer exists'));
    req.user = user;
    next();
  } catch (err) {
    next(new ApiError(401, 'Invalid or expired token'));
  }
};

export const requireAdmin = (req, res, next) => {
  if (!req.user || req.user.role !== ROLES.ADMIN) {
    return next(new ApiError(403, 'Admin access required'));
  }
  next();
};

export const optionalAuth = async (req, res, next) => {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (token) {
      const decoded = verifyAccessToken(token);
      const user = await User.findById(decoded.id);
      if (user) req.user = user;
    }
  } catch (_) {}
  next();
};
