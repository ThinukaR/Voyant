# Setting Up Firebase Credentials on Render

Since `serviceAccountKey.json` cannot be committed to Git for security reasons, you need to set up your Firebase credentials as an environment variable on Render.

## Steps:

### 1. Get Your Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (Voyant)
3. Go to **Project Settings** (gear icon)
4. Click the **Service Accounts** tab
5. Click **Generate New Private Key** button
6. A JSON file will download - keep it safe!

### 2. Convert to Environment Variable

1. Open the downloaded JSON file in a text editor
2. Copy the entire content
3. You'll need to convert it to a single-line string (remove newlines):
   - Option A: Use an online tool like https://www.freeformatter.com/json-minifier.html
   - Option B: In the file, select all and copy, then paste into a JSON minifier

### 3. Set on Render Dashboard

1. Go to your Render service: `voyant-backend`
2. Click **Environment**
3. Add new environment variable:
   - **Key**: `FIREBASE_CONFIG`
   - **Value**: Paste the minified JSON key (from step 2)
4. Click **Save**

### 4. Redeploy

Click the three dots (...) and select **Redeploy**

---

## Complete Environment Variables Checklist

Make sure these are all set in Render:

| Variable | Value | Notes |
|----------|-------|-------|
| `MONGO_URI` | `mongodb+srv://voyantAdmin:1VfeLDAFCQU84yJ7@voyant.y7zwi17.mongodb.net/voyant` | MongoDB connection string |
| `PORT` | `3000` | Server port |
| `FIREBASE_CONFIG` | Your minified service account JSON | Firebase credentials |

---

## Troubleshooting

If you still see "Application exited early":

1. Check the Render logs for the exact error message
2. Common issues:
   - FIREBASE_CONFIG is invalid JSON
   - MONGO_URI is incorrect or MongoDB is unreachable
   - Network connectivity issues

### View Logs:
Go to your service → **Logs** tab → Look for `[ERROR]` messages

---

## Security Note

✅ Never commit `serviceAccountKey.json` to Git
✅ Never share your Firebase credentials publicly
✅ Use environment variables for all sensitive data
✅ If you accidentally exposed credentials, regenerate them immediately

