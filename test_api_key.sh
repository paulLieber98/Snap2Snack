#!/bin/bash

# Snap2Snack API Key Test Script
# This script helps verify that your OpenAI API key is properly configured

echo "🔍 Snap2Snack API Key Configuration Test"
echo "========================================"
echo ""

# Check if environment variable is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "❌ OPENAI_API_KEY environment variable is NOT set"
    echo ""
    echo "📋 To fix this:"
    echo "1. Open Xcode"
    echo "2. Go to Product → Scheme → Edit Scheme..."
    echo "3. Select 'Run' in the left sidebar"
    echo "4. Go to 'Arguments' tab"
    echo "5. Under 'Environment Variables', click the '+' button"
    echo "6. Add:"
    echo "   - Name: OPENAI_API_KEY"
    echo "   - Value: your-actual-api-key-here"
    echo "7. Click 'Close' and restart Xcode"
    echo ""
    echo "📖 See API_KEY_SETUP.md for detailed instructions"
    exit 1
else
    echo "✅ OPENAI_API_KEY environment variable is set"
    
    # Check if it looks like a valid API key
    if [[ $OPENAI_API_KEY == sk-* ]]; then
        echo "✅ API key format looks correct (starts with 'sk-')"
        
        # Check length
        key_length=${#OPENAI_API_KEY}
        if [ $key_length -gt 20 ]; then
            echo "✅ API key length looks reasonable ($key_length characters)"
            echo ""
            echo "🎉 Your API key appears to be configured correctly!"
            echo "📱 Try running your Snap2Snack app now - it should work!"
        else
            echo "⚠️  API key seems too short ($key_length characters)"
            echo "   Make sure you copied the complete key from OpenAI"
        fi
    else
        echo "⚠️  API key doesn't start with 'sk-' - this might not be a valid OpenAI key"
        echo "   Double-check that you copied the key correctly from OpenAI Platform"
    fi
fi

echo ""
echo "🔗 Get your API key from: https://platform.openai.com/api-keys"
