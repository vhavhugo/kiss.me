import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@upstash/redis@1.20.4'

const redis = createClient({
  url: Deno.env.get('UPSTASH_REDIS_REST_URL')!,
  token: Deno.env.get('UPSTASH_REDIS_REST_TOKEN')!,
})

serve(async (req) => {
  try {
    const { lat, lng, radius } = await req.json()

    // GEOSEARCH user_locations FROMLONLAT lng lat BYRADIUS radius KM
    const nearby = await redis.geosearch(
      'user_locations',
      { longitude: lng, latitude: lat },
      { radius: radius, unit: 'km' }
    )

    return new Response(JSON.stringify({ ids: nearby }), {
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
