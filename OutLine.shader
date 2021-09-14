Shader "Unlit/OutLine"
{
    Properties
    {
        [PerRendererData]_MainTex ("Texture", 2D) = "white" {}
        _Width ("Width", Range(0.0, 1.0)) = 0.01
        [PerRendererData]_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _OutLineColor ("OutLineColor", Color) = (1.0, 1.0, 1.0, 1.0)

        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
    }
    SubShader
    {
        Tags 
        { 
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ PIXELSNAP_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Width; 
            float4 _Color;
            float4 _OutLineColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color * _Color;
                
                #ifdef PIXELSNAP_ON
                    o.vertex = UnityPixelSnap(v.vertex);
                #endif

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 originalCol = tex2D(_MainTex, i.uv);
                float4 leftShift = tex2D(_MainTex, float2(i.uv.x + _Width, i.uv.y));
                float4 rightShift = tex2D(_MainTex, float2(i.uv.x - _Width, i.uv.y));
                float4 upShift = tex2D(_MainTex, float2(i.uv.x, i.uv.y + _Width * 3.0));
                float4 downShift = tex2D(_MainTex, float2(i.uv.x, i.uv.y - _Width * 3.0));

                float4 outLineCol = saturate((leftShift.a - originalCol.a) + (rightShift.a - originalCol.a) + (upShift.a - originalCol.a) + (downShift.a - originalCol.a));
                outLineCol = outLineCol * _OutLineColor;

                float4 col = originalCol + outLineCol;
                col *= i.color;
                col.rgb = col * (1.0 - outLineCol.a) + outLineCol * outLineCol.a;
                col.rgb *= col.a;
                return col;
            }
            ENDCG
        }
    }
}
