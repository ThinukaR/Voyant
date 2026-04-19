# Hosting Backend on Render - Complete Guide

## Step 1: Push Your Code to GitHub
Make sure your backend code is pushed to GitHub:
```bash
git add .
git commit -m "Prepare backend for Render deployment"
git push origin main
```

## Step 2: Create a Render Account
1. Go to https://render.com
2. Sign up with your GitHub account (recommended for easy deployment)
3. Verify your email

## Step 3: Create a New Web Service
1. From the Render dashboard, click **"New +"** → **"Web Service"**
2. Connect your GitHub repository (Voyant)
3. Select the repository

## Step 4: Configure the Web Service

### Basic Settings:
- **Name**: `voyant-backend`
- **Environment**: `Node`
- **Branch**: `main`
- **Start Command**: `npm start`

### Environment Variables:
Add these environment variables in the Render dashboard:

| Key | Value |
|-----|-------|
| MONGO_URI | `mongodb+srv://voyantAdmin:1VfeLDAFCQU84yJ7@voyant.y7zwi17.mongodb.net/voyant` |
| PORT | `3000` |

⚠️ **IMPORTANT**: Consider rotating your MongoDB password after deployment for security!

### Plan:
- Choose **Free** tier to start (you can upgrade later if needed)

### Deploy Hooks (Optional):
- Leave blank for now, or set up if you need automatic deployments on push

## Step 5: Deploy
1. Click **"Deploy Web Service"**
2. Render will automatically build and deploy your application
3. Wait for the deployment to complete (this may take a few minutes)

## Step 6: Get Your Render URL
Once deployed successfully:
1. Go to your service dashboard
2. Find your service URL (usually looks like: `https://voyant-backend.onrender.com`)
3. Update your Flutter app's `api_config.dart`:

```dart
class ApiConfig {
  static const String _baseUrl = 'https://your-service-name.onrender.com/api';
  
  static String get baseUrl {
    return 'https://your-service-name.onrender.com/api';
  }
}
```

Replace `your-service-name` with your actual Render service name.

## Step 7: Verify the Deployment
Test your health endpoint:
```
https://your-service-name.onrender.com/health
```

You should get a response like:
```json
{
  "status": "OK",
  "message": "Server is running"
}
```

## Step 8: Test an API Endpoint
Try testing one of your endpoints to ensure everything is working.

---

## Important Notes:

### Free Tier Limitations:
- Services spin down after 15 minutes of inactivity
- This means the first request after idle time will be slower
- For production, consider upgrading to a paid plan

### File Structure:
Your `render.yaml` is configured to use Node.js and expects your `backend` folder at the root.

### Troubleshooting:
- **Build fails**: Check your build logs in the Render dashboard
- **503/502 errors**: Usually means the service is spinning up. Wait a moment and retry
- **CORS errors**: May need to configure CORS in your Express app
- **Connection timeout**: Check if MongoDB URI is correct and accessible

### Security:
- Never commit `.env` files with real credentials
- Use Render's environment variable feature (already set up)
- Consider using Render's secrets for sensitive data

---

## Rolling Back on Render:
If you need to rollback to a previous deployment:
1. Go to your service in Render dashboard
2. Click on the service
3. Go to the **"Deployments"** tab
4. Click the 3-dot menu on a previous deployment
5. Select **"Redeploy"**

