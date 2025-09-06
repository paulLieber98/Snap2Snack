# Snap2Snack - ChatGPT Integration Setup

## �� Quick Setup Guide

### 1. Get Your OpenAI API Key
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in to your account
3. Navigate to "API Keys" in your dashboard
4. Click "Create new secret key"
5. Copy the generated API key

### 2. Configure the App (Choose One Method)

#### Method A: Environment Variable (Recommended for Development)
1. Open your project in Xcode
2. Go to **Product → Scheme → Edit Scheme**
3. Select **Run** in the left sidebar
4. Go to **Arguments** tab
5. Under **Environment Variables**, click the **+** button
6. Add:
   - **Name**: `OPENAI_API_KEY`
   - **Value**: `your-actual-api-key-here`
7. Click **Close**

#### Method B: Direct Code Configuration
1. Open `Snap2Snack/Config.swift`
2. Replace `***REMOVED***` with your actual API key:
   ```swift
   static let openAIAPIKey = "sk-your-actual-api-key-here"
   ```
   **Note**: This method is NOT recommended for public repositories

### 3. Build and Run
1. Clean and build the project
2. Run on simulator or device
3. Take photos of food items to test the AI analysis

## 🔧 Features Enabled

### Grocery Store Assistant
- **Real AI Analysis**: ChatGPT-4o mini analyzes food photos
- **Diabetes-Friendly Recommendations**: Context-aware advice for blood sugar management
- **Nutritional Data**: Detailed macros and glycemic index information
- **Confidence Scoring**: AI confidence levels for each analysis

### Fridge Scan
- **Food Detection**: Identifies all visible food items
- **Health Scoring**: 1-10 health score for your fridge contents
- **Meal Suggestions**: AI-generated diabetes-friendly recipes
- **Smart Recommendations**: Personalized advice based on detected foods

## 🎯 How It Works

1. **Image Capture**: User takes photo with camera or selects from gallery
2. **AI Processing**: Image sent to ChatGPT-4o mini with diabetes-specific prompts
3. **Analysis**: AI provides detailed analysis with recommendations
4. **Display**: Results shown with visual indicators and detailed information

## 🔒 Privacy & Security

- Images are sent to OpenAI for analysis
- No data is stored permanently
- API calls are made securely over HTTPS
- Your API key is stored locally in the app
- **Environment variables keep your key secure and out of the code**

## 💡 Tips for Best Results

- **Good Lighting**: Ensure food items are well-lit
- **Clear Photos**: Avoid blurry or dark images
- **Single Items**: For grocery analysis, focus on one food item at a time
- **Fridge Organization**: For fridge scans, ensure items are visible and organized

## 🛠 Troubleshooting

### "API Key Required" Error
- Make sure you've set the environment variable correctly
- Verify the key is correct and active
- Check your OpenAI account has sufficient credits
- Try restarting Xcode after setting the environment variable

### "Analysis Error" Messages
- Check your internet connection
- Verify your OpenAI API key is valid
- Ensure you have sufficient API credits
- Try taking a clearer photo

### Build Errors
- Make sure all files are added to the Xcode project
- Clean and rebuild the project
- Check that iOS deployment target is 15.0 or higher

## 📱 Supported iOS Versions

- iOS 15.0+
- iPhone and iPad compatible
- Requires camera access for photo capture

## 🔄 API Usage

The app uses OpenAI's GPT-4o mini model which is:
- Cost-effective for image analysis
- Fast response times
- High accuracy for food recognition
- Optimized for mobile applications

## 📊 Expected API Costs

- Grocery analysis: ~$0.01-0.03 per image
- Fridge scan: ~$0.02-0.05 per image
- Monthly usage for moderate use: $5-15

## 🎉 Ready to Go!

Once configured, your Snap2Snack app will provide real AI-powered diabetes management assistance!

## 🔐 Security Note

The app is configured to use environment variables for API keys, making it safe to:
- Commit to public repositories
- Share with other developers
- Publish as open source

Your API key will only be used when running the app locally with the environment variable set.
