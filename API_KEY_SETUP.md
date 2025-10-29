# 🔑 Snap2Snack API Key Setup Guide

## 🚨 IMPORTANT: Secure API Key Configuration

Your Snap2Snack app is now configured to use **environment variables** for API key management. This is the **secure and recommended approach** that prevents your API key from being exposed in your code.

## 📋 Step-by-Step Setup

### 1. Get Your OpenAI API Key
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in to your account
3. Navigate to "API Keys" in your dashboard
4. Click "Create new secret key"
5. Copy the generated API key (starts with `sk-`)

### 2. Configure Environment Variable in Xcode

#### Method A: Xcode Scheme Configuration (Recommended)
1. Open your project in Xcode
2. Go to **Product → Scheme → Edit Scheme...**
3. Select **Run** in the left sidebar
4. Go to **Arguments** tab
5. Under **Environment Variables**, click the **+** button
6. Add:
   - **Name**: `OPENAI_API_KEY`
   - **Value**: `your-actual-api-key-here` (paste your real API key)
7. Click **Close**

#### Method B: Terminal Setup (Alternative)
```bash
# Add to your shell profile (~/.zshrc or ~/.bash_profile)
export OPENAI_API_KEY="your-actual-api-key-here"

# Then restart Xcode or your terminal
```

### 3. Verify Configuration
1. Clean and build your project in Xcode
2. Run the app
3. Try taking a photo of food - you should see AI analysis instead of "Analysis failed"

## 🔒 Security Benefits

✅ **API key is NOT stored in your code**  
✅ **Safe to commit to public repositories**  
✅ **Easy to share with other developers**  
✅ **No risk of accidentally exposing your key**  

## 🛠 Troubleshooting

### "Analysis failed" Error
- **Check**: Is your environment variable set correctly?
- **Verify**: Your API key is valid and has credits
- **Restart**: Xcode after setting the environment variable

### Environment Variable Not Working
1. Make sure you're setting it in the **Run** scheme (not Debug/Release)
2. Try restarting Xcode completely
3. Clean and rebuild your project
4. Check that the variable name is exactly `OPENAI_API_KEY`

### API Key Validation
The app now validates your API key by checking:
- ✅ Not empty
- ✅ Not the placeholder text
- ✅ Starts with "sk-"
- ✅ Has sufficient length (>20 characters)

## 🎯 What Happens Now

1. **Without API Key**: App shows "Analysis failed" with helpful error message
2. **With Valid API Key**: App provides real AI-powered food analysis
3. **Invalid API Key**: App shows appropriate error message

## 📱 Testing Your Setup

1. **Grocery Scan**: Take a photo of any food item
2. **Fridge Scan**: Take a photo of your fridge contents
3. **Expected Result**: Detailed AI analysis with diabetes-friendly recommendations

## 🔄 Next Steps

Once configured, your Snap2Snack app will provide:
- Real-time food analysis using ChatGPT-4o mini
- Diabetes-friendly recommendations
- Nutritional data and glycemic index information
- Personalized meal suggestions

---

**Remember**: Never commit your actual API key to version control. The environment variable approach keeps your key secure while allowing the app to function properly.
