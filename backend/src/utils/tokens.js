import jwt from 'jsonwebtoken';


// for create accessToken
export const signAccessToken = (payload) =>
  jwt.sign(payload, process.env.JWT_ACCESS_SECRET, {
    expiresIn: process.env.JWT_ACCESS_EXPIRY || '15m',
  });


  // for create refreshToken
export const signRefreshToken = (payload) =>
  jwt.sign(payload, process.env.JWT_REFRESH_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRY || '7d',
  });

  // for to verify accessToken (use => eg . when user want logout)
export const verifyAccessToken = (token) => jwt.verify(token, process.env.JWT_ACCESS_SECRET);

//for to verify accessToken(use => eg.when user want logout)
export const verifyRefreshToken = (token) => jwt.verify(token, process.env.JWT_REFRESH_SECRET);


// signAccessToken aur signRefreshToken ko mai user model me likh sakta tha 
// but thiik hai yaha bhi ek alag file me ...