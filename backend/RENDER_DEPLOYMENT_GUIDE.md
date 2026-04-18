# Hosting Backend on Render - Complete Guide

## Quick Start (Recommended: Web Dashboard)

The easiest way to deploy to Render is using their web dashboard with your GitHub repository. The Render CLI has compatibility issues on Windows, so the web dashboard approach is recommended.

---

## Step 1: Prepare Your Repository

Your code is already ready! Make sure your changes are pushed to GitHub:

```powershell
git push origin feature/render-deployment
```

Your `render.yaml` file in the `backend/` folder will tell Render how to build and run your service.

---

## Step 2: Deploy via Render Web Dashboard

### 1. Go to Render Dashboard
- Visit https://render.com
- Sign up or log in with GitHub

### 2. Create New Web Service
- Click **"New +"** → **"Web Service"**
- Select **"Deploy existing code from a repository"**
- Choose **"ThinukaR/Voyant"** repository
- Click **"Connect"**

### 3. Configure Service
- **Name:** `voyant-backend`
- **Branch:** `feature/render-deployment` (or `main` after merge)
- **Runtime:** Node
- **Start Command:** `npm start`

### 4. Add Environment Variables
Click **"Add Environment Variable"** and add:

| Key | Value |
|-----|-------|
| MONGO_URI | `mongodb+srv://voyantAdmin:1VfeLDAFCQU84yJ7@voyant.y7zwi17.mongodb.net/voyant` |
| PORT | `3000` |

### 5. Choose Plan
- Select **Free** tier to start

### 6. Deploy
- Click **"Create Web Service"**
- Wait for deployment to complete

### 7. Get Your URL
Once deployed, your service URL will be displayed (e.g., `https://voyant-backend.onrender.com`)

---

## Step 3: Update Your Flutter App

Update your Flutter app's API config with your Render URL:

**File:** `lib/config/api_config.dart`

```dart
class ApiConfig {
  static const String _baseUrl = 'https://voyant-backend.onrender.com/api';
  
  static String get baseUrl {
    return 'https://voyant-backend.onrender.com/api';
  }
}
```

Replace `voyant-backend` with your actual Render service name if different.

---

## Step 4: Test Your Deployment

Test your health endpoint:
```
https://voyant-backend.onrender.com/health
```

Expected response:
```json
{
  "status": "OK",
  "message": "Server is running"
}
```

---

## Monitoring Your Deployment

### View Logs
1. Go to your service in Render dashboard
2. Click **"Logs"** tab
3. View real-time logs

### Troubleshooting
1. Check the **"Events"** tab for deployment issues
2. Review **"Logs"** for runtime errors
3. Verify environment variables are set correctly

---

## Troubleshooting Common Issues

### Build Fails
- Check the build logs in Render dashboard
- Ensure `backend/package.json` is correct
- Verify build command: `cd backend && npm install`

### 503/502 Errors
- Usually means service is still starting
- Free tier services take longer to spin up
- Wait a few moments and retry

### Connection Errors
- Verify MONGO_URI environment variable is set
- Check MongoDB connection string is valid
- Ensure MongoDB Atlas allows connections from Render

### CORS Errors
- May need to add CORS configuration to Express app
- Update `backend/index.js` if needed

---

## After Deployment

### Redeployments
To redeploy after pushing new code:
1. Go to your service in Render dashboard
2. Click the three dots (...)
3. Select **"Redeploy"**

Or automatic redeployment can be enabled in settings.

### View Service Details
In Render dashboard, you can:
- View environment variables
- Update settings
- Manage deploys
- Delete service

---

## Free Tier Limitations
- Services spin down after 15 minutes of inactivity
- First request after idle will be slower (cold start)
- 0.1 CPU, 512MB RAM
- For production, consider upgrading to paid plan

---

## Important Security Note
⚠️ **DO NOT commit `.env` files with real credentials to GitHub**

Always use Render's environment variables feature for sensitive data like:
- MONGO_URI
- API keys
- Secrets

---

## Deployment Complete! 🚀

Your backend is now deployed on Render and can be accessed at:
```
https://voyant-backend.onrender.com
```

Update your Flutter app to use this URL, and you're ready to go!

