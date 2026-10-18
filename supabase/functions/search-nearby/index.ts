import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@upstash/redis@1.34.3'

const redis = createClient({
  url: Deno.env.get('UPSTASH_REDIS_REST_URL')!,
  token: Deno.env.get('UPSTASH_REDIS_REST_TOKEN')!,
})

serve(async (req) => {
  try {
    const { lat, lng, radius } = await req.json()

    // GEOSEARCH user_locations FROMLONLAT lng lat BYRADIUS radius KM ASC WITHDIST
    const found = (await redis.geosearch(
      'user_locations',
      { type: 'FROMLONLAT', coordinate: { lon: lng, lat: lat } },
      { type: 'BYRADIUS', radius: radius, radiusType: 'KM' },
      'ASC',
      { withDist: true },
    )) as Array<{ member: string; dist?: number }>

    const nearby = found.map((f) => f.member)
    // Distância em metros, na mesma ordem de `ids` (mais próximos primeiro).
    const distances = found.map((f) => Math.round((f.dist ?? 0) * 1000))

    return new Response(JSON.stringify({ ids: nearby, distances }), {
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
