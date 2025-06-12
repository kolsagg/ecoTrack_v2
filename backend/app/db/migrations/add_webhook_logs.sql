-- Create webhook_logs table for tracking webhook processing
CREATE TABLE IF NOT EXISTS webhook_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    transaction_id TEXT,
    payload JSONB NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('success', 'failed', 'retry', 'pending')),
    response_code INTEGER,
    error_message TEXT,
    processing_time_ms INTEGER,
    retry_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Add RLS policies for webhook_logs
ALTER TABLE webhook_logs ENABLE ROW LEVEL SECURITY;

-- Only admin/service role can access webhook logs
CREATE POLICY "Service role can manage webhook logs"
    ON webhook_logs FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_webhook_logs_merchant_id ON webhook_logs(merchant_id);
CREATE INDEX IF NOT EXISTS idx_webhook_logs_status ON webhook_logs(status);
CREATE INDEX IF NOT EXISTS idx_webhook_logs_created_at ON webhook_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_webhook_logs_transaction_id ON webhook_logs(transaction_id);

-- Add comment for documentation
COMMENT ON TABLE webhook_logs IS 'Logs for tracking webhook processing attempts and results';
COMMENT ON COLUMN webhook_logs.status IS 'Webhook processing status: success, failed, retry, pending'; 