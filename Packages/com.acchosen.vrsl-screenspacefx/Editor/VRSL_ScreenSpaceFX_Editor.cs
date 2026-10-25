#if !COMPILER_UDONSHARP && UNITY_EDITOR
using System.Reflection;
using UnityEditor;
using UnityEngine;

namespace VRSL.ScreenSpaceFX.Editor
{
    public class MyToggleDrawer : MaterialPropertyDrawer
    {
        // Draw the property inside the given rect
        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            Color originalBackground = GUI.backgroundColor;
            // Setup
            bool value = (prop.floatValue != 0.0f);
            float x = position.x;
            Color onColor = new Color(0.95f, 0.95f, 0.95f, 1.0f);
            Color offColor = new Color(0.5f, 0.5f, 0.5f, 1.0f);
            // float xMax = position.xMax;
            // float xMin = position.xMin;
            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;
            GUIStyle style = new GUIStyle("button");
            //position.height = 30;
            // Show the toggle control
            GUI.backgroundColor = value ? onColor : offColor;
            string buttonText = value ? "Enabled" : "Disabled";
            position.width = 60f;
            position.height = 30f;
            //position.xMax = xMax - 25;
            //position.xMin = xMin + 100;
            position.x = EditorGUIUtility.currentViewWidth - 79f;
            if (GUI.Button(position, buttonText, style))
            {
                value = !value;
            }
            //value = EditorGUI.Toggle(position, value);

            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck())
            {
                // Set the new value if it has changed
                prop.floatValue = value ? 1.0f : 0.0f;
            }

            GUI.backgroundColor = originalBackground;
        }
    }

    public class VRSL_ScreenSpaceFX_Editor : ShaderGUI
    {
        BindingFlags bindingFlags = BindingFlags.Public |
                                    BindingFlags.NonPublic |
                                    BindingFlags.Instance |
                                    BindingFlags.Static;

        MaterialProperty _EnableDMX = null;
        MaterialProperty _DMXChannel = null;
        MaterialProperty _NineUniverseMode = null;
        MaterialProperty _EnableVerticalMode = null;

        MaterialProperty _EnableCompatibilityMode = null;

        MaterialProperty _SOBEL_ON = null;
        MaterialProperty _DMXChannelSobel = null;
        MaterialProperty _Factor = null;
        MaterialProperty _BlacklerpThreshold = null;
        MaterialProperty _Outline = null;
        MaterialProperty _OutlineGlow = null;
        MaterialProperty _Colorlerp = null;
        MaterialProperty _Color = null;
        MaterialProperty _Blacklerp = null;
        MaterialProperty _BGMix = null;
        MaterialProperty _BGColor = null;
        MaterialProperty _FILTERS_ON = null;
        MaterialProperty _DMXChannelFilters = null;
        MaterialProperty _FiltersStrength = null;
        MaterialProperty _Hue = null;
        MaterialProperty _Saturation = null;
        MaterialProperty _Brightness = null;
        MaterialProperty _Contrast = null;
        MaterialProperty _CHROMATIC_ON = null;
        MaterialProperty _DMXChannelChormatic = null;
        MaterialProperty _ChromaticAberration = null;
        MaterialProperty _ChromaticAberrationY = null;
        MaterialProperty _SHAKE_ON = null;
        MaterialProperty _DMXChannelShake = null;
        MaterialProperty _ScreenShakeOverallStrength = null;
        MaterialProperty _ScreenShakeXStrength = null;
        MaterialProperty _ScreenShakeXSpeed = null;
        MaterialProperty _ScreenShakeYStrength = null;
        MaterialProperty _ScreenShakeYSpeed = null;
        MaterialProperty _TEXTURESCROLL_ON = null;
        MaterialProperty _DMXChannelScroll = null;
        MaterialProperty _ScrollTextureStrength = null;
        MaterialProperty _ScrollXSpeed = null;
        MaterialProperty _ScrollYSpeed = null;
        MaterialProperty _ScrollTextureXScale = null;
        MaterialProperty _ScrollTextureYScale = null;
        MaterialProperty _ScrollTextureXOffset = null;
        MaterialProperty _ScrollTextureYOffset = null;
        MaterialProperty _ScrollMixMethod = null;
        MaterialProperty _ScrollAlphaMethod = null;
        MaterialProperty _ChooseTexture = null;
        MaterialProperty _ScrollTexture = null;
        MaterialProperty _ScrollTexture1 = null;
        MaterialProperty _ScrollTexture2 = null;
        MaterialProperty _ScrollTexture3 = null;
        MaterialProperty _ScrollTexture4 = null;
        MaterialProperty _ScrollTexture5 = null;
        MaterialProperty _ScrollTexture6 = null;

        MaterialProperty _ScrollTexture7 = null;

        //foldout booleans
        static bool showOutlineSettings = true;
        static bool showFilterSettings = true;
        static bool showChromaticSettings = true;
        static bool showShakeSettings = true;
        static bool showTextureScrollSettings = true;


        private GUIStyle FoldOutLabel()
        {
            GUIStyle style = new GUIStyle("foldoutHeader");
            style.fontSize = 20;
            style.fixedHeight = 30;
            //style.fixedWidth = EditorGUIUtility.currentViewWidth-100;
            //style.padding.right = 800;
            // style.padding.left = 0;
            //style.margin.right = 0;
            // style.margin.left = 0;
            style.alignment = TextAnchor.MiddleLeft;
            style.fontStyle = FontStyle.Normal;
            style.richText = true;
            style.stretchWidth = true;
            return style;
        }

        private GUIStyle Label(int size)
        {
            GUIStyle style = new GUIStyle();
            style.fontSize = size;
            style.fontStyle = FontStyle.Italic;
            style.normal.textColor = Color.white;
            style.alignment = TextAnchor.MiddleCenter;

            return style;
        }

        private GUIStyle Label2(int size)
        {
            GUIStyle style = new GUIStyle();
            style.fontSize = size;
            style.fontStyle = FontStyle.Normal;
            style.normal.textColor = Color.white;
            style.alignment = TextAnchor.MiddleLeft;
            style.padding = new RectOffset(0, 0, 0, 0);
            style.margin = new RectOffset(0, 0, 0, 0);

            return style;
        }

        int GetUniverse(int channel)
        {
            if (Between(channel, 512, 521))
            {
                return 0;
            }

            if (Between(channel, 1032, 1041))
            {
                return 0;
            }

            if (Between(channel, 1552, 1561))
            {
                return 0;
            }

            if (Between(channel, 2072, 2081))
            {
                return 0;
            }

            if (Between(channel, 2592, 2601))
            {
                return 0;
            }

            if (Between(channel, 3112, 3121))
            {
                return 0;
            }

            if (Between(channel, 3632, 3641))
            {
                return 0;
            }

            if (Between(channel, 4152, 4161))
            {
                return 0;
            }

            if (channel > 4672)
            {
                return 0;
            }

            if (channel > 520 && channel < 1033)
            {
                return 2;
            }
            else if (channel > 1040 && channel < 1553)
            {
                return 3;
            }
            else if (channel > 1560 && channel < 2073)
            {
                return 4;
            }
            else if (channel > 2080 && channel < 2601)
            {
                return 5;
            }
            else if (channel > 2600 && channel < 3113)
            {
                return 6;
            }
            else if (channel > 3120 && channel < 3633)
            {
                return 7;
            }
            else if (channel > 3640 && channel < 4153)
            {
                return 8;
            }
            else if (channel > 4160 && channel < 4673)
            {
                return 9;
            }

            return 1;
        }

        bool Between(int x, int y, int z)
        {
            return x > y && x < z;
        }

        int GetChannel(int channel)
        {
            if (Between(channel, 512, 521))
            {
                return 0;
            }

            if (Between(channel, 1032, 1041))
            {
                return 0;
            }

            if (Between(channel, 1552, 1561))
            {
                return 0;
            }

            if (Between(channel, 2072, 2081))
            {
                return 0;
            }

            if (Between(channel, 2592, 2601))
            {
                return 0;
            }

            if (Between(channel, 3112, 3121))
            {
                return 0;
            }

            if (Between(channel, 3632, 3641))
            {
                return 0;
            }

            if (Between(channel, 4152, 4161))
            {
                return 0;
            }

            if (channel > 4672)
            {
                return 0;
            }

            if (channel > 520 && channel < 1033)
            {
                channel -= 7;
                return Mathf.FloorToInt(channel % 513);
            }
            else if (channel > 1040 && channel < 1553)
            {
                return Mathf.FloorToInt(channel % (1040));
            }
            else if (channel > 1560 && channel < 2073)
            {
                return Mathf.FloorToInt(channel % 1560);
            }
            else if (channel > 2080 && channel < 2593)
            {
                return Mathf.FloorToInt(channel % 2080);
            }
            else if (channel > 2600 && channel < 3113)
            {
                return Mathf.FloorToInt(channel % 2600);
            }
            else if (channel > 3120 && channel < 3633)
            {
                return Mathf.FloorToInt(channel % 3120);
            }
            else if (channel > 3640 && channel < 4153)
            {
                return Mathf.FloorToInt(channel % 3640);
            }
            else if (channel > 4160 && channel < 4673)
            {
                return Mathf.FloorToInt(channel % 4160);
            }

            return channel;

        }

        int Chan(MaterialProperty c)
        {
            return Mathf.FloorToInt(c.floatValue);
        }

        public static void SetKeyword(Material mat, string keyword, bool status)
        {
            if (status)
            {
                mat.EnableKeyword(keyword);
            }
            else
            {
                mat.DisableKeyword(keyword);
            }
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            Material material = materialEditor.target as Material;
            Shader shader = material.shader;

            //END Type Identifiers

            foreach (var property in GetType().GetFields(bindingFlags))
            {
                if (property.FieldType == typeof(MaterialProperty))
                {
                    try
                    {
                        property.SetValue(this, FindProperty(property.Name, props));
                    }
                    catch
                    {
                    }
                }
            }

            EditorGUI.BeginChangeCheck();
            {
                Color originalBackground = GUI.backgroundColor;
                Color foldoutColor = new Color(0.85f, 0.85f, 0.85f, 1.0f);
                Color innerColor = new Color(0.9f, 0.9f, 0.9f, 1.0f);
                VRSLStyles.DrawLogo();
                VRSLStyles.ShurikenHeaderCentered(VRSLStyles.GetVersion());
                VRSLStyles.PartingLine();
                //VRSLStyles.DepthPassWarning();
                GUILayout.Space(5);

                EditorGUILayout.LabelField(
                    "Universe: " + GetUniverse(Chan(_DMXChannel)) + "  Base Channel: " + GetChannel(Chan(_DMXChannel)),
                    Label(17));
                GUILayout.Space(5);
                materialEditor.ShaderProperty(_EnableDMX, "Enable DMX");
                //materialEditor.TexturePropertySingleLine(new GUIContent("DMX Grid"),_Udon_DMXGridRenderTexture);
                GUILayout.Space(5);
                materialEditor.ShaderProperty(_DMXChannel, "Base DMX Channel");
                GUILayout.Space(5);
                materialEditor.ShaderProperty(_NineUniverseMode, "Enable Nine Universe Mode");
                materialEditor.ShaderProperty(_EnableVerticalMode, "Enable Vertical Mode");
                materialEditor.ShaderProperty(_EnableCompatibilityMode, "Enable Compatibility Mode");
                VRSLStyles.PartingLine();
                GUILayout.Space(10);
                
                GUI.backgroundColor = foldoutColor;
                EditorGUILayout.BeginHorizontal();
                Rect rect = GUILayoutUtility.GetRect(new GUIContent("Sobel Outline"), FoldOutLabel());
                float x = rect.width;
                rect.width = EditorGUIUtility.currentViewWidth - 103;
                showOutlineSettings =
                    EditorGUI.BeginFoldoutHeaderGroup(rect, showOutlineSettings, "Sobel Outline", FoldOutLabel());
                materialEditor.ShaderProperty(_SOBEL_ON, "");
                SetKeyword(material, "_SOBEL_ON", (Mathf.FloorToInt(material.GetInt("_SOBEL_ON"))) == 1);

                EditorGUILayout.EndHorizontal();
                GUI.backgroundColor = originalBackground;
                if (showOutlineSettings)
                {

                    GUILayout.Space(5);
                    EditorGUI.BeginDisabledGroup(_SOBEL_ON.floatValue != 1.0);

                    EditorGUI.indentLevel++;

                    EditorGUILayout.LabelField("Channel: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelSobel)),
                        Label(15));
                    GUILayout.Space(5);
                    GUI.backgroundColor = innerColor;
                    materialEditor.ShaderProperty(_DMXChannelSobel, "DMX Channel Offset");
                    GUILayout.Space(10);
                    //EditorGUILayout.BeginHorizontal();
                    materialEditor.ShaderProperty(_Factor, "Wet/Dry Strength");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelSobel)),
                        Label2(10));
                    //EditorGUILayout.EndHorizontal();

                    materialEditor.ShaderProperty(_BlacklerpThreshold, "Threshold");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelSobel) + 1),
                        Label2(10));

                    materialEditor.ShaderProperty(_Outline, "Outline Radius");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelSobel) + 2),
                        Label2(10));

                    materialEditor.ShaderProperty(_OutlineGlow, "Intensity/Glow");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelSobel) + 3),
                        Label2(10));

                    materialEditor.ShaderProperty(_Colorlerp, "Outline Base Color Mix");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelSobel) + 4),
                        Label2(10));

                    materialEditor.ShaderProperty(_Color, "Outline Color");
                    EditorGUILayout.LabelField("Ch:    R: " +
                                               GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelSobel) + 5) + "   G: " +
                                               GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelSobel) + 6) + "   B: " +
                                               GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelSobel) + 7), Label2(10));

                    materialEditor.ShaderProperty(_Blacklerp, "Background Color Alpha");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelSobel) + 8),
                        Label2(10));

                    materialEditor.ShaderProperty(_BGMix, "Background Mix Method");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelSobel) + 9),
                        Label2(10));

                    materialEditor.ShaderProperty(_BGColor, "Background Color");
                    EditorGUILayout.LabelField("Ch:    R: " +
                                               GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelSobel) + 10) + "   G: " +
                                               GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelSobel) + 11) + "   B: " +
                                               GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelSobel) + 12), Label2(10));

                    VRSLStyles.PartingLine();

                    GUI.backgroundColor = originalBackground;
                    EditorGUI.indentLevel--;
                    EditorGUI.EndDisabledGroup();
                }

                EditorGUILayout.EndFoldoutHeaderGroup();
                GUILayout.Space(10);
                EditorGUILayout.BeginHorizontal();
                GUI.backgroundColor = foldoutColor;
                rect = GUILayoutUtility.GetRect(new GUIContent("Filters"), FoldOutLabel());
                x = rect.width;
                rect.width = EditorGUIUtility.currentViewWidth - 103;
                showFilterSettings =
                    EditorGUI.BeginFoldoutHeaderGroup(rect, showFilterSettings, "Filters", FoldOutLabel());
                materialEditor.ShaderProperty(_FILTERS_ON, "");
                SetKeyword(material, "_FILTERS_ON",
                    (Mathf.FloorToInt(material.GetInt("_FILTERS_ON"))) == 1);

                EditorGUILayout.EndHorizontal();
                GUI.backgroundColor = originalBackground;
                if (showFilterSettings)
                {
                    EditorGUI.BeginDisabledGroup(_FILTERS_ON.floatValue != 1.0);
                    GUILayout.Space(5);
                    EditorGUI.indentLevel++;
                    EditorGUILayout.LabelField("Channel: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelFilters)),
                        Label(15));
                    GUILayout.Space(5);
                    GUI.backgroundColor = innerColor;
                    materialEditor.ShaderProperty(_DMXChannelFilters, "DMX Channel Offset");
                    GUILayout.Space(10);
                    materialEditor.ShaderProperty(_FiltersStrength, "Wet/Dry Strength");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelFilters)),
                        Label2(10));

                    materialEditor.ShaderProperty(_Hue, "Hue");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelFilters) + 1),
                        Label2(10));

                    materialEditor.ShaderProperty(_Saturation, "Saturation");
                    EditorGUILayout.LabelField(
                        "Ch:   INCREASE: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelFilters) + 2) +
                        "   DECREASE: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelFilters) + 3), Label2(10));

                    materialEditor.ShaderProperty(_Brightness, "Brightness");
                    EditorGUILayout.LabelField(
                        "Ch:   INCREASE: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelFilters) + 4) +
                        "   DECREASE: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelFilters) + 5), Label2(10));

                    materialEditor.ShaderProperty(_Contrast, "Contrast");
                    EditorGUILayout.LabelField(
                        "Ch:   INCREASE: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelFilters) + 6) +
                        "   DECREASE: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelFilters) + 7), Label2(10));


                    VRSLStyles.PartingLine();
                    GUI.backgroundColor = originalBackground;
                    EditorGUI.indentLevel--;
                    EditorGUI.EndDisabledGroup();
                }

                EditorGUI.EndFoldoutHeaderGroup();
                GUILayout.Space(10);
                EditorGUILayout.BeginHorizontal();
                GUI.backgroundColor = foldoutColor;
                rect = GUILayoutUtility.GetRect(new GUIContent("Chromatic Aberration"), FoldOutLabel());
                x = rect.width;
                rect.width = EditorGUIUtility.currentViewWidth - 103;
                showChromaticSettings = EditorGUI.BeginFoldoutHeaderGroup(rect, showChromaticSettings,
                    "Chromatic Aberration", FoldOutLabel());
                materialEditor.ShaderProperty(_CHROMATIC_ON, "");
                SetKeyword(material, "_CHROMATIC_ON",
                    (Mathf.FloorToInt(material.GetInt("_CHROMATIC_ON"))) == 1);

                EditorGUILayout.EndHorizontal();
                GUI.backgroundColor = originalBackground;
                if (showChromaticSettings)
                {
                    EditorGUI.BeginDisabledGroup(_CHROMATIC_ON.floatValue != 1.0);
                    GUILayout.Space(5);
                    EditorGUI.indentLevel++;
                    EditorGUILayout.LabelField("Channel: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelChormatic)),
                        Label(15));
                    GUILayout.Space(5);
                    GUI.backgroundColor = innerColor;
                    materialEditor.ShaderProperty(_DMXChannelChormatic, "DMX Channel Offset");
                    GUILayout.Space(10);

                    materialEditor.ShaderProperty(_ChromaticAberration, "Wet/Dry X Axis");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelChormatic)),
                        Label2(10));

                    materialEditor.ShaderProperty(_ChromaticAberrationY, "Wet/Dry Y Axis");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelChormatic) + 1),
                        Label2(10));


                    VRSLStyles.PartingLine();
                    GUI.backgroundColor = originalBackground;
                    EditorGUI.indentLevel--;
                    EditorGUI.EndDisabledGroup();
                }

                EditorGUI.EndFoldoutHeaderGroup();

                GUILayout.Space(10);
                EditorGUILayout.BeginHorizontal();
                GUI.backgroundColor = foldoutColor;
                rect = GUILayoutUtility.GetRect(new GUIContent("Screen Shake"), FoldOutLabel());
                x = rect.width;
                rect.width = EditorGUIUtility.currentViewWidth - 103;
                showShakeSettings =
                    EditorGUI.BeginFoldoutHeaderGroup(rect, showShakeSettings, "Screen Shake", FoldOutLabel());
                materialEditor.ShaderProperty(_SHAKE_ON, "");
                SetKeyword(material, "_SHAKE_ON", (Mathf.FloorToInt(material.GetInt("_SHAKE_ON"))) == 1);

                EditorGUILayout.EndHorizontal();
                GUI.backgroundColor = originalBackground;
                if (showShakeSettings)
                {
                    EditorGUI.BeginDisabledGroup(_SHAKE_ON.floatValue != 1.0);
                    GUILayout.Space(5);
                    EditorGUI.indentLevel++;
                    EditorGUILayout.LabelField("Channel: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelShake)),
                        Label(15));
                    GUILayout.Space(5);
                    GUI.backgroundColor = innerColor;
                    materialEditor.ShaderProperty(_DMXChannelShake, "DMX Channel Offset");
                    GUILayout.Space(10);

                    materialEditor.ShaderProperty(_ScreenShakeOverallStrength, "Wet/Dry Strength");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelShake)),
                        Label2(10));

                    materialEditor.ShaderProperty(_ScreenShakeXStrength, "X Shake Strength");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelShake) + 1),
                        Label2(10));

                    materialEditor.ShaderProperty(_ScreenShakeXSpeed, "X Shake Speed");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelShake) + 2),
                        Label2(10));

                    materialEditor.ShaderProperty(_ScreenShakeYStrength, "Y Shake Strength");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelShake) + 3),
                        Label2(10));

                    materialEditor.ShaderProperty(_ScreenShakeYSpeed, "Y Shake Speed");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelShake) + 4),
                        Label2(10));

                    VRSLStyles.PartingLine();
                    GUI.backgroundColor = originalBackground;
                    EditorGUI.indentLevel--;
                    EditorGUI.EndDisabledGroup();
                }

                EditorGUI.EndFoldoutHeaderGroup();
                GUILayout.Space(10);
                EditorGUILayout.BeginHorizontal();
                GUI.backgroundColor = foldoutColor;
                rect = GUILayoutUtility.GetRect(new GUIContent("Texture Scroll/Overlay"), FoldOutLabel());
                x = rect.width;
                rect.width = EditorGUIUtility.currentViewWidth - 103;
                showTextureScrollSettings = EditorGUI.BeginFoldoutHeaderGroup(rect, showTextureScrollSettings,
                    "Texture Scroll/Overlay", FoldOutLabel());
                materialEditor.ShaderProperty(_TEXTURESCROLL_ON, "");
                SetKeyword(material, "_TEXTURESCROLL_ON",
                    (Mathf.FloorToInt(material.GetInt("_TEXTURESCROLL_ON"))) == 1);

                EditorGUILayout.EndHorizontal();
                GUI.backgroundColor = originalBackground;
                if (showTextureScrollSettings)
                {
                    EditorGUI.BeginDisabledGroup(_TEXTURESCROLL_ON.floatValue != 1.0);
                    GUILayout.Space(5);
                    EditorGUI.indentLevel++;
                    EditorGUILayout.LabelField("Channel: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll)),
                        Label(15));
                    GUILayout.Space(5);
                    GUI.backgroundColor = innerColor;
                    materialEditor.ShaderProperty(_DMXChannelScroll, "DMX Channel Offset");
                    GUILayout.Space(10);

                    EditorGUILayout.BeginHorizontal("box");
                    materialEditor.TexturePropertySingleLine(new GUIContent("Texture 1"), _ScrollTexture);
                    materialEditor.TexturePropertySingleLine(new GUIContent("Texture 2"), _ScrollTexture1);
                    EditorGUILayout.EndHorizontal();
                    EditorGUILayout.BeginHorizontal("box");
                    materialEditor.TexturePropertySingleLine(new GUIContent("Texture 3"), _ScrollTexture2);
                    materialEditor.TexturePropertySingleLine(new GUIContent("Texture 4"), _ScrollTexture3);
                    EditorGUILayout.EndHorizontal();
                    EditorGUILayout.BeginHorizontal("box");
                    materialEditor.TexturePropertySingleLine(new GUIContent("Texture 5"), _ScrollTexture4);
                    materialEditor.TexturePropertySingleLine(new GUIContent("Texture 6"), _ScrollTexture5);
                    EditorGUILayout.EndHorizontal();
                    EditorGUILayout.BeginHorizontal("box");
                    materialEditor.TexturePropertySingleLine(new GUIContent("Texture 7"), _ScrollTexture6);
                    materialEditor.TexturePropertySingleLine(new GUIContent("Texture 8"), _ScrollTexture7);
                    EditorGUILayout.EndHorizontal();

                    GUILayout.Space(10);
                    materialEditor.ShaderProperty(_ScrollTextureStrength, "Wet/Dry Strength");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll)),
                        Label2(10));

                    materialEditor.ShaderProperty(_ChooseTexture, "Select Texture");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll) + 1),
                        Label2(10));

                    materialEditor.ShaderProperty(_ScrollMixMethod, "Texture Mix Method");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll) + 2),
                        Label2(10));

                    materialEditor.ShaderProperty(_ScrollAlphaMethod, "Texture Alpha Method");
                    EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll) + 3),
                        Label2(10));

                    materialEditor.ShaderProperty(_ScrollTextureXOffset, "X Offset");
                    //EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll)+3), Label2(10));

                    materialEditor.ShaderProperty(_ScrollTextureYOffset, "Y Offset");
                    ////EditorGUILayout.LabelField("Ch: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll)+3), Label2(10));

                    materialEditor.ShaderProperty(_ScrollTextureXScale, "X Scale");
                    EditorGUILayout.LabelField(
                        "Ch:     Scale Amount: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll) + 4)
                                                 + "    Direction: " +
                                                 GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll) + 5),
                        Label2(10));

                    materialEditor.ShaderProperty(_ScrollTextureYScale, "Y Scale");
                    EditorGUILayout.LabelField(
                        "Ch:     Scale Amount: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll) + 6)
                                                 + "    Direction: " +
                                                 GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll) + 7),
                        Label2(10));

                    materialEditor.ShaderProperty(_ScrollXSpeed, "X Speed");
                    EditorGUILayout.LabelField(
                        "Ch:     Speed: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll) + 8)
                                          + "    Direction: " +
                                          GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll) + 9), Label2(10));

                    materialEditor.ShaderProperty(_ScrollYSpeed, "Y Speed");
                    EditorGUILayout.LabelField(
                        "Ch:     Speed: " + GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll) + 10)
                                          + "    Direction: " +
                                          GetChannel(Chan(_DMXChannel) + Chan(_DMXChannelScroll) + 11), Label2(10));

                    VRSLStyles.PartingLine();
                    GUI.backgroundColor = originalBackground;
                    EditorGUI.indentLevel--;
                    EditorGUI.EndDisabledGroup();
                }

                EditorGUI.EndFoldoutHeaderGroup();
                GUILayout.Space(10);
            }
        }
    }
}
#endif