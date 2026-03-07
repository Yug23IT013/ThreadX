// TEMPLATE FILE - Copy this to cloudinary_config.dart and fill in your credentials
// Get your credentials from: https://console.cloudinary.com/

class CloudinaryConfig {
  // Replace with your Cloudinary Cloud Name
  static const String cloudName = 'YOUR_CLOUD_NAME';
  
  // Replace with your Cloudinary API Key
  static const String apiKey = 'YOUR_API_KEY';
  
  // Replace with your Cloudinary API Secret
  static const String apiSecret = 'YOUR_API_SECRET';
  
  // Upload endpoint
  static String get uploadUrl => 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
  
  // Delete endpoint
  static String get deleteUrl => 'https://api.cloudinary.com/v1_1/$cloudName/image/destroy';
}
