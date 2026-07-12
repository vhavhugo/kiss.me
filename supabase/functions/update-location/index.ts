import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@upstash/redis@1.20.4'

const redis = createClient({
  url: Deno.env.get('UPSTASH_REDIS_REST_URL')!,
  token: Deno.env.get('UPSTASH_REDIS_REST_TOKEN')!,
})

serve(async (req) => {
  try {
    const { user_id, lat, lng } = await req.json()

    // GEOADD key longitude latitude member
    await redis.geoadd('user_locations', {
      longitude: lng,
      latitude: lat,
      member: user_id
    })

    return new Response(JSON.stringify({ success: true }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
