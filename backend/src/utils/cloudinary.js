import { v2 as cloudinary } from 'cloudinary';
import streamifier from 'streamifier';

let configured = false;
const configure = () => {
  if (configured) return;
  const { CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET } = process.env;
  if (CLOUDINARY_CLOUD_NAME && CLOUDINARY_API_KEY && CLOUDINARY_API_SECRET) {
    cloudinary.config({
      cloud_name: CLOUDINARY_CLOUD_NAME,
      api_key: CLOUDINARY_API_KEY,
      api_secret: CLOUDINARY_API_SECRET,
    });
    configured = true;
  }
};

export const isCloudinaryConfigured = () => {
  configure();
  return configured;
};
if (configured) {
  console.log("Cloudinary is connected");
}

export const uploadBufferToCloudinary = (buffer, resourceType = 'image', folder = 'WoodCarversStore') =>
  new Promise((resolve, reject) => {
    configure();
    if (!configured) return reject(new Error('Cloudinary not configured'));
    const stream = cloudinary.uploader.upload_stream(
      { resource_type: resourceType, folder },
      (err, result) => (err ? reject(err) : resolve(result))
    );
    streamifier.createReadStream(buffer).pipe(stream);
  });

export const destroyCloudinary = (publicId, resourceType = 'image') => {
  configure();
  if (!configured) return Promise.resolve();
  return cloudinary.uploader.destroy(publicId, { resource_type: resourceType });
};
