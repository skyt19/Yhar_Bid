# Yhar Bid Deployment Guide

## Prerequisites

- Supabase CLI installed
- Firebase CLI installed
- Project access and credentials configured
- Git repository access

## 1. Database Migration

```bash
# Review migration file
cat supabase/migrations/20261115_chat_history.sql

# Apply to Supabase project (STAGING FIRST)
supabase db push

# Verify tables created
supabase db list

# Check RLS policies
supabase inspect db --local
```

## 2. Deploy Edge Functions

```bash
# Set environment variables
supabase secrets set FIREBASE_PROJECT_ID=yhar-bid
supabase secrets set SUPABASE_URL=https://aanochhlejpbhdhkgjpx.supabase.co
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key>
supabase secrets set GROQ_API_KEY=<your-groq-key>

# Deploy chat-db function
supabase functions deploy chat-db

# Deploy groq-proxy function (verify configuration)
supabase functions deploy groq-proxy

# Test Edge Functions
curl -X POST https://aanochhlejpbhdhkgjpx.supabase.co/functions/v1/chat-db \
  -H "Authorization: Bearer <test-firebase-token>" \
  -H "Content-Type: application/json" \
  -d '{"operation":"list_conversations","limit":10}'
```

## 3. Verify CORS Configuration

Ensure chat-db/index.ts CORS matches deployment domain:
- Production: `https://yhar-bid.web.app`
- Staging: Update accordingly

## 4. Flutter Web Build

```bash
# Clean build
flutter clean
flutter pub get

# Verify no errors
flutter analyze

# Run tests
flutter test

# Build release
flutter build web --release
```

## 5. Firebase Hosting Deployment

```bash
# Deploy to staging/preview first
firebase hosting:channel:deploy preview

# Test thoroughly in preview environment

# Deploy to production (after verification)
firebase deploy --only hosting
```

## 6. Post-Deployment Verification

### Test Chat History
1. Login with test account A
2. Create conversation
3. Send messages
4. Refresh browser - verify persistence
5. Login with account B
6. Verify account B cannot see account A's conversations

### Test AI Features
1. Create task with deadline
2. Ask AI "What do I have this week?"
3. Verify AI retrieves actual task
4. Test all three personality modes
5. Verify Thai responses use "ค่ะ" consistently

### Test Markdown Viewer
1. Open preparation plan
2. Click "View Markdown"
3. Verify side panel opens
4. Export PDF
5. Verify Thai characters render correctly

### Test Localization
1. Switch to Thai
2. Verify all major screens show Thai
3. Switch to English
4. Verify all major screens show English
5. Restart browser
6. Verify language persists

## 7. Rollback Procedure

If issues arise:

```bash
# Rollback Firebase Hosting
firebase hosting:rollback

# Rollback Edge Functions
supabase functions deploy chat-db --no-verify-jwt  # Previous version
```

For database rollback, restore from backup:
```bash
supabase db dump > backup.sql
# Restore if needed
supabase db reset
```

## Security Checklist

- [ ] Firebase ID tokens verified server-side
- [ ] Service-role key not exposed in client
- [ ] CORS restricted to production domain
- [ ] RLS policies active and tested
- [ ] Cross-user isolation verified
- [ ] API keys not in source control
- [ ] .env file not in build artifacts

## Monitoring

Set up monitoring for:
- Edge Function errors (Supabase logs)
- Chat operation failures
- AI request failures
- Client-side errors (Sentry/logging)

## Environment Variables

Never commit these - set via Supabase secrets:
- FIREBASE_PROJECT_ID
- SUPABASE_URL
- SUPABASE_SERVICE_ROLE_KEY
- GROQ_API_KEY

Client uses public keys only (configured in AppConfig).
