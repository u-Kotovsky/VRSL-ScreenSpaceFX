Shader "VRSL/ScreenSpaceFX"
{
    Properties
    {
        [Toggle] _EnableDMX ("Enable Stream DMX/DMX Control", Int) = 0
        _DMXChannel ("Base DMX Channel", Int) = 0
		[Toggle] _NineUniverseMode ("Extended Universe Mode", Int) = 0
        [Toggle] _EnableVerticalMode ("Enable Vertical Mode", Int) = 0
		[Toggle] _EnableCompatibilityMode ("Enable Compatibility Mode", Int) = 0
        [Space(40)]
        //[NoScaleOffset] _Udon_DMXGridRenderTexture("DMX Grid Render Texture (To Control Lights)", 2D) = "white" {}
        //
        //[Header(Sobel Outline)]
        /////////////////////////////////////////////////////////////////////////////////////////////
        [MyToggle]_SOBEL_ON ("", Int) = 1
        _DMXChannelSobel ("DMX Channel Offset", Int) = 0
        _Factor ("Wet/Dry Strength (ch1)", Range(0, 1)) = 1.0
        _BlacklerpThreshold ("Threshold (ch2)", Range(0.01, 5.0)) = 0.1
        _Outline ("Outline Radius (ch3)", Range(0, 15)) = 8.0
        _OutlineGlow ("Intensity/Glow (ch4)", Range(1, 15)) = 8.0
        //[Space(10)]
        _Colorlerp ("Outline Base Color Mix (ch5)", Range(0, 1)) = 1
        _Color ("Outline Color (ch6+7+8)", Color) = (1,1,1,1)
        //[Space(10)]
        _Blacklerp ("Background Color Alpha (ch9)", Range(0, 1)) = 1
        _BGMix ("Color Mixture (ch10)", Range(0, 1)) = 1
        _BGColor ("Background Color (ch11+12+13)", Color) = (1,1,1,1)
        
        
       /////////////////////////////////////////////////////////////////////////////////////////////

        //[Header(Basic Filters)]
        [MyToggle]_FILTERS_ON ("Toggle Basic Filters", Int) = 1
        _DMXChannelFilters("DMX Channel Offset", Int) = 0
        _FiltersStrength ("Wet/Dry Strength (ch1)", Range(0, 1)) = 1.0
        _Hue ("Hue (ch21)", Range(0, 1)) = 1.0
        _Saturation ("Saturation (ch3)", Range(-1, 1)) = 1.0
        _Brightness ("Brightness (ch4)", Range(-1, 1)) = 1.0
        _Contrast ("Contrast (ch5)", Range(0.9, 1.1)) = 1.0
        /////////////////////////////////////////////////////////////////////////////////////////////

        //[Header(Chromatic Aberration)]
        [MyToggle]_CHROMATIC_ON ("Toggle Chromatic Aberration", Int) = 1
        _DMXChannelChormatic ("DMX Channel Offset", Int) = 0
        _ChromaticAberration ("Wet/Dry Strength (ch1)", Range(0,2)) = 1.0
        _ChromaticAberrationY ("Wet/Dry Strength Y (ch2)", Range(0,2)) = 1.0
        ////////////////////////////////////////////////////////////////////////////////////////////

        //[Header(Screen Shake)]
        [MyToggle]_SHAKE_ON ("Toggle Screen Shake", Int) = 1
        _DMXChannelShake ("DMX Channel Offset", Int) = 0
        _ScreenShakeOverallStrength ("Wet/Dry Strength", Range(0,1)) = 1.0
        _ScreenShakeXStrength ("X Strength", Range(0, 1)) = 1.0
        _ScreenShakeXSpeed("X Speed", Range(0, 20)) = 1.0
        _ScreenShakeYStrength ("Y Strength", Range(0, 1)) = 1.0
        _ScreenShakeYSpeed("Y Speed", Range(0, 20)) = 1.0

        /////////////////////////////////////////////////////////////////////////////////////////////

        //[Header (Texture Scroll)]
        [MyToggle]_TEXTURESCROLL_ON ("Toggle Texture Scroll", Int) = 1
        _DMXChannelScroll ("DMX Channel Offset", Int) = 0
        _ScrollTextureStrength("Wet/Dry Strength", Range(0,1)) = 1.0
        _ScrollXSpeed ("Scroll X Speed", Range(-5, 5)) = 1.0
        _ScrollYSpeed ("Scroll Y Speed", Range(-5, 5)) = 1.0
        _ScrollTextureXScale ("X Scale", Range(-20, 20)) = 1.0
        _ScrollTextureYScale ("Y Scale", Range(-20, 20)) = 1.0
        _ScrollTextureXOffset ("X Offset", Range(-1, 1)) = 1.0
        _ScrollTextureYOffset ("Y Offset", Range(-1, 1)) = 1.0
        //[Space(10)]
        _ScrollMixMethod("Mix Method", Range(0,1)) = 0
        [Toggle]_ScrollAlphaMethod("Alpha Method", Int) = 0
        _ChooseTexture ("Select Texture", Range(1,8)) = 1.0
        [NoScaleOffset] _ScrollTexture("Scroll Texture 1", 2D) = "white" {}
        [NoScaleOffset] _ScrollTexture1("Scroll Texture 2", 2D) = "white" {}
        [NoScaleOffset] _ScrollTexture2("Scroll Texture 3", 2D) = "white" {}
        [NoScaleOffset] _ScrollTexture3("Scroll Texture 4", 2D) = "white" {}
        [NoScaleOffset] _ScrollTexture4("Scroll Texture 5", 2D) = "white" {}
        [NoScaleOffset] _ScrollTexture5("Scroll Texture 6", 2D) = "white" {}
        [NoScaleOffset] _ScrollTexture6("Scroll Texture 7", 2D) = "white" {}
        [NoScaleOffset] _ScrollTexture7("Scroll Texture 8", 2D) = "white" {}
        
    }
    SubShader
    {
        Tags { "Queue"="Transparent+6" "IgnoreProjector"="True" "RenderType"="Transparent" }

        GrabPass {"_VRSLGrabTexture"}
        Cull Off
        ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma shader_feature_local _SOBEL_ON
            #pragma shader_feature_local _FILTERS_ON
            #pragma shader_feature_local _CHROMATIC_ON
            #pragma shader_feature_local _SHAKE_ON
            #pragma shader_feature_local _TEXTURESCROLL_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 screenPos : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                nointerpolation float4 dmxWetDryThresholdRadiusIntensiy : TEXCOORD1;
                nointerpolation float4 dmxOutlineColorWithColorMix : TEXCOORD2;
                nointerpolation float4 dmxBackgroundColorWithAlpha : TEXCOORD3;
                nointerpolation float dmxBackgroundColorMixture : TEXCOORD4;
                nointerpolation float dmxFilterStrength : TEXCOORD5;
                nointerpolation float4 dmxHueSatBrightnessContrast : TEXCOORD6;
                nointerpolation float2 dmxChromaticAberration : TEXCOORD7;
                nointerpolation float3 dmxScreenShake : TEXCOORD8;
                nointerpolation float2 dmxScreenShakeSpeed : TEXCOORD9;
                nointerpolation float4 dmxScrollMixTextureSelectMixMethodAlphaMethod : TEXCOORD10;
                nointerpolation float4 dmxScrollWithOffsetPlusScale: TEXCOORD11;

            };
                sampler2D _VRSLGrabTexture;
                Texture2D _ScrollTexture, _ScrollTexture1, _ScrollTexture2, _ScrollTexture3, _ScrollTexture4, _ScrollTexture5, _ScrollTexture6, _ScrollTexture7;
                SamplerState my_point_repeat_sampler;
                float4 _ScrollTexture_ST;
                float4 _VRSLGrabTexture_TexelSize, _Color, _BGColor;
                float _ScrollTextureStrength, _ScrollXSpeed, _ScrollYSpeed;
                float _Factor, _ScrollMixMethod;
                int _Directions, _ScrollAlphaMethod;
                int _Quality, _ChooseTexture;
                int _DMXChannelSobel;
                float _Size, _Colorlerp, _Outline, _Blacklerp, _BlacklerpThreshold, _OutlineGlow;
                float _ScreenShakeXStrength, _ScreenShakeYStrength, _BGMix, _ScrollTextureXScale, _ScrollTextureYScale, _ScrollTextureXOffset, _ScrollTextureYOffset;
                float _ChromaticAberration, _Contrast, _Brightness, _Saturation, _Hue,_ChromaticAberrationY; 
                int _DMXChannelFilters, _DMXChannelChormatic, _DMXChannelShake, _DMXChannelScroll;
                float _ScreenShakeXSpeed, _ScreenShakeYSpeed, _ScreenShakeOverallStrength, _FiltersStrength;
                #include "Packages/com.acchosen.vr-stage-lighting/Runtime/Shaders/VRSLDMX.cginc"
     
                #if _FILTERS_ON
                    float4x4 contrastMatrix( float contrast )
                    {
                        float t = ( 1.0 - contrast ) / 2.0;
                        
                        return float4x4( contrast, 0, 0, 0,
                                    0, contrast, 0, 0,
                                    0, 0, contrast, 0,
                                    t, t, t, 1 );
                    }
                    float3 rgb2hsv(float3 c)
                    {
                        float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                        float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                        float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

                        float d = q.x - min(q.w, q.y);
                        float e = 1.0e-10;
                        return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
                    }
                    float3 hsv2rgb(float3 c)
                    {
                        float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                        float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                        return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
                    }
                #endif



            v2f vert (appdata v)
            {
                v2f o;
                int dmxSobel = GetDMXChannel() + _DMXChannelSobel;
                int dmxFilters = GetDMXChannel() + _DMXChannelFilters;
                int dmxAberration = GetDMXChannel() + _DMXChannelChormatic;
                int dmxShake = GetDMXChannel() + _DMXChannelShake;
                int dmxScroll = GetDMXChannel() + _DMXChannelScroll;

                //SOBEL OUTLINE START
                o.dmxWetDryThresholdRadiusIntensiy = float4(0,0,0,0);
                o.dmxOutlineColorWithColorMix = float4(0,0,0,0);
                o.dmxBackgroundColorWithAlpha = float4(0,0,0,0);
                o.dmxBackgroundColorMixture = 0.0;              
                #ifdef _SOBEL_ON

                    o.dmxWetDryThresholdRadiusIntensiy.x = ReadDMX(dmxSobel, _Udon_DMXGridRenderTexture); // Channel 1 wet/dry _Factor
                    o.dmxWetDryThresholdRadiusIntensiy.y = ReadDMX(dmxSobel + 1 , _Udon_DMXGridRenderTexture); // Channel 2 threshold _BlacklerpThreshold
                    o.dmxWetDryThresholdRadiusIntensiy.z = ReadDMX(dmxSobel + 2 , _Udon_DMXGridRenderTexture); // Channel 3 radius _Outline
                    o.dmxWetDryThresholdRadiusIntensiy.w = ReadDMX(dmxSobel + 3 , _Udon_DMXGridRenderTexture); // Channel 4 intensity/multiplier _OutlineGlow

                    o.dmxOutlineColorWithColorMix.w = ReadDMX(dmxSobel + 4 , _Udon_DMXGridRenderTexture); // Channel 5 outline Base Color Mix _Colorlerp
                    o.dmxOutlineColorWithColorMix.x = ReadDMX(dmxSobel + 5 , _Udon_DMXGridRenderTexture); // Channel 6 outline color red _Color
                    o.dmxOutlineColorWithColorMix.y = ReadDMX(dmxSobel + 6 , _Udon_DMXGridRenderTexture); // Channel 7 outline color green _Color
                    o.dmxOutlineColorWithColorMix.z = ReadDMX(dmxSobel + 7 , _Udon_DMXGridRenderTexture); // Channel 8 outline color blue _Color
                    

                    o.dmxBackgroundColorWithAlpha.w = ReadDMX(dmxSobel + 8 , _Udon_DMXGridRenderTexture); // Channel 9 background color alpha _BlackLerp
                    o.dmxBackgroundColorMixture = ReadDMX(dmxSobel + 9 , _Udon_DMXGridRenderTexture); // Channel 10 background color mixture _BGMix

                    o.dmxBackgroundColorWithAlpha.x = ReadDMX(dmxSobel + 10 , _Udon_DMXGridRenderTexture); // Channel 11 background color red _BGColor
                    o.dmxBackgroundColorWithAlpha.y = ReadDMX(dmxSobel + 11 , _Udon_DMXGridRenderTexture); // Channel 12 background color green _BGColor
                    o.dmxBackgroundColorWithAlpha.z = ReadDMX(dmxSobel + 12 , _Udon_DMXGridRenderTexture); // Channel 13 background color blue _BGColor
                    
                    o.dmxWetDryThresholdRadiusIntensiy = isDMX() ? float4(o.dmxWetDryThresholdRadiusIntensiy.x, 
                    VRSL_remap(0, 1, 0.01, 1, o.dmxWetDryThresholdRadiusIntensiy.y), 
                    VRSL_remap(0,1,10,0,o.dmxWetDryThresholdRadiusIntensiy.z), 
                    (VRSL_remap(0,1,1,15, o.dmxWetDryThresholdRadiusIntensiy.w))) : 
                    float4(_Factor, _BlacklerpThreshold, _Outline, _OutlineGlow);

                    o.dmxOutlineColorWithColorMix = isDMX() ? o.dmxOutlineColorWithColorMix : float4(_Color.xyz, _Colorlerp);
                #endif
                //SOBEL OUTLINE END

                //FILTERS START
                o.dmxFilterStrength = 0.0;
                o.dmxHueSatBrightnessContrast = float4(0,0,0,0);
                #ifdef _FILTERS_ON
                    o.dmxFilterStrength = isDMX() ? (ReadDMX(dmxFilters, _Udon_DMXGridRenderTexture)) : _FiltersStrength;
                    o.dmxHueSatBrightnessContrast.x = ReadDMX(dmxFilters + 1, _Udon_DMXGridRenderTexture);

                    float satINCREASE = ReadDMX(dmxFilters + 2, _Udon_DMXGridRenderTexture);
                    float satDECREASE = ReadDMX(dmxFilters + 3, _Udon_DMXGridRenderTexture) * -1.0;
                    o.dmxHueSatBrightnessContrast.y = satINCREASE + satDECREASE;

                    float brightnessINCREASE = ReadDMX(dmxFilters + 4, _Udon_DMXGridRenderTexture);
                    float brightnessDECREASE = (ReadDMX(dmxFilters + 5, _Udon_DMXGridRenderTexture)) * -1.0;
                    o.dmxHueSatBrightnessContrast.z = brightnessINCREASE + brightnessDECREASE;

                    float contrastINCREASE = VRSL_remap(0,1,0,0.1, ReadDMX(dmxFilters + 6, _Udon_DMXGridRenderTexture));
                    float contrastDECREASE = VRSL_remap(0,1,0,0.1, ReadDMX(dmxFilters + 7, _Udon_DMXGridRenderTexture)) * -1.0;
                    o.dmxHueSatBrightnessContrast.w = (1 + contrastINCREASE) + contrastDECREASE;
                    o.dmxHueSatBrightnessContrast = isDMX() ? o.dmxHueSatBrightnessContrast : float4(_Hue, _Saturation, _Brightness, _Contrast);
                #endif
                //FILTERS END

                //CHROMATIC ABERRATION START
                o.dmxChromaticAberration = float2(0.0,0.0);
                #ifdef _CHROMATIC_ON
                    o.dmxChromaticAberration.x = ReadDMX(dmxAberration, _Udon_DMXGridRenderTexture) *2;
                    o.dmxChromaticAberration.y = ReadDMX(dmxAberration+1, _Udon_DMXGridRenderTexture) *2;
                    o.dmxChromaticAberration = isDMX() ? o.dmxChromaticAberration : float2(_ChromaticAberration, _ChromaticAberrationY);
                #endif
                //CHROMATIC ABERRATION END

                //SCREEN SHAKE START
                o.dmxScreenShake = float3(0,0,0);
                o.dmxScreenShakeSpeed = float2(0,0);

                #ifdef _SHAKE_ON
                    o.dmxScreenShake.x = ReadDMX(dmxShake, _Udon_DMXGridRenderTexture); //overall strength
                    o.dmxScreenShake.y = ReadDMX(dmxShake + 1, _Udon_DMXGridRenderTexture); // x shake
                    o.dmxScreenShake.z = ReadDMX(dmxShake + 3, _Udon_DMXGridRenderTexture); // y shake

                    float xShakeSpeed =  (ReadDMX(dmxShake+2, _Udon_DMXGridRenderTexture)) * _ScreenShakeXSpeed; // x speed
                    float yShakeSpeed =  (ReadDMX(dmxShake+4, _Udon_DMXGridRenderTexture)) * _ScreenShakeYSpeed; // y speed

                    o.dmxScreenShake = isDMX() ? o.dmxScreenShake : float3(_ScreenShakeOverallStrength, _ScreenShakeXStrength, _ScreenShakeYStrength);
                    o.dmxScreenShakeSpeed = isDMX() ? float2(xShakeSpeed, yShakeSpeed): float2(_ScreenShakeXSpeed, _ScreenShakeYSpeed);
                #endif
                //SCREEN SHAKE END

                //TEXTURE SCROLL START
                o.dmxScrollMixTextureSelectMixMethodAlphaMethod = float4(0,0,0,0);
                o.dmxScrollWithOffsetPlusScale = float4(0,0,0,0);
                
                #ifdef _TEXTURESCROLL_ON
                    o.dmxScrollMixTextureSelectMixMethodAlphaMethod = isDMX() ? float4(ReadDMX(dmxScroll, _Udon_DMXGridRenderTexture), 
                    ((ReadDMX(dmxScroll+1, _Udon_DMXGridRenderTexture)+0.2) * 7), 
                    (ReadDMX(dmxScroll+2, _Udon_DMXGridRenderTexture)),
                    round(ReadDMX(dmxScroll+3, _Udon_DMXGridRenderTexture))) : 
                    float4( _ScrollTextureStrength, _ChooseTexture, _ScrollMixMethod, _ScrollAlphaMethod);
                    float4 flips = float4(1,1,1,1);
                    if(isDMX())
                    {
                        float xFlip = (ReadDMX(dmxScroll+5, _Udon_DMXGridRenderTexture) > 0.5 ? -1 : 1); // scale x direction
                        float yFlip = (ReadDMX(dmxScroll+7, _Udon_DMXGridRenderTexture) > 0.5 ? -1 : 1);// scale y direction
                        float scrollDirX = ReadDMX(dmxScroll+9, _Udon_DMXGridRenderTexture) > 0.5 ? -1 : 1; //scroll x direction
                        float scrollDirY = ReadDMX(dmxScroll+11, _Udon_DMXGridRenderTexture) > 0.5 ? -1 : 1; // scroll y direction
                        flips = float4(xFlip, yFlip, scrollDirX, scrollDirY);
                    }

                    o.dmxScrollWithOffsetPlusScale = isDMX() ? 
                    float4(
                        ((_Time.y * (ReadDMX(dmxScroll+8, _Udon_DMXGridRenderTexture)*5)) * flips.z) + //x scroll
                        (ReadDMX(dmxScroll+12, _Udon_DMXGridRenderTexture)*1) + (ReadDMX(dmxScroll+13, _Udon_DMXGridRenderTexture)*-1), //x offsets
                        ((_Time.y * (ReadDMX(dmxScroll+10, _Udon_DMXGridRenderTexture)*5)) * flips.w) + // y scroll
                        (ReadDMX(dmxScroll+14, _Udon_DMXGridRenderTexture)*1) + (ReadDMX(dmxScroll+15, _Udon_DMXGridRenderTexture)*-1), // yoffsets
                        VRSL_remap(0,1,1,20,ReadDMX(dmxScroll+4, _Udon_DMXGridRenderTexture)) * flips.x,
                        VRSL_remap(0,1,1,20,ReadDMX(dmxScroll+6, _Udon_DMXGridRenderTexture)) * flips.y)  
                        : 
                    float4((_Time.y * _ScrollXSpeed) + _ScrollTextureXOffset, (_Time.y * _ScrollYSpeed) + _ScrollTextureYOffset, _ScrollTextureXScale, _ScrollTextureYScale);
                #endif
                //TEXTURE SCROLL END

                o.pos = (o.dmxWetDryThresholdRadiusIntensiy.x + 
                o.dmxFilterStrength + 
                o.dmxChromaticAberration.x + 
                o.dmxChromaticAberration.y + 
                o.dmxScreenShake.x + 
                o.dmxScrollMixTextureSelectMixMethodAlphaMethod.x) <= 0.01 ? float4(0,0,0,0) : UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeGrabScreenPos(o.pos);

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float4 col = float4(0,0,0,0);
                if((
                i.dmxWetDryThresholdRadiusIntensiy.x + 
                i.dmxFilterStrength + 
                i.dmxChromaticAberration.x + 
                i.dmxChromaticAberration.y + 
                i.dmxScreenShake.x + 
                i.dmxScrollMixTextureSelectMixMethodAlphaMethod.x) <= 0.01)
                {
                    return col;
                }

                float Pi = 6.28318530718; // Pi*2
                float2 screenUV = i.screenPos.xy / i.screenPos.w; // put screenPos in normal UV land

                //SCREEN SHAKE START
                #ifdef _SHAKE_ON
                    float triangleWaveX = (abs(((_Time.y*i.dmxScreenShakeSpeed.x) % 2) - (1)) * 0.1)-0.05;
                    float triangleWaveY = (abs(((_Time.y*i.dmxScreenShakeSpeed.y) % 2) - (1)) * 0.1)-0.05;
                    screenUV.x += ((triangleWaveX*i.dmxScreenShake.y) * i.dmxScreenShake.x);
                    screenUV.y += ((triangleWaveY*i.dmxScreenShake.z) * i.dmxScreenShake.x);
                #endif
                //SCREEN SHAKE END

                //CHROMATIC ABERRATION START
                #ifdef _CHROMATIC_ON
                    float offset = distance(screenUV, float2(0.5, 0.5))*(0.01*i.dmxChromaticAberration.x);
                    float offsetY = distance(screenUV, float2(0.5, 0.5))*(0.02*i.dmxChromaticAberration.y);
                    col = float4(tex2D(_VRSLGrabTexture, screenUV+float2(offset, offsetY)).r, 
                    tex2D(_VRSLGrabTexture, screenUV+float2(-offset, offsetY)).g, 
                    tex2D(_VRSLGrabTexture, screenUV).b, 1.0);
                #else
                    col = tex2D(_VRSLGrabTexture, screenUV);
                #endif
                //CHROMATIC ABERRATION END

                //SOBEL OUTLINE START
                #ifdef _SOBEL_ON
                    float3 preOutlineCol = col.rgb;
                    //Pixel Sampling
                    ///Top Row Kernel
                    float3 TL = tex2D(_VRSLGrabTexture, screenUV + float2(-1, 1)/ _VRSLGrabTexture_TexelSize.zw).rgb;
                    float3 TM = tex2D(_VRSLGrabTexture, screenUV + float2(0, 1)/ _VRSLGrabTexture_TexelSize.zw).rgb;
                    float3 TR = tex2D(_VRSLGrabTexture, screenUV + float2(1, 1)/ _VRSLGrabTexture_TexelSize.zw).rgb;
                    
                    //Middle Row Kernel
                    float3 ML = tex2D(_VRSLGrabTexture, screenUV + float2(-1, 0)/ _VRSLGrabTexture_TexelSize.zw).rgb;
                    float3 C = tex2D(_VRSLGrabTexture, screenUV + float2(0, 0)/ _VRSLGrabTexture_TexelSize.zw).rgb;
                    
                    //The middle pixel is the pixel we are on.
                    float3 MR = tex2D(_VRSLGrabTexture, screenUV + float2(1, 0)/ _VRSLGrabTexture_TexelSize.zw).rgb;
                    
                    //Bottom Row Kernel
                    float3 BL = tex2D(_VRSLGrabTexture, screenUV + float2(-1, -1)/ _VRSLGrabTexture_TexelSize.zw).rgb;
                    float3 BM = tex2D(_VRSLGrabTexture, screenUV + float2(0, -1)/ _VRSLGrabTexture_TexelSize.zw).rgb;
                    float3 BR = tex2D(_VRSLGrabTexture, screenUV + float2(1, -1)/ _VRSLGrabTexture_TexelSize.zw).rgb;


                    //The actual Algorithm
                    float outline = i.dmxWetDryThresholdRadiusIntensiy.z;
                    
                    //X Row
                    float3 GradX = (-TL + TR - 2.0 * ML + 2.0 * MR - BL + BR) * outline;
                    //Y Row
                    float3 GradY = (TL + 2.0 * TM + TR - BL - 2.0 * BM - BR) * outline;

                    
                    col.r = length(float2(GradX.r, GradY.r));
                    col.g = length(float2(GradX.r, GradY.g));
                    col.b = length(float2(GradX.r, GradY.b));
                    float4 color = float4(i.dmxOutlineColorWithColorMix.rgb, 1);
                    float colorLerp = i.dmxOutlineColorWithColorMix.a;

                    float threshold = i.dmxWetDryThresholdRadiusIntensiy.y;
                    
                    col = col <= float4(threshold,threshold,threshold,1) ? float4(0,0,0,1) : col;
                    col = lerp(col, col.r * color, colorLerp);

                    float4 bgColor = isDMX() ? (lerp(float4(i.dmxBackgroundColorWithAlpha.xyz,1),
                    float4(i.dmxBackgroundColorWithAlpha.xyz,1) * float4(preOutlineCol,1), 
                    i.dmxBackgroundColorMixture)) : (lerp(_BGColor,_BGColor * float4(preOutlineCol,1), _BGMix));

                    col = col <= float4(0,0,0,1) ? lerp(float4(preOutlineCol,1), bgColor, isDMX() ? i.dmxBackgroundColorWithAlpha.w : _Blacklerp) : 
                    col * (i.dmxWetDryThresholdRadiusIntensiy.w);
                    
                    col = lerp(float4(preOutlineCol,1), col, i.dmxWetDryThresholdRadiusIntensiy.x);
                #endif
                //SOBEL OUTLINE END

                //TEXTURE SCROLL START
                #ifdef _TEXTURESCROLL_ON
                    float2 screenScrollUV = screenUV;
                    float2 uvScale = float2(i.dmxScrollWithOffsetPlusScale.z, i.dmxScrollWithOffsetPlusScale.w);
                    screenScrollUV = (screenScrollUV - 0.5) * uvScale + 0.5;

                    screenScrollUV.x += i.dmxScrollWithOffsetPlusScale.x;
                    screenScrollUV.y += i.dmxScrollWithOffsetPlusScale.y;
                    float4 scrollTexture = float4(1,1,1,1);
                    switch(floor(i.dmxScrollMixTextureSelectMixMethodAlphaMethod.y))
                    {
                        case 1:
                            scrollTexture = _ScrollTexture.Sample(my_point_repeat_sampler, screenScrollUV);
                            break;
                        case 2: 
                            scrollTexture = _ScrollTexture1.Sample(my_point_repeat_sampler, screenScrollUV);
                            break;
                        case 3: 
                            scrollTexture = _ScrollTexture2.Sample(my_point_repeat_sampler, screenScrollUV);
                            break;
                        case 4: 
                            scrollTexture = _ScrollTexture3.Sample(my_point_repeat_sampler, screenScrollUV);
                            break;
                        case 5: 
                            scrollTexture = _ScrollTexture4.Sample(my_point_repeat_sampler, screenScrollUV);
                            break;
                        case 6: 
                            scrollTexture = _ScrollTexture5.Sample(my_point_repeat_sampler, screenScrollUV);
                            break;
                        case 7: 
                            scrollTexture = _ScrollTexture6.Sample(my_point_repeat_sampler, screenScrollUV);
                            break;
                        case 8: 
                            scrollTexture = _ScrollTexture7.Sample(my_point_repeat_sampler, screenScrollUV);
                            break;
                        default:
                            break;
                    }
                    
                    float4 colScrollTexMix = float4(1,1,1,1);
                    switch(round(i.dmxScrollMixTextureSelectMixMethodAlphaMethod.z * 3))
                    {
                        case 0:
                            colScrollTexMix = lerp(col, scrollTexture, i.dmxScrollMixTextureSelectMixMethodAlphaMethod.x);
                            break;
                        case 1:
                            colScrollTexMix = lerp(col, col * scrollTexture, i.dmxScrollMixTextureSelectMixMethodAlphaMethod.x);
                            break;
                        case 2:
                            colScrollTexMix = lerp(col, col + scrollTexture, i.dmxScrollMixTextureSelectMixMethodAlphaMethod.x);
                            break;
                        case 3:
                            colScrollTexMix = lerp(col, saturate(col / scrollTexture), i.dmxScrollMixTextureSelectMixMethodAlphaMethod.x);
                            break;
                        default: break;
                    }

                    col = i.dmxScrollMixTextureSelectMixMethodAlphaMethod.w  == 0 ? lerp(col,colScrollTexMix,scrollTexture.a) : colScrollTexMix;
                #endif
                //TEXTURE SCROLL END

                //FILTERS START
                #ifdef _FILTERS_ON
                    float3 colhsv = rgb2hsv(col.rgb);
                    colhsv = float3(colhsv.r + i.dmxHueSatBrightnessContrast.x, colhsv.g, colhsv.b + i.dmxHueSatBrightnessContrast.z);
                    
                    float4 filters = float4(hsv2rgb(colhsv), col.a);
                    float3 desat = dot(filters.rgb, float3(0.3, 0.59, 0.11));
                    filters = lerp(float4(desat, filters.a), filters, i.dmxHueSatBrightnessContrast.y+1);
                    filters = mul(filters, contrastMatrix(i.dmxHueSatBrightnessContrast.w));
                    
                    col = lerp(col, filters, i.dmxFilterStrength);
                #endif
                //FITLERS END
                
                return col;
            }
            ENDCG
        }
    }
    CustomEditor "VRSL_ScreenSpaceFX_Editor"
}
