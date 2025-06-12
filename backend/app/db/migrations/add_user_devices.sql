-- Add user_devices table for FCM tokens
CREATE TABLE IF NOT EXISTS user_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL, -- Unique device identifier
    fcm_token TEXT NOT NULL, -- Firebase Cloud Messaging token
    device_type TEXT NOT NULL CHECK (device_type IN ('ios', 'android', 'web')),
    device_name TEXT, -- User-friendly device name
    app_version TEXT,
    os_version TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    -- Ensure one record per device per user
    UNIQUE(user_id, device_id)
);

-- Add RLS policies for user_devices
ALTER TABLE user_devices ENABLE ROW LEVEL SECURITY;

-- Users can view their own devices
CREATE POLICY "Users can view own devices"
    ON user_devices FOR SELECT
    USING (auth.uid() = user_id);

-- Users can create their own device records
CREATE POLICY "Users can create own devices"
    ON user_devices FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own device records
CREATE POLICY "Users can update own devices"
    ON user_devices FOR UPDATE
    USING (auth.uid() = user_id);

-- Users can delete their own device records
CREATE POLICY "Users can delete own devices"
    ON user_devices FOR DELETE
    USING (auth.uid() = user_id);

-- Add indexes for performance
CREATE INDEX idx_user_devices_user_id ON user_devices(user_id);
CREATE INDEX idx_user_devices_fcm_token ON user_devices(fcm_token);
CREATE INDEX idx_user_devices_device_id ON user_devices(device_id);
CREATE INDEX idx_user_devices_is_active ON user_devices(is_active);

-- Add trigger for updated_at
CREATE TRIGGER update_user_devices_updated_at
    BEFORE UPDATE ON user_devices
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add notification_logs table for tracking sent notifications
CREATE TABLE IF NOT EXISTS notification_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID REFERENCES user_devices(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    notification_type TEXT NOT NULL,
    data JSONB,
    success BOOLEAN NOT NULL DEFAULT FALSE,
    error_message TEXT,
    fcm_response JSONB,
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Add RLS policies for notification_logs
ALTER TABLE notification_logs ENABLE ROW LEVEL SECURITY;

-- Users can view their own notification logs
CREATE POLICY "Users can view own notification logs"
    ON notification_logs FOR SELECT
    USING (auth.uid() = user_id);

-- Only system can insert notification logs (no user policy)
-- This ensures only the backend can create notification logs

-- Add indexes for notification_logs
CREATE INDEX idx_notification_logs_user_id ON notification_logs(user_id);
CREATE INDEX idx_notification_logs_device_id ON notification_logs(device_id);
CREATE INDEX idx_notification_logs_sent_at ON notification_logs(sent_at);
CREATE INDEX idx_notification_logs_success ON notification_logs(success);
CREATE INDEX idx_notification_logs_notification_type ON notification_logs(notification_type); 