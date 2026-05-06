import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 🔐 1. AUTH
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response('Unauthorized', { status: 401 })
    }

    const token = authHeader.replace('Bearer ', '')

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser(token)

    if (authError || !user) {
      return new Response('Invalid token', { status: 401 })
    }

    // 📦 2. BODY
    const { justificatif_id, decision, rejection_reason } = await req.json()

    if (!justificatif_id || !decision) {
      return new Response('Missing fields', { status: 400 })
    }

    const allowedDecisions = ['validé', 'rejeté']
    if (typeof decision !== 'string' || !allowedDecisions.includes(decision)) {
      return new Response('Invalid decision', { status: 400 })
    }

    // 👤 3. ROLE CHECK
    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (!profile || profile.role !== 'professor') {
      return new Response('Forbidden', { status: 403 })
    }

    // 🔎 4. VERIFY OWNERSHIP
    const { data: justification } = await supabase
      .from('justificatifs')
      .select('id, presence_id')
      .eq('id', justificatif_id)
      .single()

    if (!justification) {
      return new Response('Not found', { status: 404 })
    }

    const { data: presence } = await supabase
      .from('presences')
      .select('sessions(seances(professor_id))')
      .eq('id', justification.presence_id)
      .single()

    const profId = presence?.sessions?.seances?.professor_id

    if (profId !== user.id) {
      return new Response('Forbidden', { status: 403 })
    }

    // 🛠️ 5. VALIDATION MÉTIER VIA RPC
    const { error } = await supabase.rpc('validate_justification', {
      justificatif_id,
      decision,
      rejection_reason: rejection_reason ?? null,
    })

    if (error) throw error

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})