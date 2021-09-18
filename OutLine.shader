//================================================================================================
//      2DOutLineShader    Var 1.0.0
//
//      Copyright (C) 2021 ayaha401
//      Twitter : @ayaha__401
//
//      This software is released under the MIT License.
//      see https://github.com/ayaha401/2DOutLineShader/blob/main/LICENSE
//================================================================================================
Shader "Unlit/2DOutLineShader"
{
    Properties
    {
        [PerRendererData]_MainTex ("Texture", 2D) = "white" {}
        _Width ("Width", Range(0.0, 0.01)) = 0.001
        _WidthXMul ("Width X Mul", float) = 1.0
        _WidthYMul ("Width Y Mul", float) = 1.0
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
            float _WidthXMul;
            float _WidthYMul;

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
                float4 leftShift = tex2D(_MainTex, float2(i.uv.x + (_Width * _WidthXMul), i.uv.y));
                float4 rightShift = tex2D(_MainTex, float2(i.uv.x - (_Width * _WidthXMul), i.uv.y));
                float4 upShift = tex2D(_MainTex, float2(i.uv.x, i.uv.y + (_Width * _WidthYMul)));
                float4 downShift = tex2D(_MainTex, float2(i.uv.x, i.uv.y - (_Width * _WidthYMul)));

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
