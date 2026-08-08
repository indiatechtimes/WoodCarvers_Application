import mongoose from 'mongoose';

const mediaSchema = new mongoose.Schema(
  {
    url: { type: String, required: true },
    type: { type: String, enum: ['image', 'video'], default: 'image' },
    publicId: { type: String, default: '' },
  },
  { _id: false }
);

const productSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    slug: { type: String, required: true, unique: true, lowercase: true },
    description: { type: String, required: true },
    shortDescription: { type: String, default: '' },
    price: { type: Number, required: true, min: 0 },
    compareAtPrice: { type: Number, default: 0 },
    category: { type: String, required: true },
    tags: [{ type: String }],
    stock: { type: Number, required: true, default: 0 },
    sku: { type: String, default: '' },
    media: [mediaSchema],
    featured: { type: Boolean, default: false },
    handmade: { type: Boolean, default: true },
    materials: [{ type: String }],
    color: { type: String, default: '' },
    brand: { type: String, default: 'WOOD CARVERS' },
    sku: { type: String, default: '' },
    dimensions: { type: String, default: '' },
    weight: { type: String, default: '' },
    rating: { type: Number, default: 4.7 },
    reviewCount: { type: Number, default: 0 },
    active: { type: Boolean, default: true },
    bestSeller: { type: Boolean, default: false },
    newArrival: { type: Boolean, default: false },
    published: { type: Boolean, default: true },
    seoTitle: { type: String, default: '' },
    seoDescription: { type: String, default: '' },
  },
  { timestamps: true }
);

productSchema.index({ name: 'text', description: 'text', tags: 'text' });

export default mongoose.model('Product', productSchema);
