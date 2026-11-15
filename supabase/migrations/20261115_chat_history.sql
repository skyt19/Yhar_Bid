-- supabase/migrations/20261115_chat_history.sql
-- AI Assistance Chat History Schema
-- Phase 4: Persistent conversation history with user isolation

-- Enable Row Level Security
ALTER DATABASE postgres SET timezone TO 'Asia/Bangkok';

-- Conversations table
CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    title TEXT,
    personality_level TEXT NOT NULL DEFAULT 'standard',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT conversations_user_id_not_empty CHECK (char_length(user_id) > 0),
    CONSTRAINT conversations_personality_valid CHECK (
        personality_level IN ('standard', 'advanced', 'executive')
    )
);

-- Messages table
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    role TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB,

    CONSTRAINT messages_role_valid CHECK (role IN ('user', 'assistant', 'system'))
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON public.conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_conversations_updated_at ON public.conversations(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at);

-- Enable Row Level Security
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies for conversations
-- Users can only see their own conversations
CREATE POLICY "Users can view their own conversations"
    ON public.conversations FOR SELECT
    USING (user_id = current_setting('app.user_id', true));

CREATE POLICY "Users can insert their own conversations"
    ON public.conversations FOR INSERT
    WITH CHECK (user_id = current_setting('app.user_id', true));

CREATE POLICY "Users can update their own conversations"
    ON public.conversations FOR UPDATE
    USING (user_id = current_setting('app.user_id', true))
    WITH CHECK (user_id = current_setting('app.user_id', true));

CREATE POLICY "Users can delete their own conversations"
    ON public.conversations FOR DELETE
    USING (user_id = current_setting('app.user_id', true));

-- RLS Policies for messages
-- Users can only see messages from their own conversations
CREATE POLICY "Users can view messages from their conversations"
    ON public.messages FOR SELECT
    USING (
        conversation_id IN (
            SELECT id FROM public.conversations
            WHERE user_id = current_setting('app.user_id', true)
        )
    );

CREATE POLICY "Users can insert messages to their conversations"
    ON public.messages FOR INSERT
    WITH CHECK (
        conversation_id IN (
            SELECT id FROM public.conversations
            WHERE user_id = current_setting('app.user_id', true)
        )
    );

CREATE POLICY "Users can update messages in their conversations"
    ON public.messages FOR UPDATE
    USING (
        conversation_id IN (
            SELECT id FROM public.conversations
            WHERE user_id = current_setting('app.user_id', true)
        )
    )
    WITH CHECK (
        conversation_id IN (
            SELECT id FROM public.conversations
            WHERE user_id = current_setting('app.user_id', true)
        )
    );

CREATE POLICY "Users can delete messages from their conversations"
    ON public.messages FOR DELETE
    USING (
        conversation_id IN (
            SELECT id FROM public.conversations
            WHERE user_id = current_setting('app.user_id', true)
        )
    );

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to auto-update updated_at
CREATE TRIGGER update_conversations_updated_at
    BEFORE UPDATE ON public.conversations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions
GRANT ALL ON public.conversations TO authenticated;
GRANT ALL ON public.messages TO authenticated;
GRANT ALL ON public.conversations TO anon;
GRANT ALL ON public.messages TO anon;
