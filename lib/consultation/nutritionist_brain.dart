class NutritionistBrain {
  static String reply(String message) {
    final msg = message.toLowerCase();

    if (msg.contains("weight") || msg.contains("lose")) {
      return """
🟢 **Weight Loss Plan**

📌 Goal  
Reduce body fat safely and sustainably.

🥗 What to eat  
• Vegetables  
• Fruits  
• Dal, eggs, paneer  
• Roti instead of white rice  

🚫 Avoid  
• Sugary drinks  
• Fried food  
• Bakery items  

💡 Tip  
Walk 30 minutes daily and drink 3 liters of water.
""";
    }

    if (msg.contains("gym") || msg.contains("protein") || msg.contains("muscle")) {
      return """
🟢 **Muscle Building Plan**

📌 Goal  
Increase muscle mass and strength.

🥗 What to eat  
• Eggs  
• Chicken  
• Paneer  
• Dal  
• Milk & nuts  

🚫 Avoid  
• Skipping meals  
• Junk food  

💡 Tip  
Consume protein within 30 minutes after workout.
""";
    }

    if (msg.contains("diabetes") || msg.contains("sugar")) {
      return """
🟢 **Diabetes Control Plan**

📌 Goal  
Keep blood sugar stable.

🥗 What to eat  
• Oats  
• Vegetables  
• Dal  
• Brown rice  

🚫 Avoid  
• White sugar  
• Sweets  
• Soft drinks  

💡 Tip  
Eat small meals every 3 hours.
""";
    }

    return """
🟢 **Healthy Lifestyle Plan**

🥗 Eat balanced meals with vegetables, protein, and whole grains.  
🚫 Avoid junk and processed food.  
💡 Drink water, sleep well, and exercise daily.
""";
  }
}

