export const DB_NAME = process.env.DB_NAME || 'bamboo_decor';

export const ROLES = {
  USER: 'user',
  ADMIN: 'admin',
};

export const ORDER_STATUS = {
  PENDING: 'pending',
  PAID: 'paid',
  PROCESSING: 'processing',
  SHIPPED: 'shipped',
  DELIVERED: 'delivered',
  CANCELLED: 'cancelled',
  FAILED: 'failed',
};

export const PAYMENT_STATUS = {
  PENDING: 'pending',
  PAID: 'paid',
  FAILED: 'failed',
  REFUNDED: 'refunded',
};

export const PRODUCT_CATEGORIES = [
  'wall-decor',
  'home-decor',
  'kitchen',
  'office',
  'gifts',
  'personalized',
];

export const SETTING_KEYS = {
  HERO_IMAGE: 'hero_image',
  HERO_HEADLINE: 'hero_headline',
  HERO_SUBHEADING: 'hero_subheading',
  PROMO_BANNER: 'promo_banner',
  LOGO_URL: 'logo_url',
};
