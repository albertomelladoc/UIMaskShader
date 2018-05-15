/*
    Author: Alberto Mellado Cruz
    Date: 15/05/2018

    Comments:
    Mask Shader for UI that allows transparency. 
    You need to place one Image with the colormask at 15 and the other at 0
*/


Shader "Custom/UI/Mask"
{
    Properties
    {
        [PerRendererData] _MainTex("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)

        // required for UI.Mask
        _StencilComp("Stencil Comparison", Float) = 3
        _Stencil("Stencil ID", Float) = 0
        _StencilOp("Stencil Operation", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255
        _ColorMask("Color Mask", Float) = 15

        _Cutoff("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader
    {
    
        Tags
        {
            // ...
        }

        // required for UI.Mask
        Stencil
        {
            Ref[_Stencil]
            Comp[_StencilComp]
            Pass[_StencilOp]
            ReadMask[_StencilReadMask]
            WriteMask[_StencilWriteMask]
        }
        
        ZTest[unity_GUIZTestMode]
        
        ColorMask[_ColorMask] //15 -> Color -- 0 -> Mask(Alpha)

        Blend SrcAlpha OneMinusSrcAlpha //Transparency

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            float _Cutoff;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv) * _Color;

                if (c.a < _Cutoff)
                discard;
            
                return c;
            }

            ENDCG
        }
    }
}
