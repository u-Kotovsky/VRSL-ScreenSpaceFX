Shader "Unlit/Animated Sprite GIF"
{
    Properties
    {
		[Header(Texture Sheet)]
		_VJLoop1("VJ Loop1", 2D) = "white" {}
		_VJLoop2("VJ Loop2", 2D) = "white" {}
		_VJBlend("VJ Blend Selection", Range(0,1)) = 0
		_Cutoff("Alpha Cutoff", Range(0,1)) = 0.15
		[Header(Settings)]
		_ColumnsX("Columns (X)", int) = 1
		_RowsY("Rows (Y)", int) = 1
		_AnimationSpeed("Frames Per Seconds", float) = 10
        _Scale("Scale Up", Range(0.1,2)) = 1
        _Multiplier ("Multiplier", Range(0,1)) = 1
        _Additive ("Additive", Range(0, .1)) = 0
        _Emission("Light Color Tint", Color) = (1,1,1,1)
        _FrameIndex("FrameIndex", Int) = 0
		[Toggle]_isAlpha ("Is Alpha Cutout", Int) = 0
		[Toggle]_isAnimated ("Is Aniamted?", Int) = 0
        
     }

     SubShader
     {
        Lighting Off
        Blend One Zero

        Pass
        {
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 3.0

			float _Cutoff;
			sampler2D _VJLoop1, _VJLoop2, _RainbowTexture;
			float4 _VJLoop1_ST, _VJLoop2_ST, _Emission;
			uint _ColumnsX;
			uint _RowsY, _isAlpha, _isAnimated, _UseColorChord, _AudioLinkBand, _AudioLinkDelay, _UseRainbow, _Blackout;
            uint _FrameIndex;
			float _AnimationSpeed, _VJBlend, _BandMultiplier, _RainbowSpeed, _RainbowLength;
            float _Scale, _Multiplier, _Additive;
            #include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"
            inline float AudioLinkLerp3_g5( int Band, float Delay )
            {
                return AudioLinkLerp( ALPASS_AUDIOLINK + float2( Delay, Band ) ).r;
            }

            float4 GetColorChordLight()
            {
                return AudioLinkData(ALPASS_CCLIGHTS).rgba;
            }
                float GetAudioReactAmplitude()
            {
                return AudioLinkLerp3_g5(_AudioLinkBand, _AudioLinkDelay) * _BandMultiplier;
            }


            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                if(_Blackout)
                {
                    return float4(0,0,0,0);
                }
                float2 size = float2(1.0f / _ColumnsX, 1.0f / _RowsY);
				uint totalFrames = _ColumnsX * _RowsY;

				// use timer to increment index
				uint index = 0;
				if(_isAnimated)
				{
					 index = floor(_Time.y * _AnimationSpeed);
				}
				else
				{
					 index = _FrameIndex;
				}
				// wrap x and y indexes
				uint indexX = index % _ColumnsX;
				uint indexY = floor((index % totalFrames) / _ColumnsX);

				// get offsets to our sprite index
				float2 offset = float2(size.x*indexX,-size.y*indexY);

                float2 uv = IN.localTexcoord.xy;


                uv -= float2(0.5, 0.5);
                //uv *= (1/_Scale);
                uv *= 1/(1 + (GetAudioReactAmplitude() * 0.5));
                uv += float2(0.5, 0.5);

				// get single sprite UV
				float2 newUV = uv*size;

                

				// flip Y (to start 0 from top)
				newUV.y = newUV.y + size.y*(_RowsY - 1);

				newUV = (newUV + offset);
                // newUV -= float2(0.5, 0.5);
                // newUV *= _Scale;
                // newUV += float2(0.5, 0.5);
                fixed2 RainbowUV = fixed2(((newUV.x + (_RainbowSpeed * _Time.y)) * _RainbowLength), newUV.y);
                
                fixed4 vj1 = tex2D(_VJLoop1, newUV);
				fixed4 vj2 = tex2D(_VJLoop2, newUV);

				fixed4 col = lerp(vj1, vj2, _VJBlend);
                col += _Additive;
                col *= _Multiplier * lerp(2, 6, GetAudioReactAmplitude()) ;
                //col = 
                if(_UseColorChord)
                {
                    col*= GetColorChordLight();
                }
                else if (_UseRainbow)
                {
                    col *= tex2D (_RainbowTexture, RainbowUV);
                } 
                else
                {
                    col *= _Emission;
                }

				// cutout
				// if(_isAlpha == 1)
				// {
				// 	clip(col.a - _Cutoff);					
				// }
				//clip(col.a - _Cutoff);
                return col;



                //return _Color * tex2D(_Tex, IN.localTexcoord.xy);
            }
            ENDCG
            }
    }
}