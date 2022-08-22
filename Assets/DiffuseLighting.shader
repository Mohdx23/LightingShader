Shader "Unlit/DiffuseLighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightPoint ("Light Point Position", Vector) = (0, 0, 0 ,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work 
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPosition : TEXCOORD2;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _LightPoint;

            v2f vert (appdata v) //Feeding in appdata which gives extra info and we're outputting v2f that is the fed into our frag func.'
            {
                v2f o;
                o.worldNormal = UnityObjectToWorldNormal(v.normal); //N=Face of mesh/direction. //UnityToWorldNorm converts N from mesh to worldspace. 
                o.vertex = UnityObjectToClipPos(v.vertex);//Translates vertex into something we can use in mesh.
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);//we use the * function to multiply the matrix by our vertex. It takes our object vertex and translates it into worldspace. O = worldSpPosition of our object.
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);//translating the uv tex into coordinates.
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed3 lightDifference = i.worldPosition - _LightPoint.xyz; //To get the lightDifference, we - the worldposition and the lightpoint.xyz which we pulled using the swizzle operator. (Order-sens)
                fixed3 lightDirection = normalize(lightDifference);//Since we don't have use for the mang of the lightdiff, we normalize it to give it a length of 1/normals on mesh will also have a length of 1.
                fixed intensity = -.5 * dot(lightDirection, i.worldNormal) + 0.5f;//returns cosine of the angle between vector. if we give it two normalized vectors, result will be 1 if those vectors are in the same direction. -1 if anti-parallel.
                fixed4 col = intensity * tex2D(_MainTex, i.uv); //  *Tex2d
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
