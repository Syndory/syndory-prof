import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-client@2.43.1'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Gestion du CORS pour les appels depuis le Web
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { justificatif_id, decision, rejection_reason } = await req.json()

    // Initialisation du client Supabase avec la clé de service (Admin)
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Mise à jour du justificatif
    const { data, error } = await supabaseClient
      .from('justificatifs')
      .update({ 
        statut: decision,
        rejection_reason: rejection_reason,
        reviewed_at: new Date().toISOString()
      })
      .eq('id', justificatif_id)
      .select()

    if (error) throw error

    return new Response(
      JSON.stringify({ message: 'Statut mis à jour avec succès', data }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400 
      }
    )
  }
})
