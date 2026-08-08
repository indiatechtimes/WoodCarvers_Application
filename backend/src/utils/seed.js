import User from '../models/User.js';
import Product from '../models/Product.js';
import Review from '../models/Review.js';
import Setting from '../models/Setting.js';
import Coupon from '../models/Coupon.js';
import { ROLES, SETTING_KEYS } from '../constants.js';

// Realistic Unsplash photography of wooden décor in modern interiors
const SEED_PRODUCTS = [
  {
    name: 'Walnut Sunburst Wall Art',
    slug: 'walnut-sunburst-wall-art',
    description:
      'A hand-carved sunburst medallion in solid walnut, finished with natural beeswax. Each ray is cut and sanded by hand to create a soft, radiant statement above a console or entryway.',
    shortDescription: 'Hand-carved walnut sunburst statement piece.',
    price: 6499, compareAtPrice: 8999, category: 'wall-decor',
    tags: ['wall', 'sunburst', 'walnut', 'statement'],
    stock: 8, featured: true, handmade: true,
    materials: ['walnut', 'natural beeswax'],
    dimensions: '60 cm diameter', weight: '2.4 kg',
    media: [
      { url: 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=1600&q=80', type: 'image' },
      { url: 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=1600&q=80', type: 'image' },
    ],
  },
  {
    name: 'Oak Wall Clock — Roman Numerals',
    slug: 'oak-wall-clock-roman',
    description:
      'A minimalist wall clock cut from a single slab of aged oak, with hand-etched Roman numerals filled in walnut ink and silent quartz movement.',
    shortDescription: 'Silent oak wall clock with etched Roman numerals.',
    price: 3799, compareAtPrice: 4999, category: 'wall-decor',
    tags: ['clock', 'oak', 'minimal'],
    stock: 22, featured: true, handmade: true,
    materials: ['aged oak', 'silent quartz movement'],
    dimensions: '35 cm diameter', weight: '1.1 kg',
    media: [
      { url: 'https://images.unsplash.com/photo-1584208632869-05fa2b2a5934?w=1600&q=80', type: 'image' },
    ],
  },
  {
    name: 'Engraved Wooden Name Plate',
    slug: 'engraved-wooden-name-plate',
    description:
      'A personalised name plate CNC-cut and hand-finished from Indian rosewood. Add your family name at checkout — brass inlay letters available.',
    shortDescription: 'Personalised rosewood name plate.',
    price: 1799, category: 'personalized',
    tags: ['nameplate', 'personalized', 'rosewood'],
    stock: 40, featured: true, handmade: true,
    materials: ['Indian rosewood', 'brass inlay (optional)'],
    dimensions: '30 x 12 cm', weight: '0.5 kg',
    media: [
      { url: 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=1600&q=80&sig=nameplate', type: 'image' },
    ],
  },
  {
    name: 'Teak Table Lamp — Turned Base',
    slug: 'teak-table-lamp-turned-base',
    description:
      'A hand-turned solid teak lamp base paired with a warm linen shade. Emits a soft, honeyed light that grounds a bedside or reading nook.',
    shortDescription: 'Solid teak lamp with warm linen shade.',
    price: 5299, compareAtPrice: 6499, category: 'home-decor',
    tags: ['lamp', 'teak', 'lighting'],
    stock: 14, featured: true, handmade: true,
    materials: ['teak', 'linen shade'],
    dimensions: '20 × 20 × 48 cm', weight: '2.1 kg',
    media: [
      { url: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=1600&q=80', type: 'image' },
      { url: 'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=1600&q=80', type: 'image' },
    ],
  },
  {
    name: 'Carved Wooden Elephant Sculpture',
    slug: 'carved-wooden-elephant-sculpture',
    description:
      'A single-block carving of a walking elephant, sculpted by third-generation artisans in Rajasthan. The grain of the mango wood becomes the wrinkles of the skin.',
    shortDescription: 'Single-block mango wood elephant.',
    price: 4899, category: 'home-decor',
    tags: ['sculpture', 'elephant', 'artisan'],
    stock: 9, featured: true, handmade: true,
    materials: ['seasoned mango wood', 'natural oil finish'],
    dimensions: '28 × 12 × 22 cm', weight: '1.8 kg',
    media: [
      { url: 'https://images.unsplash.com/photo-1611967164521-abae8fba4668?w=1600&q=80', type: 'image' },
    ],
  },
  {
    name: 'Sheesham Serving Tray with Brass Handles',
    slug: 'sheesham-serving-tray-brass',
    description:
      'A generous rectangular serving tray in sheesham, edged with a chamfered lip and cast-brass drop handles. Food-safe finish.',
    shortDescription: 'Rectangular sheesham tray with brass handles.',
    price: 2499, compareAtPrice: 3299, category: 'kitchen',
    tags: ['tray', 'sheesham', 'kitchen'],
    stock: 25, featured: false, handmade: true, bestSeller: true,
    materials: ['sheesham', 'cast brass', 'food-safe oil'],
    dimensions: '45 × 30 × 4 cm', weight: '1.4 kg',
    media: [
      { url: 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=1600&q=80', type: 'image' },
    ],
  },
  {
    name: 'Live-Edge Acacia Cheese Board',
    slug: 'live-edge-acacia-cheese-board',
    description:
      'A live-edge cheese and charcuterie board in acacia, oil-finished to reveal the deep caramel figuring. Every board is one of a kind.',
    shortDescription: 'Live-edge acacia charcuterie board.',
    price: 1899, category: 'kitchen',
    tags: ['board', 'charcuterie', 'acacia'],
    stock: 30, featured: false, handmade: true,
    materials: ['acacia', 'food-safe mineral oil'],
    dimensions: '45 × 22 × 2 cm', weight: '1.0 kg',
    media: [
      { url: 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=1600&q=80', type: 'image' },
    ],
  },
  {
    name: 'Walnut Desk Organiser',
    slug: 'walnut-desk-organiser',
    description:
      'A modular desk organiser in solid walnut with felted compartments for pens, cards, keys and a shallow tray for the everyday.',
    shortDescription: 'Modular walnut desk organiser with felted compartments.',
    price: 3299, category: 'office',
    tags: ['office', 'organiser', 'walnut'],
    stock: 18, featured: false, handmade: true, bestSeller: true,
    materials: ['walnut', 'wool felt'],
    dimensions: '28 × 18 × 6 cm', weight: '0.9 kg',
    media: [
      { url: 'https://images.unsplash.com/photo-1631679706909-1844bbd07221?w=1600&q=80', type: 'image' },
    ],
  },
  {
    name: 'Rosewood Business Card Holder',
    slug: 'rosewood-business-card-holder',
    description:
      'A minimal, gently arced business card holder in polished rosewood — a small object made with a lot of care.',
    shortDescription: 'Arched polished rosewood card holder.',
    price: 899, category: 'office',
    tags: ['office', 'gift', 'rosewood'],
    stock: 60, featured: false, handmade: true,
    materials: ['rosewood', 'natural lacquer'],
    dimensions: '10 × 6 × 4 cm', weight: '0.2 kg',
    media: [
      { url: 'https://images.unsplash.com/photo-1631049035182-249067d7618e?w=1600&q=80', type: 'image' },
    ],
  },
  {
    name: 'Personalised Wooden Photo Frame',
    slug: 'personalised-wooden-photo-frame',
    description:
      'A hand-finished mango-wood photo frame that carries your names, a date, or a short quote — laser-etched with a natural finish.',
    shortDescription: 'Personalised laser-etched photo frame.',
    price: 1299, compareAtPrice: 1699, category: 'gifts',
    tags: ['gift', 'personalized', 'frame'],
    stock: 45, featured: true, handmade: true,
    materials: ['mango wood', 'archival glass'],
    dimensions: '15 × 20 cm (fits A5 photo)', weight: '0.4 kg',
    media: [
      { url: 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=1600&q=80', type: 'image' },
    ],
  },
  {
    name: 'Keepsake Box with Brass Inlay',
    slug: 'keepsake-box-with-brass-inlay',
    description:
      'A handsome keepsake box in mango wood, inlaid with a delicate brass compass motif. Lined in dark linen inside.',
    shortDescription: 'Mango wood keepsake box with brass inlay.',
    price: 2699, category: 'gifts',
    tags: ['gift', 'box', 'brass'],
    stock: 20, featured: false, handmade: true, bestSeller: true,
    materials: ['mango wood', 'brass inlay', 'linen lining'],
    dimensions: '22 × 15 × 9 cm', weight: '0.8 kg',
    media: [
      { url: 'https://images.unsplash.com/photo-1600411833196-7c1f6b1a8b90?w=1600&q=80', type: 'image' },
    ],
  },
  {
    name: 'Personalised Wedding Coordinates Plaque',
    slug: 'personalised-wedding-coordinates-plaque',
    description:
      'A commissioned plaque in walnut engraved with the coordinates and date of a special moment. A modern heirloom for weddings and anniversaries.',
    shortDescription: 'Walnut coordinates plaque, commissioned.',
    price: 2399, category: 'personalized',
    tags: ['wedding', 'gift', 'personalized'],
    stock: 18, featured: true, handmade: true, newArrival: true,
    materials: ['walnut', 'gold leaf option'],
    dimensions: '25 × 18 cm', weight: '0.7 kg',
    media: [
      { url: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=1600&q=80', type: 'image' },
    ],
  },
];

export const seedDatabase = async () => {
  // Admin
  const adminEmail = (process.env.ADMIN_EMAIL || 'admin@bamboodecor.com').toLowerCase();
  const existingAdmin = await User.findOne({ email: adminEmail });
  if (!existingAdmin) {
    await User.create({
      name: process.env.ADMIN_NAME || 'Store Admin',
      email: adminEmail,
      password: process.env.ADMIN_PASSWORD || 'Admin@123',
      role: ROLES.ADMIN,
    });
    console.log(`Seeded admin user: ${adminEmail}`);
  }

  // Products — reseed if legacy bamboo categories are present, or if empty
  const legacy = await Product.countDocuments({
    category: { $in: ['bamboo-decor', 'leaf-decor', 'wall-art', 'lamps', 'planters', 'baskets'] },
  });
  const total = await Product.countDocuments();
  if (total === 0 || legacy > 0) {
    if (legacy > 0) {
      console.log('Legacy categories detected — replacing product catalog with WOOD CARVERS collection');
      await Product.deleteMany({});
      await Review.deleteMany({}); // orphan reviews cleared alongside legacy products
    }
    await Product.insertMany(SEED_PRODUCTS);
    console.log(`Seeded ${SEED_PRODUCTS.length} wooden products`);
  } else {
    // Idempotent media reconcile — fix any product whose seeded media has changed
    for (const p of SEED_PRODUCTS) {
      await Product.updateOne({ slug: p.slug }, { $set: { media: p.media } });
    }
  }

  // Settings — seed hero + banner defaults
  const defaults = [
    { key: SETTING_KEYS.HERO_IMAGE, value: 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=2000&q=85' },
    { key: SETTING_KEYS.HERO_HEADLINE, value: 'Handcrafted Elegance for Every Home' },
    { key: SETTING_KEYS.HERO_SUBHEADING, value: 'Premium handcrafted wooden décor and personalized creations made with passion, precision, and timeless craftsmanship.' },
    { key: SETTING_KEYS.PROMO_BANNER, value: { text: 'Complimentary shipping on orders above ₹1499', active: true } },
    { key: SETTING_KEYS.LOGO_URL, value: '' },
  ];
  for (const d of defaults) {
    await Setting.updateOne({ key: d.key }, { $setOnInsert: d }, { upsert: true });
  }

  // Coupons — seed a couple of demo coupons
  const seedCoupons = [
    { code: 'WELCOME10', description: '10% off your first order', type: 'percent', value: 10, minSubtotal: 999, maxDiscount: 500 },
    { code: 'WOOD500', description: '₹500 off orders over ₹3999', type: 'flat', value: 500, minSubtotal: 3999 },
  ];
  for (const c of seedCoupons) {
    await Coupon.updateOne({ code: c.code }, { $setOnInsert: c }, { upsert: true });
  }
};
