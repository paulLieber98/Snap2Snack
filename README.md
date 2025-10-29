# Snap2Snack - Congressional App Challenge 2025

## Overview
Snap2Snack is an iOS application designed to help individuals with diabetes manage their nutrition and health through AI-powered image recognition and personalized recommendations.

## Problem Statement
Managing diabetes requires constant attention to food choices, blood glucose levels, and lifestyle factors. Many people struggle with:
- Identifying diabetes-friendly foods while grocery shopping
- Planning meals based on available ingredients
- Tracking glucose levels and medication schedules
- Finding appropriate physical activities
- Locating local healthcare resources

## Solution
Snap2Snack provides a comprehensive diabetes management solution through five main features:

### 1. Grocery Store Assistant
- Take photos of food items or scan barcodes
- AI-powered analysis determines if foods are "diabetes-friendly" or "limit intake"
- Quick nutritional guidance while shopping

### 2. Fridge Scan for Healthy Meal Suggestions
- AI image recognition identifies foods in your fridge
- Suggests low-glycemic index recipes
- Provides nutritional breakdown and cooking instructions
- Filters by cooking time, difficulty, and dietary restrictions

### 3. Glucose Check & Medication Reminders
- Log and track blood glucose levels
- Set personalized reminders for glucose checks and medication
- Visual status indicators (low, normal, elevated, high)

### 4. Physical Activity Suggestions
- Curated exercise recommendations suitable for diabetes management
- Activity intensity and duration guidance
- Safety warnings based on glucose levels

### 5. Local Resource Finder
- Directory of diabetes clinics, dietitians, and support groups
- Insurance acceptance and cost information
- Direct phone number access

## Technical Features
- **SwiftUI**: Modern iOS development framework
- **Camera Integration**: Photo capture and gallery selection
- **OpenAI GPT-4o mini**: Real AI analysis for food recognition and meal suggestions
- **Tabbed Interface**: Intuitive navigation between features
- **Responsive Design**: Optimized for all iOS device sizes
- **Secure API Key Management**: Environment variable configuration for OpenAI API

## Target Audience
- Individuals with Type 1 and Type 2 diabetes
- Caregivers and family members
- Healthcare providers
- Anyone interested in diabetes management

## Impact
Snap2Snack empowers users to:
- Make informed food choices
- Maintain better glucose control
- Improve overall diabetes management
- Access local healthcare resources
- Lead healthier, more active lifestyles

## Future Enhancements
- Real AI integration for food recognition
- Bluetooth glucose meter connectivity
- Personalized meal planning algorithms
- Community features and support groups
- Integration with health apps and devices

## Development Team
[Your Team Names Here]

## Congressional App Challenge 2025
This app was developed for the Congressional App Challenge, an initiative to encourage students to learn coding and create apps that solve real-world problems.

## Installation & Setup

### Prerequisites
- Xcode 15.0 or later
- iOS 15.0 or later
- OpenAI API key (for AI features)

### Quick Setup
1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Snap2Snack
   ```

2. **Configure OpenAI API Key**
   - Get your API key from [OpenAI Platform](https://platform.openai.com/api-keys)
   - Follow the detailed instructions in [API_KEY_SETUP.md](API_KEY_SETUP.md)
   - **Quick method**: In Xcode, go to Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables, add `OPENAI_API_KEY` with your key

3. **Build and Run**
   - Open `Snap2Snack.xcodeproj` in Xcode
   - Build and run on iOS device or simulator
   - Grant camera and photo library permissions when prompted

### Testing Your Setup
Run the test script to verify your API key configuration:
```bash
./test_api_key.sh
```

### Troubleshooting
- **"Analysis failed" errors**: Check your API key setup in [API_KEY_SETUP.md](API_KEY_SETUP.md)
- **Build errors**: Ensure iOS deployment target is 15.0 or higher
- **Permission issues**: Grant camera access in iOS Settings

## Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## License
[Your License Here]