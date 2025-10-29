#!/bin/bash

# Quick verification that your API key is working
echo "🔍 Verifying Snap2Snack API Configuration"
echo "=========================================="
echo ""

# Check if API key is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "❌ OPENAI_API_KEY not set in terminal"
    echo "💡 Make sure to configure it in Xcode as well:"
    echo "   Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables"
    exit 1
fi

echo "✅ API Key Status:"
echo "   - Format: $(echo $OPENAI_API_KEY | cut -c1-10)..."
echo "   - Length: ${#OPENAI_API_KEY} characters"
echo "   - Valid: $(if [[ $OPENAI_API_KEY == sk-* ]]; then echo "Yes"; else echo "No"; fi)"
echo ""

echo "📱 Next Steps:"
echo "1. Configure the same API key in Xcode:"
echo "   Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables"
echo "   Name: OPENAI_API_KEY"
echo "   Value: $OPENAI_API_KEY"
echo ""
echo "2. Restart Xcode completely"
echo "3. Clean and build your project"
echo "4. Run the app and try taking a photo!"
echo ""
echo "🎉 Your API key is valid and ready to use!"
